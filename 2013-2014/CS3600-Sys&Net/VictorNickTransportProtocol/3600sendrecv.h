/*******************************************************************************
*
* Project 4: TCP
* CS3600: Systems and Networks
* 4/23/2014
* Nick Jones, Victor Monterroso
*
* Starter code provided by Prof. Mislove.
*
*******************************************************************************/

#ifndef __3600SENDRECV_H__
#define __3600SENDRECV_H__

#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>
#include <time.h>

typedef struct header_t {
  unsigned int magic:14;
  unsigned int ack:1;
  unsigned int eof:1;
  unsigned short length;
  unsigned int sequence;
  unsigned short checkSum;
} header;

unsigned int MAGIC;    // The magic number, which is specific to this program.
double WINDOW_SIZE;    // size of window in packets
unsigned int SS_THRES; // SS_THRESHOLD in packets
unsigned long TIMEOUT; // TIMEOUT VALUE IN microSeconds

void dump_packet(unsigned char *data, int size);
header *make_header(int sequence, int length, int eof, int ack, 
  unsigned short checkSum);
header *get_header(void *data);
char *get_data(void *data);
char *timestamp();
void mylog(char *fmt, ...);


/*******************************************************************************
*
* PacketQueue
* Header of queue for keeping track of sent packet information
* Nick Jones, Victor Monterroso
* 4/1/2014
*
*******************************************************************************/

struct PacketEnt_t;

/**
* PacketQueue is the head of the queue
*
* size  - The number of elements in the queue
* first - The first element of the queue
* last  - The last element of the queue
*/
typedef struct PacketQueue_t {
    unsigned int size;
    struct PacketEnt_t *first;
    struct PacketEnt_t *last;
} PacketQueue;

/**
* PacketEnt is a single entry in the queue
*
* timeSent       - The time the packet was last sent
* sequenceNumber - The sequence number of the packet
* data           - The pointer to the data of the packet (including the header)
* dataSize       - The number of bytes of data in data
* acked          - Has this packet been acked?
* prev           - The packet sent before this one, null if first in queue
* last           - The packet sent after this one, null if last in queue
*/
typedef struct PacketEnt_t {
    struct timeval timeSent;
    unsigned int sequenceNumber;
    char *data;
    unsigned int dataSize;
    bool acked;
    struct PacketEnt_t *prev;
    struct PacketEnt_t *next;
    bool ignored;
} PacketEnt;

// FUNCTIONS

PacketQueue *makeQueue();
bool isFull(PacketQueue *queue);
void removeFirst(PacketQueue *queue);
bool removeAckedFront(PacketQueue *queue);
void setEnt(PacketEnt *ent, unsigned int sequenceNum, char *data, 
  unsigned int dataSize);
int addEnt(PacketQueue *queue, unsigned int sequenceNum, char *data, 
  unsigned int dataSize);
void ackEnt(PacketQueue *queue, unsigned int sequenceNum);
bool isTimedOut(PacketEnt *ent);
PacketEnt *getFirstExpiredPacket(PacketQueue *queue);
void addInOrder(PacketQueue *pack, unsigned int sequenceNumber, char *data, 
  unsigned int dataSize);
bool inQueue(PacketQueue *pack, unsigned int sequenceNumber);
void flushQueue(PacketQueue *pack, unsigned int *globalseq);
unsigned short checkSum (unsigned short * addr, int count);

void printQueue(PacketQueue *q);
long manageTIMEOUT(struct timeval *start);

#endif

