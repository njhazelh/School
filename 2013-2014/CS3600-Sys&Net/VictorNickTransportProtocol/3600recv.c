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

#include "3600sendrecv.h"

static int DATA_SIZE = 1500;
unsigned int nextSeq = 0;
struct sockaddr_in in;
int sock;
PacketQueue *received;

/*
 * This function handles having received an EOF packet
 */
void manageEOF() {
    mylog("[recv eof]\n");
    mylog("[completed] recv\n");
    exit(0);
}



/*
 * This function sends the appropriate ACK upon receiving a valid packet
 * 
 * eof - Is this ack the eof?
 */
void sendAck(int eof) {
    header *responseheader = make_header(nextSeq, 0, eof, 1, 0);

    if (sendto(sock,
               responseheader,
               sizeof(header),
               0,
               (struct sockaddr *) &in,
               (socklen_t) sizeof(in))
        < 0) {
        perror("sendto");
        mylog("Error sending ack %d", nextSeq);
    }

    free(responseheader);
}



/*
 * This stores a pakcet in the queue the receiver manages
 *
 * *myheader - The header of the file
 * *packet   - The packet to store
 */
void storePacket(header *myheader, char *packet) {
    char *storeData = (char *) malloc(myheader->length + sizeof(header));
    memcpy(storeData, packet, myheader->length + sizeof(header));
    addInOrder(received, myheader->sequence, storeData, myheader->length);
}



/*
 * This function manages a packet that has been received in order by printing it
 * out to standard output and also printing any queued packets that are right 
 * after.
 *
 * *myheader - The header of the packet
 * *packet   - The packet
 */
void managePacketInOrder(header *myheader, char *packet) {
    write(1, get_data(packet), myheader->length);

    // update next expected sequence number
    nextSeq++;

    // print packets stored that follow and increment sequence numbers
    flushQueue(received, &nextSeq);

    // send ack
    sendAck(myheader->eof);
}



/*
 * This function manages packets that have been received out of order by 
 * queueing them and sending the appropriate ACK
 *
 * *myheader - The header of the packet
 * *packet   - The packet
 */
void managePacketOutOfOrder(header *myheader, char *packet) {
    // store packet
    storePacket(myheader, packet);

    // send next expected sequence number ack
    sendAck(myheader->eof);
}

/*
 * This function manages packets that are duplicates.
 *
 * *myheader - The header of the packet
 */
void manageDuplicatePacket(header *myheader) {
    mylog("[recv data] %hd (%d) %s\n", myheader->sequence, 
                                       myheader->length, 
                                       "IGNORED {Duplicate past data}");
    sendAck(0);
}

/*
 * This function handles packets whose MAGIC number does not match ours.
 */
void manageBadMAGIC() {
    mylog("[recv corrupted packet]\n");
}

/*
 * This master function parses the buffer and extracts the header and the data
 * and deals with it accordingly
 * 
 * *packet - The packet to parse
 */
void parsePacket(char *packet) {
    header *headr = get_header(packet);
    unsigned short packetCheck = 0;
    unsigned short recCheck = 0;    

    
     // Was the length field in the header corrupted and possibly giving us a
     // length greater than the buffer can give the data?
    if (headr->length > DATA_SIZE - sizeof(header)) {
       manageBadMAGIC();
       return;          
    }
    
    if (!(headr->eof)) {
        packetCheck = headr->checkSum;
        mylog("Extracted Checksum, Packet %d: %hu\n", headr->sequence,
                                                      packetCheck);

        recCheck = checkSum((unsigned short *)((char *)packet + sizeof(header)),
                            headr->length);

        mylog("Receiver's Computed checksum for Packet %d is: %hu\n", 
                headr->sequence, recCheck);
    }

    if (headr->magic == MAGIC && recCheck == packetCheck) {
        if (headr->sequence == nextSeq && headr->eof)
            manageEOF();
        else if (headr->sequence == nextSeq)     // packet in order
            managePacketInOrder(headr, packet);
        else if (headr->sequence > nextSeq)      // packet arrived too soon
            managePacketOutOfOrder(headr, packet);
        else                                     // packet already received
            manageDuplicatePacket(headr);
    }
    else
        manageBadMAGIC();
}
/*
 * Our main function
 */
int main() {
    mylog("\n\n\nReceiver running.\n");

    // first, open a UDP socket  
    sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

    // next, construct the local port
    struct sockaddr_in out;
    out.sin_family = AF_INET;
    out.sin_port = htons(0);
    out.sin_addr.s_addr = htonl(INADDR_ANY);

    if (bind(sock, (struct sockaddr *) &out, sizeof(out))) {
        perror("bind");
        exit(1);
    }

    struct sockaddr_in tmp;
    int len = sizeof(tmp);
    if (getsockname(sock, (struct sockaddr *) &tmp, (socklen_t *) &len)) {
        perror("getsockname");
        exit(1);
    }

    mylog("[bound] %d\n", ntohs(tmp.sin_port));

    // wait for incoming packets
    socklen_t in_len = sizeof(in);

    // construct the socket set
    fd_set socks;

    // construct the timeout
    struct timeval *t = (struct timeval *) malloc(sizeof(struct timeval));

    // our receive buffer
    int buf_len = 1500;
    void* buf = malloc(buf_len);

    //We want to store out of order packets in a queue
    received = makeQueue();

    //Functions for received queue

    // wait to receive, or for a timeout
    while (1) {
        FD_ZERO(&socks);
        FD_SET(sock, &socks);
        t->tv_sec = 10;
        t->tv_usec = 0;

        //mylog("receiving...\n");
        //mylog("TimeVal values: %ld, %ld\n", t->tv_sec, t->tv_usec);

        if (select(sock + 1, &socks, NULL, NULL, t)) {

            int received;

            if ((received = recvfrom(sock,
                                     buf, 
                                     buf_len, 
                                     0, 
                                     (struct sockaddr *) &in, 
                                     (socklen_t *) &in_len))
                < 0) {

                perror("recvfrom");
                mylog("recvfrom error");
                exit(1);
            }

            parsePacket(buf);
        }
        else {
            mylog("[error] timeout occurred (in recv)\t\t\texiting\n");
            exit(1);
        }
    }
}
