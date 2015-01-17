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

#include <math.h>
#include <ctype.h>
#include <time.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "3600sendrecv.h"

unsigned int MAGIC = 0x0cab;
double WINDOW_SIZE = 1.0;
unsigned int SS_THRES = 100;
unsigned long TIMEOUT = 1000000L;
bool DEBUG = false;
bool PRINT = true;

char ts[16];


/**
 * Returns a properly formatted timestamp
 */
char *timestamp() {
  time_t ltime;
  ltime=time(NULL);
  struct tm *tm;
  tm=localtime(&ltime);
  struct timeval tv1;
  gettimeofday(&tv1, NULL);

  sprintf(ts,"%02d:%02d:%02d %03d.%03d", tm->tm_hour, 
                                         tm->tm_min, 
                                         tm->tm_sec,
                                         (int) (tv1.tv_usec/1000),
                                         (int) (tv1.tv_usec % 1000));
  return ts;
}

/**
 * Logs debugging messages.  Works like printf(...)
 */
void mylog(char *fmt, ...) {
  if (PRINT || DEBUG) {
    va_list args;
    va_list args_cp;
    va_start(args,fmt);

    if (PRINT)
      va_copy(args_cp, args);

    if (DEBUG) {
      FILE *fd = (FILE *)fopen("log.txt", "a");
      if (fd == NULL) {
        perror("no file");
        exit(1);
      }
      fprintf(fd, "%s: ", timestamp());
      vfprintf(fd, fmt, args);
      va_end(args);
      fclose(fd);
    }
        
    if (PRINT) {
      fprintf(stderr, "%s: ", timestamp());
      vfprintf(stderr, fmt, args_cp);
      va_end(args_cp);
    }
  }
}

/**
 * This function takes in a bunch of header fields and 
 * returns a brand new header.  The caller is responsible for
 * eventually free-ing the header.
 */
header *make_header(int sequence, int length, int eof, int ack, unsigned short checkSum) {
  header *myheader = (header *) malloc(sizeof(header));
  myheader->magic = MAGIC;
  myheader->eof = eof;
  myheader->sequence = htonl(sequence);
  myheader->length = htons(length);
  myheader->ack = ack;
  myheader->checkSum = htons(checkSum);

  return myheader;
}

/**
 * This function takes a returned packet and returns a header pointer.  It
 * does not allocate any new memory, so no free is needed.
 */
header *get_header(void *data) {
  header *h = (header *) data;
  h->sequence = ntohl(h->sequence);
  h->length = ntohs(h->length);
  h->checkSum = ntohs(h->checkSum);

  return h;
}

/**
 * This function takes a returned packet and returns a pointer to the data.  It
 * does not allocate any new memory, so no free is needed.
 */
char *get_data(void *data) {
  return (char *) data + sizeof(header);
}

/**
 * This function will print a hex dump of the provided packet to the screen
 * to help facilitate debugging.  
 *
 * DO NOT MODIFY THIS FUNCTION
 *
 * data - The pointer to your packet buffer
 * size - The length of your packet
 */
void dump_packet(unsigned char *data, int size) {
    unsigned char *p = data;
    unsigned char c;
    int n;
    char bytestr[4] = {0};
    char addrstr[10] = {0};
    char hexstr[ 16*3 + 5] = {0};
    char charstr[16*1 + 5] = {0};
    for(n=1;n<=size;n++) {
        if (n%16 == 1) {
            /* store address for this line */
            snprintf(addrstr, sizeof(addrstr), "%.4x",
               ((unsigned int)(intptr_t) p-(unsigned int)(intptr_t) data) );
        }
            
        c = *p;
        if (isalnum(c) == 0) {
            c = '.';
        }

        /* store hex str (for left side) */
        snprintf(bytestr, sizeof(bytestr), "%02X ", *p);
        strncat(hexstr, bytestr, sizeof(hexstr)-strlen(hexstr)-1);

        /* store char str (for right side) */
        snprintf(bytestr, sizeof(bytestr), "%c", c);
        strncat(charstr, bytestr, sizeof(charstr)-strlen(charstr)-1);

        if(n%16 == 0) { 
            /* line completed */
            printf("[%4.4s]   %-50.50s  %s\n", addrstr, hexstr, charstr);
            hexstr[0] = 0;
            charstr[0] = 0;
        } else if(n%8 == 0) {
            /* half line: add whitespaces */
            strncat(hexstr, "  ", sizeof(hexstr)-strlen(hexstr)-1);
            strncat(charstr, " ", sizeof(charstr)-strlen(charstr)-1);
        }
        p++; /* next byte */
    }

    if (strlen(hexstr) > 0) {
        /* print rest of buffer if not empty */
        printf("[%4.4s]   %-50.50s  %s\n", addrstr, hexstr, charstr);
    }
}


/*******************************************************************************
*
* PacketQueue
* Implementation of queue for keeping track of sent packet information
* Nick Jones, Victor Monterroso
* 4/1/2014
*
*******************************************************************************/

long getTimeDiff(struct timeval *start, struct timeval *finish) {
  return ((finish->tv_sec - start->tv_sec) * 1000000L + finish->tv_usec) - start->tv_usec;
}


long manageTIMEOUT(struct timeval *start) {
  struct timeval *now = malloc(sizeof(struct timeval));
  gettimeofday(now, NULL);
  long estRTT = getTimeDiff(start, now);
  TIMEOUT = TIMEOUT * .75 + estRTT * .25 * 2;
  return estRTT;
}

/*
 * This function will return a pointer to a queue of packet entries
 */
PacketQueue *makeQueue() {
    PacketQueue *queue = (PacketQueue *)malloc(sizeof(PacketQueue));

    queue->first = NULL;
    queue->last = NULL;
    queue->size = 0;

    return queue;
}

/*
 * Is the queue full? This is a valid question because since we want a window of
 * a specific size, we want to make sure we aren't sending any more packets than
 * our window size allows.
 */
bool isFull(PacketQueue *queue) {
    return queue->size >= WINDOW_SIZE;
}

/*
 * This will remove the first packet entry from the queue
 */
void removeFirst(PacketQueue *queue) {
    if (queue->first) {
        PacketEnt *ent = queue->first;
        queue->first = queue->first->next; // set second as first

        if (queue->first)
            queue->first->prev = NULL; // make previous of old second NULL
        else
            queue->last = NULL; // empty list

        free(ent->data); //free memory allocated to packet itself
        free(ent);

        //mylog("finished removing first\n");
        queue->size--;
    }
}

void printQueue(PacketQueue *queue) {
  mylog("PACKET QUEUE:\n");
  PacketEnt *ent = queue->first;
  while (ent) {
    mylog("Ent %d @ %p:\n", ent->sequenceNumber, ent);
    mylog("\tsent@: %d\n", ent->timeSent);
    mylog("\tdata ptr: %p\n", ent->data);
    mylog("\tsize: %d\n", ent->dataSize);
    mylog("\tacked?: %s\n", ent->acked ? "true" : "false");
    mylog("\tprev: %p\n", ent->prev);
    mylog("\tnext: %p\n", ent->next);
    ent = ent->next;
  }
}

/*
 * This function will remove the first k entries in the front that have been 
 * acknowledged. This is very helpful since it is analogous to determining how
 * much to move our window by.
 */
bool removeAckedFront(PacketQueue *queue) {
    bool removedFront = false;
    //printQueue(queue);
    while (queue->first && queue->first->acked) {
        mylog("removed %d\n", queue->first->sequenceNumber);
        removedFront = true;
        removeFirst(queue);
        //mylog("%d packets in queue\n", queue->size);
    }

    return removedFront;
}

/*
 * This function sets the fields for a packet entry.
 */
void setEnt(PacketEnt *ent, unsigned int sequenceNum, char *data, unsigned int dataSize) {
    gettimeofday(&(ent->timeSent), NULL);
    ent->sequenceNumber = sequenceNum;
    ent->acked = false;
    ent->data = data;
    ent->ignored = false;
    ent->dataSize = dataSize;
}

/*
 * This function will add a packet entry into the queue.
 */
int addEnt(PacketQueue *queue, unsigned int sequenceNum, char *data, unsigned int dataSize) {
    if (!isFull(queue)) {
        PacketEnt *ent = malloc(sizeof(PacketEnt));
        setEnt(ent, sequenceNum, data, dataSize);

        if (queue->last) { // list not empty
            queue->last->next = ent;
            ent->prev = queue->last;
            ent->next = NULL;
            queue->last = ent;
        }
        else { // list is empty
            queue->first = ent;
            queue->last = ent;
            ent->next = NULL;
            ent->prev = NULL;
        }

        queue->size++;
        return 0;
    }
    else // queue full
        return 1;
}

/*
 * Has the time given for an acknowledgement for a sent packet timed out
 */
bool isTimedOut(PacketEnt *ent) {
    struct timeval t;
    gettimeofday(&t, NULL);
    struct timeval sent = ent->timeSent;
    double timeWaited = getTimeDiff(&sent, &t);
    //mylog("%d has waited: %f / %ld usec\n", ent->sequenceNumber, timeWaited, TIMEOUT);
    return timeWaited >= (double)TIMEOUT;
}

//Receiver functions

/*
 * Is this packet enqueued already?
 */
bool inQueue(PacketQueue *pack, unsigned int seq) {
     //If the queue is empty, return false
     if (pack->size == 0) {
        return false;
     }
     //If the queue is non-empty, given that it is in order, we look to see
     //if the given sequence number is in the queue
     else {
        PacketEnt *ent = pack->first; 
        //Loop until we hit a sequence number greater than input 
        while (ent->sequenceNumber <= seq) {
           if (ent->sequenceNumber == seq) {
              return true;
           }
           ent = ent->next;   
        }  
        return false;  
     } //end of else     
} 

/*
 * This will add a packet entry in a queued list for the receiver in 
 * order by sequence number
 */
void addInOrder(PacketQueue *pack, unsigned int seq, char *data, unsigned int dataSize) {
     PacketEnt *ent = malloc(sizeof(PacketEnt));
     setEnt(ent, seq, data, dataSize);  
     
     //The original first element
     PacketEnt *oldEnt = pack->first;
     
     //Check to see if the list is empty
     if (pack->size == 0) {
        pack->first = ent;
        pack->last = ent;
        ent->prev = NULL;
        ent->next = NULL;
        pack->size++;
        return;
     }
     //Is this new entry the smallest and the new head?
     else if (seq < oldEnt->sequenceNumber) {
        pack->first = ent; 
        ent->prev = NULL; 
        ent->next = oldEnt; 
        oldEnt->prev = ent; 
        pack->size++;
        return;  
     }
     //Else the new entry is either between two entries or the last one
     else {
        while (oldEnt != NULL) {
            //If I hit an element with a sequence number bigger than me, 
            //I must be inserted before it
            if (oldEnt->sequenceNumber > seq) {
               PacketEnt *before = oldEnt->prev;
               ent->next = oldEnt;
               ent->prev = before;
               oldEnt->prev = ent;
               before->next = ent;
               pack->size++;
               return;                                
            }
            //If I hit the end, I am the last element
            if (oldEnt->next == NULL) {
               oldEnt->next = ent; //ent is the new end
               ent->next = NULL;
               ent->prev = oldEnt;
               pack->last = ent;
               pack->size++;
               return;
            }  
         oldEnt = oldEnt->next;     
        }   
     }
}

/*
 * This will flush all ordered packets into standard output and will return the
 * sequence number of the next expected ordered packet
 */
void flushQueue(PacketQueue *pack, unsigned int *globalseq) {
    //Get the first entry in the queue, or null if there is none  
    PacketEnt *ent = pack->first;

    //While the queue is non-empty and the packets that are queued are
    //consecutive, write them to standard output and remove them
    while (ent != NULL) {
        if (ent->sequenceNumber == *globalseq) {
            //Write the data to standard output
            //header *myheader = get_header(ent->data);
            char *info = get_data(ent->data);
            mylog("Writing data for block: %u\n", ent->sequenceNumber);
            write(1, info, ent->dataSize);
            //update new expected sequence number
            (*globalseq)++;
            //remove first
            removeFirst(pack);
            //set the new ent
            ent = pack->first;
        }
        else
            break;
    } // end of while

    mylog("Flushed until: %d\n", *globalseq);
}

//Checksum method
unsigned short checkSum (unsigned short * addr, int count) {
    unsigned long sum = 0;

    while (count > 1) {
        sum += *addr++;
        count -= 2;
    }

    // Add left-over byte, if any
    if (count > 0)
        sum += * (unsigned char *) addr;

    while (sum >> 16)
        sum = (sum & 0xffff) + (sum >> 16);

    return (unsigned short)sum;
}
