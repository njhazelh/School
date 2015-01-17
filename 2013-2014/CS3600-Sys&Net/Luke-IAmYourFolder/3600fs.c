/*
 * CS3600, Spring 2014
 * Project 2: FAT Filesystem
 * Author: Nick Jones, Victor Monterosso
 * Version: 3/10/2014
 * 
 * This file contains the implementation for using our FAT filesystem.
 * Modified from starter code provided my Alan Mislove.
  * See project handout for more details.
 */

#define FUSE_USE_VERSION 26

#ifdef linux
/* For pread()/pwrite() */
#define _XOPEN_SOURCE 500
#endif

#define _POSIX_C_SOURCE 199309

#include <time.h>
#include <fuse.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <errno.h>
#include <assert.h>
#include <sys/statfs.h>
#include <stdbool.h>
#include <libgen.h>

#ifdef HAVE_SETXATTR
#include <sys/xattr.h>
#endif

#include "3600fs.h"
#include "disk.h"

vcb globalvcb;
dirent directoryList[NUM_DIR_ENTS];
fatent *fatList;

bool direntExists(const char *name);
int writeDirent(int i);
int findFile(const char *name);
void dumpBlock(char block[]);
int rewriteFat(int fatNum);
int zeroDB(int blockNum);
int findEmptyFat();
int makeSpace(dirent *file, size_t size, off_t offset);

/**
* Write the dirent at index i in our cached dirents to the disk
* returns BLOCKSIZE if sucessful else, a negative error value
*/
int writeDirent(int i) {
	char tmp[BLOCKSIZE];
	memcpy(tmp, &directoryList[i], sizeof(dirent));

	return dwrite(1 + i, tmp);
}



/**
* Is there a directory entry with the name given?
* ASSUMES THAT THERE IS ONLY ONE LEVEL OF DIRECTORY
*/
bool direntExists(const char *name) {
	for (int i = 0; i < NUM_DIR_ENTS; i++)
		if (directoryList[i].valid && strcmp(directoryList[i].name, name) == 0)
			return true;

	return false;
}



/**
* Find the index of file with the given name.
*  *name The name of the file to find
*  returns the index in the cached dirents or -1 if the file doesnt exist.
*/
int findFile(const char *name) {
	for (int i = 0; i < NUM_DIR_ENTS; i++)
		if (directoryList[i].valid && strcmp(directoryList[i].name, name) == 0)
			return i;

	return -1;
}



/**
* Print out all the characters in the block, 10 per line.
*  block[] - The block to print out.
*/
void dumpBlock(char block[]) {
	for (int i = 0; i < BLOCKSIZE;) {
		for (int j = 0; j < 10 && i < BLOCKSIZE; j++, i++)
			printf("%1c[%3d] ",block[i],block[i]);
		printf("\n");
	}
}



/**
* Write the fatent at index fatNum to the disk
*	
* Returns BLOCKSIZE if not successful, else 0
*/
int rewriteFat(int fatNum) {
	char block[BLOCKSIZE];
	dread(globalvcb.fat_start + (fatNum * sizeof(fatent)) / BLOCKSIZE, block);
	memcpy(block + (sizeof(fatent) * fatNum) % BLOCKSIZE,
   	&fatList[fatNum], sizeof(fatent));

	return dwrite(globalvcb.fat_start + (fatNum * sizeof(fatent)) / BLOCKSIZE,
		block);
}



/**
* Set all bytes in the data block at index blockNum to zero
*
* Returns 1 if not sucessful else 0
*/
int zeroDB(int blockNum) {
	char block[BLOCKSIZE];
	memset(block, 0, BLOCKSIZE);
	return dwrite(globalvcb.db_start + blockNum, block) < 0;
}



/**
* Find the first fatent in the list which is not being used.
*
* Return -1 if no such fat or the fat number if there is a fat.
*/
int findEmptyFat() {
	for (int i = 0; i < globalvcb.fat_length; i++)
		if (!fatList[i].used)
			return i;

	return -1;
}



/**
* Make room so that data starting at offset and going size bytes will fit.
*
* Returns 0 if no error, -1 if not enough space.
*/
int makeSpace(dirent *file, size_t size, off_t offset) {
	if (size == 0)
		return 0;

	int newFat;

	if (file->first_block == (unsigned int)-1) {
		if ((newFat = findEmptyFat()) == -1)
			return -1;
		zeroDB(newFat);
		fatent *tempFat = &fatList[newFat];
		tempFat->used = 1;
		tempFat->eof = 1;
		file->first_block = newFat;
		rewriteFat(newFat);
	}

	int currentFat = file->first_block;
	fatent *fat = &fatList[currentFat];

	while (offset + size >= (unsigned int)BLOCKSIZE) {
		if (fat->eof) {
			if ((newFat = findEmptyFat()) == -1)
				return -1;
			zeroDB(newFat);
			fatent *tempFat = &fatList[newFat];
			tempFat->used = 1;
			tempFat->eof = 1;
			fat->eof = 0;
			fat->next = newFat;
			rewriteFat(newFat);
			rewriteFat(currentFat);
		}
		
		currentFat = fat->next;
		offset-=BLOCKSIZE;
		fat = &fatList[currentFat];
	}

	return 0;
}



/*
 * Initialize filesystem. Read in file system metadata and initialize
 * memory structures. If there are inconsistencies, now would also be
 * a good time to deal with that. 
 *
 * HINT: You don't need to deal with the 'conn' parameter AND you may
 * just return NULL.
 *
 */
static void* vfs_mount(struct fuse_conn_info *conn) {
	fprintf(stderr, "vfs_mount called\n");
	// Do not touch or move this code; connects the disk
	dconnect();

	// Reading vcb from disk
	char *tmp = (char *) malloc(BLOCKSIZE);
	memset(tmp, 0, BLOCKSIZE);
	int error;
	if ((error = dread(0, tmp)) < 0) {
	  fprintf(stderr, "Error: %d could not read vcb\n", error);
	  free(tmp);
	  exit(1);
	}

	memcpy(&globalvcb, tmp, sizeof(vcb));
   
	//Checking for our magic number
	if (globalvcb.magic != 1337) {
		fprintf(stderr, "The magic number, %d, did not match!\n", 
			globalvcb.magic);
		free(tmp);
		exit(1); 
	}

	// READ IN DIRENTS
	for (int i = 0; i < NUM_DIR_ENTS; i++) {
	  if ((error = dread(i + 1, tmp)) < 0) {
			fprintf(stderr, "Error: %d could not read dirent %d\n", error, i);
			exit(1);
	  }

	  memcpy(&directoryList[i], tmp, sizeof(dirent));
	}

	// READ IN FATS
	fatList = calloc(globalvcb.fat_length + 1, sizeof(fatent));
	int position = 0;
	int blockNum = globalvcb.fat_start;
	dread(blockNum++, tmp);

	for (int i = 0; i < globalvcb.fat_length; i++, position+=sizeof(fatent)) {
		if (position >= BLOCKSIZE) {
			dread(blockNum++, tmp);
			position = 0;
		}
		memcpy(&fatList[i], tmp + position, sizeof(fatent));
	}

	free(tmp);

	return NULL;
}



/*
 * Called when your file system is unmounted.
 */
static void vfs_unmount (void *private_data) {
  fprintf(stderr, "vfs_unmount called\n");

  free(fatList);
  /* 3600: YOU SHOULD ADD CODE HERE TO MAKE SURE YOUR ON-DISK STRUCTURES
	   ARE IN-SYNC BEFORE THE DISK IS UNMOUNTED (ONLY NECESSARY IF YOU
	   KEEP DATA CACHED THAT'S NOT ON DISK */

  // Do not touch or move this code; unconnects the disk
  dunconnect();
}



/* 
 *
 * Given an absolute path to a file/directory (i.e., /foo ---all
 * paths will start with the root directory of the CS3600 file
 * system, "/"), you need to return the file attributes that is
 * similar stat system call.
 *
 * HINT: You must implement stbuf->stmode, stbuf->st_size, and
 * stbuf->st_blocks correctly.
 *
 */
static int vfs_getattr(const char *path, struct stat *stbuf) {
	fprintf(stderr, "vfs_getattr called\n");

	// Do not mess with this code 
	stbuf->st_nlink = 1; // hard links
	stbuf->st_rdev  = 0;
	stbuf->st_blksize = BLOCKSIZE;

  	/* 3600: YOU MUST UNCOMMENT BELOW AND IMPLEMENT THIS CORRECTLY */
  
  
	if (strcmp(path, "/") == 0) {
		stbuf->st_mode    = 0777 | S_IFDIR;
		stbuf->st_uid     = globalvcb.user;// file uid
		stbuf->st_gid     = globalvcb.group;// file gid
		stbuf->st_atime   = globalvcb.access_time.tv_sec;// access time 
		stbuf->st_mtime   = globalvcb.modify_time.tv_sec;// modify time
		stbuf->st_ctime   = globalvcb.create_time.tv_sec;// create time
		stbuf->st_size    = 0; // file size
		stbuf->st_blocks  = 0;// file size in blocks
		return 0;
	}
	else {
		const char *base = basename((char *)path);

		for (int i = 0; i < NUM_DIR_ENTS; i++) {
			if (strcmp(directoryList[i].name, base) == 0 &&
			 directoryList[i].valid) {
				fprintf(stderr, "Found %s\n", base);
				stbuf->st_mode    = directoryList[i].mode;
				stbuf->st_uid     = directoryList[i].user;// file uid
				stbuf->st_gid     = directoryList[i].group;// file gid
				stbuf->st_atime   = directoryList[i].access_time.tv_sec; 
				stbuf->st_mtime   = directoryList[i].modify_time.tv_sec;
				stbuf->st_ctime   = directoryList[i].create_time.tv_sec;
				stbuf->st_size    = directoryList[i].size; // file size
				stbuf->st_blocks  = (int)ceil((double)directoryList[i].size /
					BLOCKSIZE);// file size in blocks
				return 0;
			}
		}
	}
  
  return -ENOENT;
}



/*
 * Given an absolute path to a directory (which may or may not end in
 * '/'), vfs_mkdir will create a new directory named dirname in that
 * directory, and will create it with the specified initial mode.
 *
 * HINT: Don't forget to create . and .. while creating a
 * directory.
 */
/*
 * NOTE: YOU CAN IGNORE THIS METHOD, UNLESS YOU ARE COMPLETING THE 
 *       EXTRA CREDIT PORTION OF THE PROJECT.  IF SO, YOU SHOULD
 *       UN-COMMENT THIS METHOD.
static int vfs_mkdir(const char *path, mode_t mode) {

  return -1;
} 
*/



/** Read directory
 *
 * Given an absolute path to a directory, vfs_readdir will return 
 * all the files and directories in that directory.
 *
 * HINT:
 * Use the filler parameter to fill in, look at fusexmp.c to see an example
 * Prototype below
 *
 * Function to add an entry in a readdir() operation
 *
 * @param buf the buffer passed to the readdir() operation
 * @param name the file name of the directory entry
 * @param stat file attributes, can be NULL
 * @param off offset of the next entry or zero
 * @return 1 if buffer is full, zero otherwise
 * typedef int (*fuse_fill_dir_t) (void *buf, const char *name,
 *                                 const struct stat *stbuf, off_t off);
 *             
 * Your solution should not need to touch fi
 *
 */
static int vfs_readdir(const char *path, void *buf, fuse_fill_dir_t filler,
					   off_t offset, struct fuse_file_info *fi)
{
	if (strcmp(path, "/") == 0) {
		int count = 0;
		for (int i = 0; i < NUM_DIR_ENTS; i++, count++) {
			if (count < offset);
			else if (directoryList[i].valid && 
				 	filler(buf, directoryList[i].name, NULL, count + 1) != 0)
				return 0;
		}
		return 0;
	}
	else
		return -1;
}



/**
* Given an absolute path to a file (for example /a/b/myFile), vfs_create 
* will create a new file named myFile in the /a/b directory.
*  *path - The path to create
*  mode  - The permissions mode of the new file
*  *fi   - Things???
*
*  Returns -EEXIST if file already exists, -1 if other error, or 0 if success.
*/
static int vfs_create(const char *path, mode_t mode, struct fuse_file_info *fi)
{
	const char *base = basename((char *)path);

	if (direntExists(base))
		return -EEXIST;

	// Find first open dirent
	int i;

	for(i = 0; directoryList[i].valid && i < NUM_DIR_ENTS; i++);

	if(i == NUM_DIR_ENTS)  // TODO: check the right error value
		return -1;

	directoryList[i].valid = 1;
	directoryList[i].first_block = -1;
	directoryList[i].size = 0;
	directoryList[i].user = geteuid();
	directoryList[i].group = getegid();
	directoryList[i].mode = (mode & 0x0000ffff) | S_IFREG;

	struct timespec now;
	clock_gettime(CLOCK_REALTIME, &now);

	directoryList[i].access_time = now;
	directoryList[i].modify_time = now;
	directoryList[i].create_time = now;


	if (strlen(base) < 439)
		strcpy(directoryList[i].name, base);
	else
		return -1;


	if (writeDirent(i) < 0) {
		fprintf(stderr, "Error writing directory: %s\n", path);
		return -1;
	}

	return 0;
}



/*
 * The function vfs_read provides the ability to read data from 
 * an absolute path 'path,' which should specify an existing file.
 * It will attempt to read 'size' bytes starting at the specified
 * offset (offset) from the specified file (path)
 * on your filesystem into the memory address 'buf'. The return 
 * value is the amount of bytes actually read; if the file is 
 * smaller than size, vfs_read will simply return the most amount
 * of bytes it could read. 
 *
 * HINT: You should be able to ignore 'fi'
 *
 */
static int vfs_read(const char *path, char *buf, size_t size, off_t offset,
	struct fuse_file_info *fi) {

	printf("offset: %d\nsize: %d\n", (int)offset, (int)size);
	if (size == 0)
		return 0;

	// Find dirent associated with the path
	int fileIndex = findFile(basename((char *)path));
	if (fileIndex == -1)
		return -1;
	dirent *file = &directoryList[fileIndex];
	fatent *fat;
	int currentFat;

	// Find the first block of the file
	if (file->first_block != (unsigned int)-1) {
		currentFat = file->first_block;
		fat = &fatList[currentFat];
	}
	else // The file is empty 
		return 0;

	// Move through blocks until offset is located in current block
	while (offset >= BLOCKSIZE && !fat->eof) {
		offset -= BLOCKSIZE;
		currentFat = fat->next;
		fat = &fatList[currentFat];
	}

	// Did we hit the eof before reaching the offset?
	if (offset >= BLOCKSIZE) 
		return 0;

	// Read Data blocks
	unsigned int count = 0;
	char block[BLOCKSIZE];
	dread(globalvcb.db_start + currentFat, block);

	while (count < size && count < file->size) {
		if (offset + count >= BLOCKSIZE && !fat->eof) {
			currentFat = fat->next;
			fat = &fatList[currentFat];
			offset-=BLOCKSIZE;
			dread(globalvcb.db_start + currentFat, block);
			printf("Read block %d\n", currentFat);
			//dumpBlock(block);
		}
		else if (offset + count >= BLOCKSIZE && fat->eof)
			return count;

		buf[count] = block[offset + count];
		count++;
	}

  return count;
}



/*
 * The function vfs_write will attempt to write 'size' bytes from 
 * memory address 'buf' into a file specified by an absolute 'path'.
 * It should do so starting at the specified offset 'offset'.  If
 * offset is beyond the current size of the file, you should pad the
 * file with 0s until you reach the appropriate length.
 *
 * You should return the number of bytes written.
 *
 * HINT: Ignore 'fi'
 */
static int vfs_write(const char *path, const char *buf, size_t size,
	off_t offset, struct fuse_file_info *fi) {

	// Find dirent associated with the path
	int fileIndex = findFile(basename((char *)path));
	dirent *file = &directoryList[fileIndex];
	fatent *fat;
	int currentFat;

	if (!file)
		return -1;

	// Add enough fat blocks so everything will fit
	if (makeSpace(file, size, offset) == -1) {
		return -ENOSPC;
	}

    //If the file has a new length, we must update the corresponding
    //directory entry in our cache and update it on the disk as well
	if (offset + size > file->size) {
		file->size = offset + size;
		writeDirent(fileIndex);
	}

    //Keep track of the current FAT entry we are at, starting with the first one
	currentFat = file->first_block;
	fat = &fatList[currentFat];

	// Move to offset block
	while (offset > BLOCKSIZE) {
		currentFat = fat->next;
		fat = &fatList[currentFat];
		offset-=BLOCKSIZE;
	}

	// Read/write Data blocks
	unsigned int count = 0;
	char block[BLOCKSIZE];
	dread(globalvcb.db_start + currentFat, block);

	while (count < size) {
		if (offset + count >= BLOCKSIZE) {
			printf("Writing data block %d\n", currentFat);
			//dumpBlock(block);
			dwrite(globalvcb.db_start + currentFat, block);
			currentFat = fat->next;
			dread(globalvcb.db_start + currentFat, block);
			fat = &fatList[currentFat];
			offset-=BLOCKSIZE;
		}

		block[(offset + count) % BLOCKSIZE] = buf[count];
		count++;
	}

	//dumpBlock(block);
	dwrite(globalvcb.db_start + currentFat, block);
	return count;
}



/*
 * This function will truncate the file at the given offset
 * (essentially, it should shorten the file to only be offset
 * bytes long).
 */
static int vfs_truncate(const char *path, off_t offset) {
	off_t temp = offset;
  				 
	//I have the index within the cached list of directory entries
    //of the file that we are truncating				 
	int fileIndex = findFile(basename((char *)path));
	//If we couldn't find the file, return an error
	if (fileIndex == -1)
		return -1;
	//If it is there, make a pointer to the directory entry	
	dirent *file = &directoryList[fileIndex];
	//If the first block field has a -1, then nothing has been written to
	//it and there is nothing to truncate
	if (file->first_block == (unsigned int)-1 && offset > 0)
		return -1;
	else if (file->first_block == (unsigned int)-1)
		return 0;
    //If the file has been written to, we want to keep track of the FAT entry
    //that we are currently at for this file
	int currentFat = file->first_block;
	fatent *fat = &fatList[currentFat];
	int last = file->first_block;
    //If the offset is zero, then we are in essence deleting everything in file
    //and the first block field should be a -1
	if (offset == 0)
		file->first_block = (unsigned int)-1;
    //If the offset is > 0, then we have to get to the place where the offset is
	while (temp >= (unsigned int)BLOCKSIZE) {
        //If we reach an EOF before getting to the offset we want to truncate at
        //we return an error
		if (fat->eof)
			return -1;
		//Otherwise, we move onto the next FAT entry, in pursuit of the offeset	
		else {
			temp -= BLOCKSIZE;
			last = currentFat;
			currentFat = fat->next;
			fat = &fatList[currentFat];
		}
	}
    //The file's new size is offset, so we update our cached directory entries
	file->size = offset;
	//int last = file->first_block;
	//We update the disk
	writeDirent(fileIndex);
	
    //Free the truncated FAT entries for use
	while (!fat->eof) {
		fat->used = false;
		rewriteFat(last);
		last = fat->next;
		fat = &fatList[fat->next];
	}

	return 0;
}



/**
 * This function deletes the last component of the path (e.g., /a/b/c you 
 * need to remove the file 'c' from the directory /a/b).
 */
static int vfs_delete(const char *path) {
    const char *base = basename((char *)path);

	for (int i = 0; i < NUM_DIR_ENTS; i++)
		//Checking to see if we find the name of the file in our cached list of
		//directory entries
        if (directoryList[i].valid && strcmp(base, directoryList[i].name) == 0) {
            //One way of freeing the FAT entries associated with this file 
            //is to call truncate with offset 0, I also check for an error
            if (vfs_truncate(path, 0) < 0) {
            	printf("Error: Could not truncate.");
               return -1;
            }
            //Now that the file is empty, we make the directory entry invalid,
            //freeing it for future allocation
			directoryList[i].valid = 0;
			
			//Finally, we update the disk, since we changed the cached version.
			//If there is an error updating the disk, we return an error
			if (writeDirent(i) < 0) {
            	fprintf(stderr, "failed to delete %s\n", directoryList[i].name);
            	return -1; //An error occurred with disk
            }

			return 0;
		}

	return -1;
}



/*
 * The function rename will rename a file or directory named by the
 * string 'oldpath' and rename it to the file name specified by 'newpath'.
 *
 * HINT: Renaming could also be moving in disguise
 *
 */
static int vfs_rename(const char *from, const char *to) {
	char *oldname = basename((char *)from);
	char *newname = basename((char *)to);
	
	//First, we need to check if the old file even exists
	if (!direntExists(oldname)) {
		fprintf(stderr, "Rename attempt: File %s did not exist", from);
		return -1;                           
	}
	//Next, we need to see if a file with the same name as the new
	//name already exists and delete it if it does exist
	if (direntExists(newname)) {
	   //If there is an error in deletion, return error
		if (vfs_delete(newname) < 0) {
			fprintf(stderr, "Rename attempt: Error in deleting newname file");   
			return -1;   
		}
	}
	//At this point, we've confirmed that "from" exists and that 
	//a "to" file does not and can therefore now change the name.  
	for (int i = 0; i < NUM_DIR_ENTS; i++) {
		if (directoryList[i].valid &&
			strcmp(directoryList[i].name, oldname) == 0) {
			// Before the string name is changed, we have to make sure the name
			// is not more than 439 chars long (since we have 440 available and
			// need one for null termination)
			if (strlen(newname) > 439) {
				fprintf(stderr, "Newname: the new name is too long!");
				return -1;      
			}            
			//Change the name!            
			strcpy(directoryList[i].name, newname);

			//Before returning success, we have to update disk
			if (writeDirent(i) < 0) {
				fprintf(stderr, "Fail: write disk for dirent%d in rename\n", i);
				return -1;      
			}
			//return success, baby!
			return 0;
		}
	}
}

/*
 * This function will change the permissions on the file
 * to be mode.  This should only update the file's mode.  
 * Only the permission bits of mode should be examined 
 * (basically, the last 16 bits).  You should do something like
 * 
 * fcb->mode = (mode & 0x0000ffff);
 *
 */
static int vfs_chmod(const char *file, mode_t mode)
{
	 // Path has a "/" at the beginning, we take it out
	const char *base = basename((char *)file); 
	
	// Find the file with the right name and update fields
	for (int i = 0; i < NUM_DIR_ENTS; i++) {
		if (directoryList[i].valid &&
			strcmp(directoryList[i].name, base) == 0) {
			directoryList[i].mode = mode;
					  
			//Before returning, update disk
			if (writeDirent(i) < 0) {
				fprintf(stderr, "Fail: write disk for dirent%d for chmod\n", i);
				return -1;      
			}
			//If we are here then the write was succesful and we return success   
			return 0;                           
		}
	} 
	// Couldn't find the file with the given name, so it is an error
	return -1;
}

/*
 * This function will change the user and group of the file
 * to be uid and gid.  This should only update the file's owner
 * and group.
 */
static int vfs_chown(const char *file, uid_t uid, gid_t gid)
{
	// Path has a "/" at the beginning, we take it out
	const char *base = basename((char *)file); 
	
	// Find the file with the right name and update fields or error if no file
	for (int i = 0; i < NUM_DIR_ENTS; i++) {
		if (directoryList[i].valid &&
			strcmp(directoryList[i].name, base) == 0) {
			directoryList[i].user = uid;
			directoryList[1].group = gid;
		   
			// Update disk
			if (writeDirent(i) < 0) {
				fprintf(stderr, "Fail: write disk for dirent%d for chown\n", i);
				return -1;      
			}
			//If we are here then the write was succesful and we return success   
			return 0;                           
		}
	}
	   
	// No file, error 
	return -1;
}




/*
 * This function will update the file's last accessed time to
 * be ts[0] and will update the file's last modified time to be ts[1].
 */
static int vfs_utimens(const char *file, const struct timespec ts[2]) {  
	// path has a "/" at the beginning, we take it out
	const char *base = basename((char *)file);
	//These are the timespec structs
	struct timespec access = ts[0];
	struct timespec modified = ts[1];
	
	// Find the file with the right name and update fields or error if no file
	for (int i = 0; i < NUM_DIR_ENTS; i++) {
		if (directoryList[i].valid &&
			strcmp(directoryList[i].name, base) == 0) {
		   directoryList[i].access_time = access;
		   directoryList[1].modify_time = modified;
		   
			// Update disk
			if (writeDirent(i) < 0) {
				fprintf(stderr, "Fail: writedisk for dirent%d in utimens\n", i);
				return -1;      
			}
			//If we are here then the write was succesful and we return success   
			return 0;                           
		}
	}
	   
	// No file, error 
	return -1;
}



/*
 * You shouldn't mess with this; it sets up FUSE
 *
 * NOTE: If you're supporting multiple directories for extra credit,
 * you should add 
 *
 *     .mkdir    = vfs_mkdir,
 */
static struct fuse_operations vfs_oper = {
	.init    = vfs_mount,
	.destroy = vfs_unmount,
	.getattr = vfs_getattr,
	.readdir = vfs_readdir,
	.create  = vfs_create,
	.read    = vfs_read,
	.write   = vfs_write,
	.unlink  = vfs_delete,
	.rename  = vfs_rename,
	.chmod   = vfs_chmod,
	.chown   = vfs_chown,
	.utimens     = vfs_utimens,
	.truncate    = vfs_truncate,
};



int main(int argc, char *argv[]) {
	/* Do not modify this function */
	umask(0);

	if ((argc < 4) || (strcmp("-s", argv[1])) || (strcmp("-d", argv[2]))) {
		printf("Usage: ./3600fs -s -d <dir>\n");
		exit(-1);
	}

	return fuse_main(argc, argv, &vfs_oper, NULL);
}
