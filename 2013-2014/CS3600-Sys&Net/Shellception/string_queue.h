/******************************************************************************
*
* string_queue.h
* Authors: Nicholas Jones, Victor Monterroso
* Class: System and Networks Spring 2014, CS3600
* 2/1/2014
*
* string_queue.(h|c) contains the implementation for building arbitrarily long
* arrays of Strings.  Strings are inserted at the first element of the list and
* pulled out from the last element.
*
* To use string_queue, first build a new queue using newStringQueue, then add
* Strings one at a time using addString.  When all Strings are added, use
* toStringArray to convert the list of an array.
*
******************************************************************************/



#include <stdlib.h>
#include <string.h>
#include <stdio.h>



/******************************************************************************
*                    Structure Definitions
******************************************************************************/



struct string_queue_elem_s;



/**
* first : The First Element of the list
* last : The last element of the list
* count : The number of elements in the list
*/
typedef struct {
	struct string_queue_elem_s *first;
	struct string_queue_elem_s *last;
	int count;
} string_queue;



/**
* string : The String at this element
* next : The element added before this one.
* prev : The element added after this one.
*/
typedef struct string_queue_elem_s {
	char *string;
	struct string_queue_elem_s *next;
	struct string_queue_elem_s *prev;
} string_queue_elem;



/******************************************************************************
*                         Functions
******************************************************************************/



/**
* Make a new queue of Strings and set the starting values
* 
* Return : The pointer to the new queue
*/
string_queue *newStringQueue();



/**
* Add a String to the queue.
*
* *queue : The queue to add to
* *string : The String to add
*/
void addString(string_queue *queue, char *string);



/**
* Convert the queue into an array
*
* ***args : The pointer to the array to make. Return argument.
* *queue : The queue to convert.
*/
void toStringArray(char ***args, string_queue *queue);