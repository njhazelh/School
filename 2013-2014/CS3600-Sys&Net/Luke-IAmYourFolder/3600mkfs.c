/*
 * CS3600, Spring 2014
 * Project 2: FAT Filesystem
 * Author: Nick Jones, Victor Monterosso
 * Version: 3/10/2014
 * 
 * This file contains the implementation for formating our FAT filesystem.
 * Modified from starter code provided my Alan Mislove.
 * See project handout for more details.
 */

#include <unistd.h>
#include <math.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>

#include "3600fs.h"
#include "disk.h"


/**
* Sets up the data structures on the disk.
*  size - The number of blocks in this filesystem.
*/
void myformat(int size) {
  // Do not touch or move this function
  dcreate_connect();

  if (size < 1000) {
    fprintf(stderr, "%s\n", "Error: Not enough blocks");
    exit(1);
  }

  size *= BLOCKSIZE;

  // first, create a zero-ed out array of memory  
  char *tmp = (char *) malloc(BLOCKSIZE);

  int numFat = (size - 1 - NUM_DIR_ENTS) * 128.0 / 129.0;

  // Make the VCB
  vcb myvcb;
  myvcb.magic = 1337;
  myvcb.blocksize = BLOCKSIZE;
  myvcb.de_start = 1;
  myvcb.de_length = NUM_DIR_ENTS; // 100 files supported, as required in proj.
  
  myvcb.fat_start = 1 + NUM_DIR_ENTS;
  myvcb.fat_length = numFat;
  myvcb.db_start = 1 + NUM_DIR_ENTS + (int)ceil(numFat / 128.0);

  myvcb.user = getuid();
  myvcb.group = getgid();
  myvcb.mode = 0777;

  struct timespec now;
  clock_gettime(CLOCK_REALTIME, &now);

  myvcb.access_time = now;
  myvcb.modify_time = now;
  myvcb.create_time = now;

  // Write the vcb
  memcpy(tmp, &myvcb, sizeof(vcb));
  fprintf(stderr, "The magic number of vcb is: %d\n", myvcb.magic);

  if (dwrite(0, tmp) < 0) {
    perror("Error while writing to disk");
    exit(1);
  }

  // Make a Directory Entry
  dirent de;
  de.valid = 0;
  de.first_block = -1;
  de.size = 0;
  de.user = 0;
  de.group = 0;
  de.mode = 0;

  for (int i = 0; i < 440; i++)
    de.name[i] = '\0';

  memcpy(tmp, &de, sizeof(dirent));
  for (int i = 0; i < NUM_DIR_ENTS; i++)
  if (dwrite(i + 1, tmp) < 0) {
    perror("Error while writing to disk");
    exit(1);
  }

  // Make a FAT
  fatent fat;
  fat.used = 0;
  fat.eof = 0;
  fat.next = 0;

  for (int i = 0; i < numFat; i++) {
    memcpy(tmp + 4 * i % 128, &fat, sizeof(fatent));

    if ((i + 1) % 128 == 0)
      if (dwrite(1 + NUM_DIR_ENTS + (i + 1) / 128, tmp) < 0) {
        perror("Error while writing to disk");
        exit(1);
      }
  }

  free(tmp);
  
  // Do not touch or move this function
  dunconnect();
}



/**
* Entry Point
*/
int main(int argc, char** argv) {
  // Do not touch this function
  if (argc != 2) {
    printf("Invalid number of arguments \n");
    printf("usage: %s diskSizeInBlockSize\n", argv[0]);
    return 1;
  }

  unsigned long size = atoi(argv[1]);
  printf("Formatting the disk with size %lu \n", size);
  myformat(size);
}
