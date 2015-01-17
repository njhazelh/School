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



#include "string_queue.h"



/******************************************************************************
*                         FUNCTIONS
******************************************************************************/



/**
* Make a new queue of Strings and set the starting values
* 
* Return : The pointer to the new queue
*/
string_queue *newStringQueue() {
	string_queue *queue = (string_queue *) malloc(sizeof(string_queue));

	queue->first = NULL;
	queue->last = NULL;
	queue->count = 0;

	return queue;
}



/**
* Add a String to the queue.
*
* *queue : The queue to add to
* *string : The String to add
*/
void addString(string_queue *queue, char *string) {
	string_queue_elem *e = (string_queue_elem *) malloc(sizeof(string_queue_elem));

	queue->count++;
	e->string = (char *) calloc(strlen(string) + 1, sizeof(char));
	strcpy(e->string, string);
	e->prev = NULL;
	e->next = queue->first;
	queue->first = e;
	if (e->next) e->next->prev = e;
	if (!queue->last) queue->last = e;
}



/**
* Convert the queue into an array
*
* ***args : The pointer to the array to make. Return argument.
* *queue : The queue to convert.
*/
void toStringArray(char ***args, string_queue *queue) {
	*args = (char **) calloc(queue->count + 1, sizeof(char **));
	string_queue_elem *elem = queue->last;

	for (int i = 0; elem != NULL; i++) {
		(*args)[i] = elem->string;
		//printf((*args)[i]);
		elem = elem->prev;
		if (elem) {
			free(elem->next);
			elem->next = NULL;
		}
	}
}