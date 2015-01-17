/******************************************************************************
*
* Stacque.c
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



#ifndef _staque_h
#define _staque_h

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>



// ============================================================================
//              DATA DEFINITIONS
// ============================================================================



struct d_element_s;

/**
 * A d_element is an element in a d_list.
 * Each element points to the element before and after it.
 * The last element in the list has next pointing to NULL
 * The first element in the list has prev pointing to NULL
 * esc refers to whether c is an escaped character
 */
typedef struct d_element_s {
  struct d_element_s *next;
  struct d_element_s *prev;
  char c;
  bool esc;
} d_element;

/**
 * A d_list is a structure similar to a doubly linked list, only there is also
 * a pointer to the last element of the list.
 * The benefit of this is that we get queue functionality.
 * 
 * INVARIANTS:
 *   An Empty list has first and last set to NULL
 *   A list with one element has first and last set to the same element.
 */
typedef struct d_list_s {
  d_element *first;
  d_element *last;
} d_list;



// ============================================================================
//                   FUNCTION DECLARATIONS
// ============================================================================



/**
* Create a new doubly linked list and set the default values
* Returns the pointer to the new list.
*/
d_list *newlist();



/**
*  Add a character to the queue
*    *list : The list to add to
*    c : The character to add
*    esc : Is the character escaped such as '\ ', '\t', or '\\'
*/
void addChar(d_list *list, char c, bool esc);



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
int countWords(d_list *list);



/**
 * Determines the length of the next word, which is the amount of elements
 * from the end until a space is hit, traversing it backwards
 *
 *  *list : The Pointer to the list in which the "next word" is stored.
 *
 *  If the list is empty, then the size of the next word is 0.
 */
int nextWordLen(d_list *list);



/**
 * Removes the last element from the list, resetting pointerss an freeing the
 * memory allocated to the element
 *
 *  *list : The list to remove the last element from.
 */
void removeLast(d_list *list);



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
char escapeChar(char c);



/**
 * Gets the next char from the list, from a backwards point of view
 * Upon retrieving the last char, the element holding the char in the list
 * is freed
 *
 *  *list : The list to get the next char from.
 *
 *  Return : The next character
 */
char nextChar(d_list *list);



/**
 * Collects the next word in the list and makes word the pointer to that String
 *
 *  *list : Pointer to the list of characters to pull the word from
 *  **word : Pointer to the String to set.  This is a return arg.
 */
void nextWord(d_list *list, char **word);



/**
 * Convert a d_list into a list of Strings where each String was space
 * delimited.
 *
 *  *list : The list to convert
 *  *numArgs : The return argment for the number of words in the list
 *  ***words : Return argument for the pointer to the list of Strings.
 */
void toStringList(d_list *list, int *numArgs, char ***words);

#endif