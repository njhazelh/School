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
#include <stdbool.h>

#include "3600sendrecv.h"

static int DATA_SIZE = 1500;

// CONNECTION INFO
int sock;
struct sockaddr_in out;
struct sockaddr_in in;
fd_set socks;

// TCP INFO
PacketQueue *packetQueue;
unsigned int sequenceNum = 0;
bool noPackets = false;
unsigned int lastAck = 0;
int dupAcks = 0;


/**
* The usage hint.
*/
void usage() {
  printf("Usage: 3600send host:port\n");
  exit(1);
}


/**
 * Reads the next block of data from stdin
 *
 * *data - pointer to fill with data
 * size - the amount of data to read.
 */
int get_next_data(char *data, int size) {
  return read(0, data, size);
}

/**
 * Builds and returns the next packet, or NULL
 * if no more data is available.
 *
 * sequenceNum - The sequence number of the packet
 * *len        - output variable for the size of the packet.
 *
 * returns a pointer to the packet or null if there is no data left.
 */
void *get_next_packet(int sequenceNum, int *len) {
  char *data = malloc(DATA_SIZE);
  int data_len = get_next_data(data, DATA_SIZE - sizeof(header));

  if (data_len == 0) {
    free(data);
    return NULL;
  }

  unsigned short check = checkSum((unsigned short*)data, data_len);
  header *myheader = make_header(sequenceNum, data_len, 0, 0, check);
  
  void *packet = malloc(sizeof(header) + data_len);
  memcpy(packet, myheader, sizeof(header));
  memcpy(((char *) packet) + sizeof(header), data, data_len);

  *len = sizeof(header) + data_len;
  mylog("The data_len for packet %d is:%d \n", 
    sequenceNum, data_len + sizeof(header));
  mylog("The checksum of packet %d, with length %d, is: %hu\n", sequenceNum, 
    data_len + sizeof(header), check);
  mylog("HTONS CHECKSUM SENDER: %hu,\n", myheader->checkSum);
  
  free(data);
  free(myheader);
  return packet;
}


/**
* Is seq a valid sequence number to ack
*
* seq - The sequence number to check.
*
* Returns true if this sequence number - 1 matches an ent in the queue.
*/
bool valid_ack_sequence(unsigned int seq) {
    PacketEnt *ent = packetQueue->first;

    while (ent) {
        if (ent->sequenceNumber + 1 == seq)
            return true;
        else
            ent = ent->next;
    }

    return false;
}



/**
* Send enough packets to fill the queue or exhaust stdin.
*
* sock - socket number to send packets on
* out  - socket address to send packets on
*
* Returns 1 if there is data left in stdin, else 0
*/
int send_next_packets(int sock, struct sockaddr_in out) {
  int packet_len = 0;
  void *packet = NULL;

  while (!isFull(packetQueue)) {
    packet = get_next_packet(sequenceNum, &packet_len);

    if (packet == NULL) {
      mylog("get_next_packet got NULL packet\n");
      noPackets = true;
      return 0;
    }

    mylog("[send data] %d (%d)\n", sequenceNum, packet_len - sizeof(header));

    int result = sendto(sock,
                        packet,
                        packet_len,
                        0,
                        (struct sockaddr *) &out,
                        (socklen_t) sizeof(out));

    if (result < 0) {
      perror("sendto");
      mylog("error sending packet in send_next_packets\n");
      exit(1);
    }

    //Add the packet to the queue in case we need to retransmit it later
    addEnt(packetQueue, sequenceNum, packet, packet_len);
    mylog("old sequenceNum is %d\n", sequenceNum);
    sequenceNum++;
    mylog("new sequenceNum is %d\n", sequenceNum);
  }

  return 1;
}



/**
* Send the final packet to close the connection
*
* sock - The socket number
* out  - The socket address for sending packets.
*/
void send_final_packet(int sock, struct sockaddr_in out) {
    header *myheader = make_header(sequenceNum, 0, 1, 0, 0);
    mylog("[send eof]\n");

    int result = sendto(sock,
                        myheader, 
                        sizeof(header),
                        0,
                        (struct sockaddr *) &out, 
                        (socklen_t) sizeof(out));

    if (result < 0) {
        perror("sendto");
        mylog("[error] sendto in send_final_packet\n");
        exit(1);
    }
}




/**
* Increase the window size by 1
* This will double the window size each time a full window of packets is acked.
*/
void slowstartIncrease() {
    // increase by 1 for each ack
    mylog("increasing window: ss increase\n");
    WINDOW_SIZE++;
}




/**
* increase for when in congestion avoidance mode
* Increase the window size by 1 / WINDOW SIZE
* After a window of packets have been acked, this will increase the window by 1
*/
void congestionAvoidIncrease() {
    // increase by 1/WINDOW_SIZE for each ack
    mylog("increasing window: congestion increase\n");
    WINDOW_SIZE += 1.0 / (int)WINDOW_SIZE;
}



/*
 * This method determines the appropriate way to increase the window size based
 * on whether we have reached the slow start threshold or not.
 */
void increaseWindow() {
    if (WINDOW_SIZE > SS_THRES)
        congestionAvoidIncrease();
    else
        slowstartIncrease();
}



/*
 * This is a response to congestion, which includes multiplicative decrease
 * and a new slow start threshold
 */
void congestionAvoidTimeout() {
    mylog("performing ca timeout\n");
    WINDOW_SIZE = WINDOW_SIZE / 2.0 + 1.0;
    SS_THRES = (int)WINDOW_SIZE;
}



/**
* Timeout performed in slow start mode
* Set SS_THRES to half the current window size
* Set WINDOW_SIZE to 1
*/
void ssTimeout() {
    mylog("performing ss timeout\n");
    SS_THRES = (int)(WINDOW_SIZE / 2.0) + 1;
    WINDOW_SIZE = 1.0;
}



/**
* Resend a packet.
* 
* *ent - the PacketEnt containing the data to resend
* sock - the socket number
* out  -  the output socket address
*/
void resendEnt(PacketEnt *ent, int sock, struct sockaddr_in out) {
    mylog("resending packet %d\n", ent->sequenceNumber);

    // send packet
    int sendResult = sendto(sock, 
                            ent->data,
                            ent->dataSize,
                            0,
                            (struct sockaddr *) &out,
                            (socklen_t) sizeof(out));

    // Check for errors sending
    if (sendResult < 0) {
        perror("sendto");
        mylog("[error] sendto in resend packet %d\n", ent->sequenceNumber);
        exit(1);
    }

    // Change timeSent to now.
    gettimeofday(&(ent->timeSent), NULL);
}



/**
* Resend all packets that have sat around for more than TIMEOUT
* 
* sock - The socket number
* out  - The socket address
*/
void resendExpired(int sock, struct sockaddr_in out) {
    PacketEnt *ent = packetQueue->first;

    for (int i = 0; i < WINDOW_SIZE && ent; i++, ent = ent->next)
        if (isTimedOut(ent))
            resendEnt(ent, sock, out);
}



/**
* perform the appropriate timeout
*
* sock - The socket number to send packets on
* out  - The socket address to send packets to.
*/
void timeout(int sock, struct sockaddr_in out) {
    // manage time out stuff here
    mylog("TIMEOUT in send\n");

    if (WINDOW_SIZE > SS_THRES)
        congestionAvoidTimeout();
    else
        ssTimeout();

    //ignoreEnts(packetQueue);
    resendExpired(sock, out);
}



/**
* Resend the first packet in the queue.
*
* sock - The socket number to send packets on
* out  - The socket address to send packets to.
*/
void resendFirstPacket(int sock, struct sockaddr_in out) {
    PacketEnt *ent = packetQueue->first;
    mylog("resending packet %d\n", ent->sequenceNumber);

    // send packet
    int sendResult = sendto(sock, 
                            ent->data,
                            ent->dataSize,
                            0,
                            (struct sockaddr *) &out,
                            (socklen_t) sizeof(out));

    // Check for errors sending
    if (sendResult < 0) {
        perror("sendto");
        mylog("[error] sendto in resend first packet\n");
        exit(1);
    }

    // Change timeSent to now.
    gettimeofday(&(ent->timeSent), NULL);
}



/**
* manageNewAck removes all the items in the queue that are before the sequence
* number of this packet.  It also increases the window size and sends enough new
* packets to fill the window.
*
* *myheader - the header of the packet.
* sock      - The socket number to send packets on
* out       - The socket address to send packets to.
*/
void manageNewAck(header *myheader, int sock, struct sockaddr_in out) {
    PacketEnt *ent = packetQueue->first;

    mylog("[recv ack] new ack %d\n", myheader->sequence);
    
    if (ent && ent->sequenceNumber == myheader->sequence - 1) {
        long estRTT = manageTIMEOUT(&(ent->timeSent));
        mylog("RTT for %d was %lu\n", myheader->sequence, estRTT);
    }

    while (ent && ent->sequenceNumber <= myheader->sequence - 1) {

        mylog("removed %d from queue\n", packetQueue->first->sequenceNumber);
        removeFirst(packetQueue);
        increaseWindow();
        send_next_packets(sock, out);
        ent = packetQueue->first;
    }

    lastAck = myheader->sequence;
}



/**
* Is the sequence number of this packet the same as lastAck?
*
* *myheader - The header of the packet
*
* Returns true if the packet has the same sequence number as the last packet
* received.
*/
bool isDupAck(header *myheader) {
    return myheader->sequence == lastAck;
}



/**
* Is this the 3rd duplicate ack in a row?
*
* *myheader - The header of the packet
*
* returns true iff the packet is the third packet in a row that is a duplicate.
*/
bool is3rdDupAck(header *myheader) {
    return isDupAck(myheader) && dupAcks == 2;
}



/**
* manageDupAck checks to see if this packet is the 3rd duplicate packet in a row
*
* if it is, then it resends the sequence number needed
* 
* if it is not, then it increments the number of times that we have had a 
* duplicate ack in a row.
*
* sock - the socket number to send packets over
* out  - the socket address to send packets to.
* *myheader - The header of the packet.
*
* Returns true if the packet is the 3rd duplicate in a row, else false
*/
bool manageDupAck(int sock, struct sockaddr_in out, header *myheader) {
    if (is3rdDupAck(myheader)) {
        resendFirstPacket(sock, out);
        dupAcks++;
        return true;
    }
    else{
        dupAcks++;
        mylog("[recv ack] #%d duplicate of ack %d\n", dupAcks, lastAck);
        return false;
    }
}



/**
* Is the sequence number of this packet greater than lastAck, meaning that we
* have not already acked it?
*
* *myheader - the header of the packet
*
* Returns true iff the packet has not been acked yet.
*/
bool isNewAck(header *myheader) {
    return myheader->sequence > lastAck;
}



/**
* Does this packet have valid MAGIC, sequence, (and checksum TODO) values?
*
* *myheader - The header of the packet
*
* Returns true if the packet has the right magic number and a sequence number
* thast matches one in the queue.
*/
bool isValidPacket(header *myheader) {
    return myheader->magic == MAGIC && valid_ack_sequence(myheader->sequence);
}



/**
* Receive a packet.
*
* sock  - the socket number to receive packets on
* socks - The fd_set thing??
* in    - The socket address to get packets from.
*
* Returns a the memory address of the packet if it gets a packet.
* If it times out, it returns false.
*/
void *receiveAck(int sock, fd_set socks, struct sockaddr_in in, 
    struct sockaddr_in out, struct timeval *t) {

    FD_ZERO(&socks);
    FD_SET(sock, &socks);

    if (select(sock + 1, &socks, NULL, NULL, t)) {
        int buf_len = 1500;
        void *buf = malloc(buf_len);
        socklen_t in_len = sizeof(in);

        int received = recvfrom(sock, 
                                buf, 
                                buf_len, 
                                0, 
                                (struct sockaddr *) &in, 
                                (socklen_t *) &in_len);

        if (received < 0) {
            perror("recvfrom in send");
            mylog("[error] recvfrom in receiveAck in send\n");
        }

        mylog("received packet\n");
        return buf;
    }
    else {
        mylog("timeout in receive ack\n");
        timeout(sock, out);
        return NULL;
    }
}



/**
* This is the loop where TCP does it's magic.
* As packets come in, the window increases, and packets go out.
* If there is a timeout, meaning that packets don't come in fast enough, then
* the window size is decreased.
*
* sock  - The socket number to recieve packets over
* socks - The fd_set thing???
* in    - The socket for getting packets.
* out   - The socket for sending packets.
*/
void recvSendLoop(int sock, fd_set socks, struct sockaddr_in in, 
    struct sockaddr_in out) {

    bool saw3Dup = false;
    unsigned int startSeq = lastAck;
    unsigned int startWindow = WINDOW_SIZE;

    // construct the timeout
    struct timeval *t = (struct timeval *) malloc(sizeof(struct timeval));
    t->tv_sec = 0;
    t->tv_usec = TIMEOUT;

    while (packetQueue->size > 0) {
        mylog("WINDOW: %f\tqueue size: %d\tTIMEOUT: %lu\tSS_THRES: %d\n", 
            WINDOW_SIZE, packetQueue->size, TIMEOUT, SS_THRES);
        mylog("lastAck: %d dupAcks: %d\n", lastAck, dupAcks);
        mylog("send waiting for acks: %d sec %d usec\n", t->tv_sec, t->tv_usec);
        //printQueue(packetQueue);
        void *packet = receiveAck(sock, socks, in, out, t);
        
        if (lastAck == startSeq + startWindow) {
            t->tv_sec = 0;
            t->tv_usec = TIMEOUT;
            startSeq = lastAck;
            startWindow = WINDOW_SIZE;
        }

        if (packet == NULL)
            continue;

        header *myheader = get_header(packet);
        mylog("[recv ack] %d\n", myheader->sequence);

        if (isValidPacket(myheader)) {
            if (isNewAck(myheader)) {
                manageNewAck(packet, sock, out);
                saw3Dup = false;
                lastAck = myheader->sequence;
                dupAcks = 0;
            }
            else if (isDupAck(myheader) && !saw3Dup)
                saw3Dup = manageDupAck(sock, out, myheader);
            else
                mylog("[recv ack] 3+dup OR old ack %d\n", myheader->sequence);
        }
        else
            mylog("[recv corrupted ack] %x %d %d %d\n", MAGIC, 
                                                        sequenceNum, 
                                                        myheader->sequence, 
                                                        myheader->ack);

        free(packet);
    }
}



/**
* Entry point
* Second argument from cmd line should be host:port as documented in usage()
*/
int main(int argc, char *argv[]) {
    TIMEOUT = 1000000L;
    WINDOW_SIZE = 5.0;
    SS_THRES = 1000;

    // extract the host IP and port
    if ((argc != 2) || (strstr(argv[1], ":") == NULL))
        usage();

    char *tmp = (char *) malloc(strlen(argv[1])+1);
    strcpy(tmp, argv[1]);

    char *ip_s = strtok(tmp, ":");
    char *port_s = strtok(NULL, ":");

    // open a UDP socket  
    int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

    // construct the local port
    struct sockaddr_in out;
    out.sin_family = AF_INET;
    out.sin_port = htons(atoi(port_s));
    out.sin_addr.s_addr = inet_addr(ip_s);

    // socket for received packets
    struct sockaddr_in in;

    // construct the socket set
    fd_set socks;

    packetQueue = makeQueue();

    send_next_packets(sock, out);        // send first window
    recvSendLoop(sock, socks, in, out);  // loop: send packets as acks received
    send_final_packet(sock, out);        // close connection

    mylog("[completed] send\n");

    return 0;
}