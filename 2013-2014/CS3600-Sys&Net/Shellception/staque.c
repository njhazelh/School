/******************************************************************************
*
* Staque.c
* Authors: Nicholas Jones, Victor Monterroso
* Class: System and Networks Spring 2014, CS3600
* 2/1/2014
*
* Staque.c contains a queue implementation for building arbitrarity long
* command lines in our shell.  To use it, first you make a new queue using
* newList.  Then you add each character using addChar.  When all characters
* are added, convert the list to an array of Strings using toStringList.
*
******************************************************************************/



#include "staque.h"



/******************************************************************************
*                       GLOBAL VARIABLES
******************************************************************************/



/* The last character that was seen.  User to eat repeat spaces or tabs. */
char lastChar = ' ';



/******************************************************************************
*                       FUNCTIONS
******************************************************************************/




/**
* Create a new doubly linked list and set the default values
* Returns the pointer to the new list.
*/
d_list *newlist() {
	d_list *list = malloc(sizeof(d_list));
	list->first = NULL;
	list->last = NULL;
	lastChar = ' ';
	return list;
}



/**
*  Add a character to the queue
*    *list : The list to add to
*    c : The character to add
*    esc : Is the character escaped such as '\ ', '\t', or '\\'
*/
void addChar(d_list *list, char c, bool esc) {
	if (!esc && (lastChar == ' ' || lastChar == '\t') && (c == ' ' || c == '\t'))
		return;

	lastChar = c;
	c = ((c != ' ' && c != '\t') || esc ? c : '\0');
	
	d_element *e = malloc(sizeof(d_element));
	e->esc = esc;
	e->c = c;
	e->prev = NULL;
	e->next = list->first;
	list->first = e;
	if (e->next) e->next->prev = e;

	// Set last if e is first element added
	if (!list->last) list->last = e;
}



/**
 *  Counts the number of words in the list
 *  A word is defined as traversing through the list and having each
 *  char be a letter in the word until a delimiter such as a " " or
 *  the end of the list is hit
 *
 *  Example of input to word count:
 *    ls -l : 2
 *    ls foo bar : 3
 *    ls foo\ bar : 2
 *
 *  *list : The list to count the words in.
 *
 *   Return : The number of words.
 */
int countWords(d_list *list) {
	int count = 0;
	d_element *elem = list->last;

	while (elem) {
		if (!elem->c) count++;
		elem = elem->prev;
	}

	return count + (list->first && list->first->c ? 1 : 0);
}



/**
 * Determines the length of the next word, which is the amount of elements
 * from the end until a space is hit, traversing it backwards
 *
 *  *list : The Pointer to the list in which the "next word" is stored.
 *
 *  If the list is empty, then the size of the next word is 0.
 */
int nextWordLen(d_list *list) {
	int size = 0;
	d_element *elem = list->last;

	while (elem && elem->c) {
		size++;
		elem = elem->prev;
	}

	return size;
}



/**
 * Removes the last element from the list, resetting pointerss an freeing the
 * memory allocated to the element
 *
 *  *list : The list to remove the last element from.
 */
void removeLast(d_list *list) {
	if (list->last) {
		d_element *e = list->last;

		if (e->prev)
			e->prev->next = NULL;
		else
			list->first = NULL;

		list->last = e->prev;

		free(e);
	}
}



/**
 * Converts a single character which has an escaped value in the shell into
 * the actual escaped character or itself if it has no escaped twin.
 * Example: 't' -> '\t'
 *          ' ' -> ' '
 *
 *  c : The charactr to convert
 * 
 *  Return: The converted character
 */
char escapeChar(char c) {
	switch (c) {
		case 't': return '\t';
		case '\\': return '\\';
		case '\t': return '\t';
		case '&': return '&';
		case ' ': return ' ';
		default: return -1;
	}
}



/**
 * Gets the next char from the list, from a backwards point of view
 * Upon retrieving the last char, the element holding the char in the list
 * is freed
 *
 *  *list : The list to get the next char from.
 *
 *  Return : The next character
 */
char nextChar(d_list *list) {
	if (list->last) {
		char c = list->last->c;
		if (list->last->esc)
			c = escapeChar(c);
		removeLast(list);
		return c;
	}
	else
		return 0;
}



/**
 * Collects the next word in the list and makes word the pointer to that String
 *
 *  *list : Pointer to the list of characters to pull the word from
 *  **word : Pointer to the String to set.  This is a return arg.
 */
void nextWord(d_list *list, char **word) {
	int size = nextWordLen(list);
	int i = 0;
	if (size == 0) return;
	*word = (char *) calloc(size + 1, sizeof(char));

	while (i < size) {
		(*word)[i] = nextChar(list);
		i++;
	}

	(*word)[size] = '\0';
	nextChar(list); //gets rid of space
}



/**
 * Convert a d_list into a list of Strings where each String was space
 * delimited.
 *
 *  *list : The list to convert
 *  *numArgs : The return argment for the number of words in the list
 *  ***words : Return argument for the pointer to the list of Strings.
 */
void toStringList(d_list *list, int *numArgs, char ***words) {
	*numArgs = countWords(list);

	*words = (char **) calloc(*numArgs + 1, sizeof(char *));

	for (int i = 0; i < *numArgs; i++) {
		nextWord(list, &((*words)[i]));
	}

	free(list);
}