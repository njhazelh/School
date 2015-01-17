/*******************************************************************************
*
* CS3600, Spring 2014
* Project 3: DNS Client
* DNS-Not-Shellception: Nick Jones, Victor Monterosso
*
* Based on Project 3 Starter Code by (c) 2013 Alan Mislove
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
#include <errno.h>

#include "3600dns.h"

/* Due of the fact that the header's values are set for a sent packet, it is
 * we know what the bit sequence of the header of the sent packets should be.
 * Rather than making bitfields which get switched around, it is much better 
 * and less confusing to use integer values whose bit sequence won't get flipped
 * and still match up with the bit sequence the header should have.
 */
const unsigned char header[] = {5, 57, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0};
const int headerSize = 12; // size of the header in bytes
short QTYPE = 1; // default value of QTYPE is 1 for A record lookup

/**
 * This function will print a hex dump of the provided packet to the screen
 * to help facilitate debugging.  In your milestone and final submission, you 
 * MUST call dump_packet() with your packet right before calling sendto().  
 * You're welcome to use it at other times to help debug, but please comment those
 * out in your submissions.
 *
 * DO NOT MODIFY THIS FUNCTION
 *
 * data - The pointer to your packet buffer
 * size - The length of your packet
 */
static void dump_packet(unsigned char *data, int size) {
    unsigned char *p = data;
    unsigned char c;
    int n;
    char bytestr[4] = {0};
    char addrstr[10] = {0};
    char hexstr[ 16*3 + 5] = {0};
    char charstr[16*1 + 5] = {0};
    for(n=1;n<=size;n++) {
        if (n % 16 == 1) {
            /* store address for this line */
            snprintf(addrstr, sizeof(addrstr), "%.4x",
               ((unsigned int)p-(unsigned int)data) );
        }
            
        c = *p;
        if (isprint(c) == 0) {
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
*                   OUR CODE STARTS HERE
*
*******************************************************************************/


/**
* This function takes in a received packet and parses out the portion of it
* that corresponds to the header and stores it in a Header structure we defined
*
* *packet - The pointer to the beginning of the packet.
*
* Returns the pointer to a Header struct with all fields set.
*/
Header *parseHeader(unsigned char *packet) {
  Header *header = (Header *)malloc(sizeof(Header));

  header->ID = ntohs(*((short *)packet));
  header->RA = (packet[3] >> 7) & 1;
  header->RD = packet[2] & 1;
  header->TC = (packet[2] >> 1) & 1;
  header->AA = (packet[2] >> 2) & 1;
  header->OPCODE = (packet[2] >> 4) & 15;
  header->QR = (packet[2] >> 7) & 1;
  header->RCODE = packet[3] & 15;
  header->Z = (packet[3] >> 4) & 7;
  header->QDCOUNT = ntohs(*(short *)&(packet[4]));
  header->ANCOUNT = ntohs(*(short *)&(packet[6]));
  header->NSCOUNT = ntohs(*(short *)&(packet[8]));
  header->ARCOUNT = ntohs(*(short *)&(packet[10]));

  return header;
}



/**
 * Based on the input we get, we must parse it to know what the server and port
 * are. This function will perform the needed parsing and set the appropriate
 * arguments.
 *
 * *arg[] - The array of arguements
 * **server - The pointer to the server domain name / ip (used for returning)
 * *port - The pointer to the port number (used for returning)
 * argc - The number of arguments in *arg[]
 *
 * It returns 0 if no error, else 1
 */
int setArgs(char *arg[], char **server, short *port, char **name, int argc) {
    // Check that we have either 2 or 3 arguments
    if (argc > 3 || argc < 2)
       return 1;

    // Set the QTYPE if sending Mail Server or Name Server query
    if (strcmp(arg[0], "-ns") == 0) {
      QTYPE = 2;
      argc -= 1;
      arg = &arg[1];
    }
    else if (strcmp(arg[0], "-mx") == 0) {
      QTYPE = 15;
      argc -= 1;
      arg = &arg[1];
    }
    
    // Return error if empty string or '@' not first character
    if (strlen(arg[0]) == 0 || arg[0][0] != '@')
      return 1;
    
    // Find the server string before the ':' (if there is a ':')
    *server = strtok(++arg[0], ":");

    // The second part is the port
    char *portStr = strtok(NULL, ":");

    // Set the Domain name that will be queried
    *name = arg[argc - 1];

    // Calculate port number else if no portStr, default to 53.
    if (portStr) {
      // Check that portStr is a numeric string using ASCII arithmetic
      for(unsigned int i = 0; i < strlen(portStr); i++)
        if (portStr[i] - '0' > 9 || portStr[i] - '0' < 0)
          return 1;

      *port = (short)atoi(portStr);
      return strtok(NULL, ":") != NULL; // CHECK THERE ARE NO EXTRA ":"
    }
    else {
      *port = (short)53; // default port number
      return 0;
    }
}



/**
* This function will format the domain name into DNS format, that is
* it will have a number value specifying the length of each section of the
* domain name that is split by the '.' delimiter.
*
* *name - The name to convert in dotted notation (eg. www.google.com)
* **query - Pointer to the converted String (used for returning)
*
* Returns the length of the of the converted *name
*/
int convertNameToDNS(char *name, char **query) {
  // length is 2 + length to fit NULL terminator and first length byte
  *query = calloc(strlen(name) + 2, sizeof(char));
  
  /*
   * We copy the string's values into our dynamically allocated memory starting
   * at index 1, because the 0th index is for the length of the first section
   */
  memcpy((char *)(*query + 1), name, strlen(name) + 1);
  int lenPos = 0; // position of length byte to set next
  int currentPos = 1; //current position
  
  // convert first byte and each '.' to the length of the following label
  while ((*query)[currentPos]) {

    if ((*query)[currentPos] == '.') {
      (*query)[lenPos] = currentPos - lenPos - 1;
      lenPos = currentPos;
    }

    currentPos++;
  }

  // Set the length of the last section
  (*query)[lenPos] = currentPos - lenPos - 1;
  
  return strlen(name) + 1;
}



/**
* Get the size of the question in bytes
*
* *packet - pointer into the packet at the beginning of the question
*
* Returns the number of bytes in the question
*/
short getQuestionSize(unsigned char *packet) {
  int i = 0;

  // Find the length of the name in the question.
  while (packet[i]) i++;

  // Add 5 due to the null label for the QNAME and the four octets needed for
  // the QTYPE and QCLASS
  return i + 5;
}



/*
 * This function will retrieve the next Answer portion of a packet that
 * has been received. It will return a pointer to an Answer structure we
 * have defined which stores each section of the answer we read.
 *
 * *answer - The pointer to the answer to get
 * **pointer - The pointer into the packet at the beginning of the next answer.
 */
void nextAnswer(Answer *answer, unsigned char **pointer) {
  //The name is the first thing in the answer section
  answer->NAME = *pointer;

  //We continue moving the pointer unless we hit either a null or a pointer
  while (**pointer != 0 && **pointer < 192) 
        (*pointer)++;

  //If we didn't hit a pointer, we hit a null so we move on to the next byte
  if (**pointer < 192)
     (*pointer)++;
  //if we didn't hit a null, then we hit a pointer, so we move 2 bytes, which
  //is the size of the pointer   
  else
    *pointer += 2;

  //Set the type field of our Answer structure
  answer->TYPE = *((short *)*pointer);

  // The type field is two octets, we move over two to get to the next field
  (*pointer) += 2;

  // Set the class field of our Answer structure
  answer->CLASS = *((short *)*pointer);

  // The class field is also two octets. Move over two bytes 
  (*pointer) += 2;

  //We set the TTL field of our structure
  answer->TTL = *((int *)*pointer);

  //The TTL is 4 octets so we move over four bytes
  (*pointer) += 4;

  //We set the RDLENGTH field of our Answer structure
  answer->RDLENGTH = ntohs(*((short *)(*pointer - 1)));

  //It is only one byte so we move over one
  (*pointer) += 1;

  //The rest of the answer is the rdata, so we set a pointer pointing to this
  //part of our answer
  answer->RDATA = *pointer;

  //Now we move the pointer over to the beginning of the next answer
  (*pointer) += answer->RDLENGTH + 1;
}



/**
* Find the pointers to the beginning of each answer
* packet the pointer to the packet at the beginning of the first answer
*
* *packet - The pointer to the first answer in the packet
* numAnswers - The number of answers in this packet
*
* Returns an array of Answers that are in the packet
*/
Answer *indexAnswers(unsigned char *packet, int numAnswers) {
  Answer *answers = (Answer *) calloc(numAnswers + 1, sizeof(Answer));

  for (int i = 0; i < numAnswers; i++) {
    nextAnswer(&(answers[i]), &packet);
  }
  return answers;
}



/**
 * Given that we have an A record, we parse the given RDATA section into
 * the format required by the specification of this project.
 *
 * *rdata - The data section containing an IP address in 4 sequencial bytes
 *
 * Returns a String containing the IP address.
 */
char *parseIP(unsigned char *rdata) {
  char *ip = (char *) calloc(16, sizeof(char));
  sprintf(ip, "%u.%u.%u.%u", rdata[0], rdata[1], rdata[2], rdata[3]);
  return ip;
}



/*
 * Given that the answer is an ARecord, this function will print out
 * the contents according to the project specification.
 *
 * answer - the answer to print
 * auth - whether or not the answer is authorative
 */
void printARecord(Answer answer, bool auth) {
  char *ip = parseIP(answer.RDATA);
  printf("IP\t%s\t%s\n", ip, auth ? "auth" : "nonauth");
  free(ip); //Free the memory that was calloc'ed by the helper function parseIP
}



/*
 * Follow all the pointers to determine the length of the Alias in characters
 *
 * *rdata - The pointer to the beginning of the rdata in the Answer
 * *packetStart - The pointer to the start of the packet
 *
 * Returns the number of characters in the converted Alias.
 */
int findAliasSize(unsigned char *rdata, unsigned char *packetStart) {
  int size = 0;
  
  //While we don't see a null
  while (*rdata) {
        //Check to see if it is a pointer
    if ((unsigned char)*rdata >= 192) { // It's a pointer to a label
      rdata = packetStart + ((rdata[0] & 0x3f << 8) | rdata[1]);
    }
    else { // It's not a pointer
      size += (*rdata) + 1;
      rdata += (*rdata) + 1;
    }
  }

  return size;
}



/*
 * This function will compute the size of the alias, allocate memory
 * that can hold it and will copy the contents of the domain name, while also
 * formatting it as specified by the project.
 *
 * *rdata - The pointer to the beginning of the rdata section of the answer
 * *packetStart - The pointer to the first byte of the packet.
 *
 * Returns a String containing the converted Alias
 * eg: 3www6google3com -> www.google.com
 */
char *parseAlias(unsigned char *rdata, unsigned char *packetStart) {
  int aliasIndex = 0;
  int charSize = 0;
  int aliasSize = findAliasSize(rdata, packetStart);

  char *alias = calloc(aliasSize, sizeof(char));
  
  //Before copying, make sure its not a pointer
  while (*rdata) {
    //Check to see if it is a pointer
    if ((unsigned char)*rdata >= 192) { // It's a pointer to a label
      rdata = packetStart + ((rdata[0] & 0x3f << 8) | rdata[1]);
    }
    else { // It's not a pointer, it we aren't at the beginning, then put a '.' 
         if (aliasIndex) {
            alias[aliasIndex++] = '.';               
         }
      charSize = *rdata;
      memcpy(alias + aliasIndex, rdata + 1, charSize);  
      rdata += (*rdata) + 1;
      aliasIndex += charSize;
    }
  }      
  alias[aliasIndex] = 0;
     
  return alias;
}



/*
 * This function prints out a Mail Server response in the required format for  
 * this project.
 *
 * answer - The answer to print the information from. Must be a Mail server.
 * *packetStart - The pointer the beginning of this packet
 * auth - Whether or not this answer is authorative.
 */
void printMS(Answer answer, unsigned char *packetStart, bool auth) {
  char *a = parseAlias(&(answer.RDATA[2]), packetStart);    
  printf("MX\t%s\t%d\t%s\n",
          a,
          (((short)answer.RDATA[0] << 8) | answer.RDATA[1]),
          auth ? "auth" : "nonauth"); 
  free(a); //a was dynamically allocated and must be freed             
}



/*
 * This function prints out a Name Server in the required format for 
 * the project.
 *
 * answer - The answer to print (must be a name server answer)
 * *packetStart - The pointer to the beginning of the packet.
 * auth - Whether or not this answer is authorative.
 */
void printNS(Answer answer, unsigned char *packetStart, bool auth) {
  char *a = parseAlias(answer.RDATA, packetStart);   
  printf("NS\t%s\t%s\n",
         a,
         auth ? "auth" : "nonauth");
  free(a); //free dynamically allocated memory                             
}



/*
 * Given that the answer is a CNAME, this function will print out the
 * contents according to the format specified by the project specification.
 *
 * answer - The answer to print (must be a CNAME answer)
 * *packetStart - The pointer to the beginning of the packet.
 * auth - Whether or not this answer is authorative.
 */
void printCNAME(Answer answer, unsigned char *packetStart, bool auth) {
  char *a = parseAlias(answer.RDATA, packetStart); 
  printf("CNAME\t%s\t%s\n",
          a,
          auth ? "auth" : "nonauth");
  free(a); //free dynamically allocated memory
}



/*
 * Given an Answer structure containing an answer portion of a packet, this 
 * function determine which type of answer it is and prints out the content
 * accordingly by calling a helper function.
 *
 * answer - The answer to print
 * *packetStart - The pointer to the beginning of the packet.
 * auth - Whether or not this answer is authorative.
 */
void printAnswer(Answer answer, unsigned char *packetStart, bool auth) {
  if (answer.TYPE == 0x0001)
    printARecord(answer, auth);
  else if (answer.TYPE == 0x0005)
    printCNAME(answer, packetStart, auth);
  else if (answer.TYPE == 0x0002)
    printNS(answer, packetStart, auth);
  else if (answer.TYPE == 0x000f)
    printMS(answer, packetStart, auth);  
}



/*
  * The function will check the response's header to check if it is valid for
  * further analysis. If an error is found, then the function will return 1, 
  * If nothing is found to be wrong, then a value of 0 will be returned.
  * 
  * *header - pointer to header to check
  * 
  * Returns 1 if error, else 0.
  */
int checkHeader(Header *head) {

    if (head->ID != 1337) {
       // ID incorrect
       printf("ERROR\tID is %d not 1337", head->ID);
       return 1;
    }
    else if (head->QR != 1) {
         // Packet is not a response
         printf("ERROR\tpacket is not a response: %u\n", head->QR);
         return 1;
    }
    else if (head->TC == 1) {
         // Response is truncated, error and exit
         printf("ERROR\treponse is truncated\n");
         return 1;
    }
    else if (head->RA == 0) {
         // Server does not support recursion, error and exit
         printf("ERROR\trecursion not supported\n");
         return 1;
    }
    else if (head->RCODE == 3) {
         // Name doesn't exist
         printf("NOTFOUND\n");
         return 1;
    }
    else if (head->RCODE != 0) {
         // Any other RCODE error
         printf("ERROR\tRCODE error %d\n", head->RCODE);
         return 1;
    }
    else {
         return 0;
    }

} //end of function



/*
 *
 * Entry Point
 *
 */
int main(int argc, char *argv[]) {

  //Here are the fields we need to keep track of from the input 
  char *server = NULL;
  short port = 0;
  char *name = NULL;

  // process the arguments
  if (argc < 2 || argc > 4 || setArgs(&argv[1],
                                      &server, &port, &name, argc - 1)) {
    fprintf(stderr, "Usage: [-ns|mx] @<server:port> <name>\n");
    exit(1);
  }

  // construct the DNS request
  char *converted;
  int querySize = convertNameToDNS(name, &converted);
  //Allocating buffer 
  unsigned char *packet = (unsigned char *)calloc(65000, sizeof(unsigned char));
  int packetSize = headerSize + querySize + 5;
  memcpy(packet, header, sizeof(header));
  memcpy(packet + sizeof(header), converted, strlen(converted) + 1);
  packet[headerSize + querySize + 2] = QTYPE;
  packet[headerSize + querySize + 4] = 1;
  
  // send the DNS request (and call dump_packet with your request)
  // first, open a UDP socket  
  int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

  // next, construct the destination address
  struct sockaddr_in out;
  out.sin_family = AF_INET;
  out.sin_port = htons(port);
  out.sin_addr.s_addr = inet_addr(server);

  dump_packet(packet, packetSize);
  if (sendto(sock, packet, (size_t)packetSize, 0, 
    (const struct sockaddr *)&out, sizeof(out)) < 0) {
    printf("ERROR! %s", strerror(errno));// an error occurred
    exit(0);
  }
  //Now that the packet has been sent, the memory can be freed.
  //The memory allocated for name conversion can also be freed.
  free(packet);
  free(converted);

  // wait for the DNS reply (timeout: 5 seconds)
  struct sockaddr_in in;
  socklen_t in_len = sizeof(in);

  // construct the socket set
  fd_set socks;
  FD_ZERO(&socks);
  FD_SET(sock, &socks);

  // construct the input buffer
  unsigned char *input = calloc(65535, sizeof(unsigned char));

  // construct the timeout
  struct timeval t;
  t.tv_sec = 5;
  t.tv_usec = 0;

  // wait to receive, or for a timeout
  if (select(sock + 1, &socks, NULL, NULL, &t)) {
    if (recvfrom(sock, input, 65535, 0, (struct sockaddr *) &in, &in_len) < 0) {
      // an error occured
      printf("ERROR\tsocket error: %s\n", strerror(errno));
      exit(0);
    }
  } else {
    // a timeout occurred
    printf("NORESPONSE\n");
    exit(0);
  }

  //Start by parsing and then checking the header section  
  Header *header = parseHeader(input);
  
  //Is the header valid?
  if (checkHeader(header)) {
     exit(0);
  }

  /* If execution reaches this point, then the HEADER section of the response 
   * has been deemed valid. We now need to know the size of the question 
   * section to be able to move into the answer section. The size of the 
   * question section is unknown due to the possible use of pointers.
   */

  // find the size of the question (required to find pointer to first answer)
  short questionSize = getQuestionSize(input + 12);

  // index answers
  Answer *answers =
    indexAnswers(input + 12 + questionSize + 1, header->ANCOUNT);

  //Print the answers we have received in proper format
  for (int i = 0; i < header->ANCOUNT; i++) {
    //Print answer function, which will maneuver through answer section
    printAnswer(answers[i], input, header->AA);
  }
  
  free(answers);
  free(header);
  free(input);

  return 0;
}
