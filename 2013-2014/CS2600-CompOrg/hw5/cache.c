/* Nicholas Jones
 * Computer Organization
 * Problem Set 5
 * 11/8/2013
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

// ============================================================================
// DATA DEFINITIONS
// ============================================================================

// CacheLine represents a single line in a cache.
//   valid: 1 if set correctly or 0 if not.
//   tag: the first n bits from the left of an address
//   *next: Used to divide lines into linked lists based on whether they are used or not.
 typedef struct cacheLine {
  int valid;
  int tag;
  struct cacheLine *next;
} CacheLine;

// Cache represents an entire cache.
//   totalBytes: Total size of the case = numSets * linesPerSet
//   numSets: How many sets of CacheLines are there?
//   linesPerSet: How many lines are in each set
//   bytesPerLine: How many bytes of data are in the block of each line?
//   *lines: An array to all the CacheLines
//   **used: An array to pointers of the most recently used CacheLine of each set.
//   **open: An array to pointers of the next free CacheLine for each set.
typedef struct {
  int totalBytes;
  int numSets;
  int linesPerSet;
  int bytesPerLine;
  CacheLine *lines;
  CacheLine **used;
  CacheLine **open;
} Cache;

// Address represents the Address of a piece of data.
//   tag: The tag of the piece of data
//   set: The number of the set which the data is in.
//   offset: used by the CPU to extact the data from the block it's in.
typedef struct {
  int address;
  int tag;
  int set;
  int offset;
} Address;

// ============================================================================
// MACROS
// ============================================================================

#define length(x) sizeof(x)/sizeof(x[0])

#define dumpCache(x) printf("\n\nsize: %d sets: %d linesPerSet: %d bytesPerLine: %d lines: %p, used: %p, open: %p \n\n", x.totalBytes, x.numSets, x.linesPerSet, x.bytesPerLine, x.lines, x.used, x.open)

#define dumpLine(x) printf("valid: %d, tag: %d, this: %p, next: %p\n\n", x.valid, x.tag, &x, x.next)

#define dumpAddress(x) printf("Address: %2d  -->  Tag: %2d, Set: %2d, Offset: %2d\n", x.address, addr.tag, addr.set, addr.offset);


// ============================================================================
// CONSTANTS
// ============================================================================

#define DEBUGGING true

int test_set[39] = {0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72,
  76, 80, 0, 4, 8, 12, 16, 71, 3, 41, 81, 39, 38, 71, 15, 39, 11, 51, 57, 41};


// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

Cache cache;

// ============================================================================
// FUNCTIONS
// ============================================================================

/* Address interpretAddress(int address)
 * 
 * Converts an integer address into a struct with each part
 * of the address broken apart.
 *
 * addr: address to convert to a struct.
 * 
 * return : An Address where each value is set according to the size of the
 *          cache.
 */
 Address interpretAddress(int address) {
  Address addr;
  int tagSetNum = address / cache.bytesPerLine;

  addr.address = address;
  addr.offset = address % cache.bytesPerLine;
  addr.set = tagSetNum % cache.numSets;
  addr.tag = tagSetNum / cache.numSets;

  return addr;
}

/* void evictCacheLine(int set)
 * 
 * Only call when cache.open[set] is NULL and cache.used[set] != NULL
 *
 * set: The set to evict from.
 *
 * Effect: Takes last member of used linked list and moves to first of open, setting 
 *         valid to false and next values accordingly.
 */
void evictCacheLine(int set) {
  CacheLine *line = cache.used[set];

  while(line->next != NULL && line->next->next != NULL) {
    line = line->next;
  }

  if (line->next == NULL) {
    line->valid = false;
    cache.open[set] = line;
    cache.used[set] = NULL;
  }
  else {
    line->next->next = cache.open[set];
    cache.open[set] = line->next;
    line->next->valid = false;
    line->next = NULL;
  }
}

// FUNCTION:  getFreeCacheLine(int set)
// EXAMPLE USAGE:
//  struct cacheLine * myCacheLine = getFreeCacheLine(set);
//  assert(myCacheLine->valid == 0);
//  mycacheLine->tag = newTagFromCPU;
//  mycacheLine->valid = 1;
CacheLine* getFreeCacheLine(int set) {
  if (cache.open[set] == NULL)
    evictCacheLine(set);
  // Now we know that freeList[set] points to a real cache line
  CacheLine *tmp = cache.open[set];
  //dumpLine((*tmp));
  cache.open[set] = tmp->next; // Now freeList[set] is correct.
  tmp->next = cache.used[set];
  cache.used[set] = tmp; // Now usedList[set] is correct.
  //dumpLine((*tmp));
  return cache.used[set]; // Return a pointer to the cacheLine we took from the free list
}

/* bool hitOrMiss(Address addr)
 *
 * Is the given address in the cache?
 *
 * addr: The address to search for.
 *
 * return: true if in cache, else false
 * effect: if not in cache, adds to cache, possibly evicting old lines with a FIFO policy
 */
bool hitOrMiss(Address addr) {
  int isHit = false;
  int startRow = cache.linesPerSet * addr.set;
  CacheLine *lines = cache.lines;
  int rowIdx;

  for (rowIdx = startRow; rowIdx < startRow + cache.linesPerSet; rowIdx++) {
    //dumpLine(lines[rowIdx]);
    //printf("%d == %d\n",  lines[rowIdx].tag, addr.tag);
    if (lines[rowIdx].valid && lines[rowIdx].tag == addr.tag) {
      isHit = true;
      break;
    }
  }

  if (isHit) return true;

  CacheLine *l = getFreeCacheLine(addr.set);

  l->valid = true;
  l->tag = addr.tag;

  return isHit; // false
}

/* Cache interpCmdArgs(char **argv)
 *
 * Convert command line arguments into a cache
 * args in order: totalBytes, linesPerSet, bytesPerLine
 */
 Cache interpCmdArgs(char **argv) {
  Cache temp;
  int set;
  int index;

  temp.totalBytes = atoi(argv[0]);
  temp.linesPerSet = atoi(argv[1]);
  temp.bytesPerLine = atoi(argv[2]);
  temp.numSets = temp.totalBytes / temp.bytesPerLine / temp.linesPerSet;

  temp.lines = (CacheLine *) malloc(sizeof(CacheLine) * temp.numSets * temp.linesPerSet);
  temp.used = (CacheLine **) malloc(sizeof(CacheLine*) * temp.numSets);
  temp.open = (CacheLine **) malloc(sizeof(CacheLine*) * temp.numSets);

  for (set = 0; set < temp.numSets; set++) {
    temp.open[set] = &(temp.lines[set * temp.linesPerSet]);
    temp.used[set] = NULL;
  }

  for (set = 0; set < temp.numSets; set++) {
    for (index = set*temp.linesPerSet; index < (set+1)*temp.linesPerSet; index++) {
      temp.lines[index].valid = false;
      temp.lines[index].tag = 0;
      temp.lines[index].next = & temp.lines[index+1];
      //dumpLine(temp.lines[index]);
    }
    temp.lines[(set+1)*temp.linesPerSet - 1].next = NULL;
    //dumpLine(temp.lines[(set+1)*temp.linesPerSet - 1]);
  }
  return temp;
}

/*
 * Must have 3 args: totalBytes, linesPerSet, bytesPerLine
 * direct mapped is linesPerSet = 1;
 * fully assoc is linesPerSet = totalByes / bytesPerLine = numLines
 */
 int main(int argc, char **argv) {
  if (argc == 4) {
    cache = interpCmdArgs(argv + 1);
  }
  else {
    exit(1);
  }

  //dumpCache(cache);

  Address addr;
  int i;

  //printf("START\n");

  for (i = 0; i < length(test_set); i++) {
    addr = interpretAddress(test_set[i]);
    //dumpAddress(addr);
    bool isHit = hitOrMiss(addr);
    if (isHit)
      printf("address(%d) Hit\n", test_set[i]);
    else
      printf("address(%d) Miss\n", test_set[i]);
  }

  //printf("END\n\n\n");

  // Free up allocated memory
  free(cache.lines);
  free(cache.open);
  free(cache.used);

  return 0;
}