/*
 * CS3600, Spring 2014
 * Project 2 Starter Code
 * (c) 2013 Alan Mislove
 *
 */

#ifndef __3600DNS_H__
#define __3600DNS_H__

typedef struct header_s {
    short ID;
    int RA;
    int RD;
    int TC;
    int AA;
    int OPCODE;
    int QR;
    int RCODE;
    int Z;
    short QDCOUNT;
    short ANCOUNT;
    short NSCOUNT;
    short ARCOUNT;
} Header;

typedef struct answer_s {
    unsigned char *NAME;
    short TYPE;
    short CLASS;
    short TTL;
    unsigned short RDLENGTH;
    unsigned char *RDATA;
} Answer;

#endif

