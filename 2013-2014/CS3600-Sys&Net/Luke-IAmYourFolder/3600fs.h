/*
 * CS3600, Spring 2014
 * Project 2: FAT Filesystem
 * Author: Nick Jones, Victor Monterosso
 * Version: 3/10/2014
 * 
 * This header file contains the data definitions for using our FAT filesystem.
 * Modified from starter code provided my Alan Mislove.
  * See project handout for more details.
 */

#ifndef __3600FS_H__
#define __3600FS_H__

#define NUM_DIR_ENTS 100

/**
* The Volume Control Block Struct represents the file system information.
* It also contains the root directory information.
*/
typedef struct vcb_s {
    int magic; // a magic number to identify our disk

    // description of the disk layout
    int blocksize;  // How many bytes are in a block?
    int de_start;   // What is the index of the first dirent block?
    int de_length;  // How many dirents are there?
    int fat_start;  // What is the findex of the first fatent block?
    int fat_length; // How many fat blocks are there?
    int db_start;   // What is the index of the first data block?

    // Metadata for the root directory
    uid_t user;  // Root user
    gid_t group; // Root Group
    mode_t mode; // Root Permissions
    struct timespec access_time;
    struct timespec modify_time;
    struct timespec create_time;
} vcb;


/**
* Directory Entry struct represents a single directory entry (file).
*/
typedef struct dirent_s {
    unsigned int valid;       // Is the file in use?
    unsigned int first_block; // What is the first fat block?
    unsigned int size;        // How many bytes are in this file?
    uid_t user;               // Who is the user
    gid_t group;              // What is the group
    mode_t mode;              // What is the permissions of the file
    struct timespec access_time;
    struct timespec modify_time;
    struct timespec create_time;
    char name[440];
} dirent;


/**
* FAT Entry struct represents a section of data inside a file.  Fatent n
* represents the link information for data block n.
*/
typedef struct fatent_s {
    unsigned int used:1;  // Is this fat being used?
    unsigned int eof:1;   // Is this fat the end of a file?
    unsigned int next:30; // What is the next block in the file?
} fatent;

#endif
