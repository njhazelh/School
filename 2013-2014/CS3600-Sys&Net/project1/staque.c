#include <bool.h>
 

// ============================================================================
//              DATA DEFINITIONS
// ============================================================================
struct d_element_s;


/**
 * A d_list is a structure similar to a doubly linked list, only there is also
 * a pointer to the last element of the list.
 * The benefit of this is that we get queue functionality.
 * 
 * INVARIANTS:
 *   An Empty list has first and last set to NULL
 *   A list with one element has first and last set to the same element.
 */
typdef struct d_list_s {
  d_element_s *first;
  d_element_s *last;
} d_linked_list;

/**
 * A d_element is an element in a d_list.
 * Each element points to the element before and after it.
 * The last element in the list has next pointing to NULL
 * The first element in the list has prev pointing to NULL
 * esc refers to whether c is an escaped character
 */
typdef struct d_element_s {
  d_element *next;
  d_element *prev;
  char c;
  bool esc;
} d_element;

// ============================================================================

/**
 *Adds an element to the list beginning of the list
 *In other words, it will be the new head
 */
void add(d_list *list, char c, bool esc) {
	// Add e to the list, allocate memory for an element
	d_element *e = malloc(sizeof(d_element));
	e->c = c;
	e->esc = esc;
	e->prev = NULL;
	e->next = list->first;
	list->first = e;

	// Set last if e is first element added
	if (!list->last) list->last = e;
}

/**
 * Counts the number of words in the list
 * A word is defined as traversing through the list and having each
 * char be a letter in the word until a delimiter such as a " " or
 * the end of the list is hit
 */
int countWords(d_list *list) {
	int count = 0;
	d_element *elem = list->last;

	while (elem) {
		if (elem->c == ' ' && !elem->esc) count++;

		elem = elem->prev;
	}

	return count;
}

/**
 * Determines the length of the next word, which is the amount of elements
 * from the end until a space is hit, traversing it backwards
 */
int nextWordLen(d_list *list) {
	int size = 0;
	d_element *elem = list->last;

	while (elem && elem->c != ' ' && elem->esc)
		size++;

	return size;
}

/**
 * Removes the last element from the list, resetting pointerss an freeing the
 * memory allocated to the element
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
 */
char escapeChar(char c) {
	switch (c) {
		case ' ': return ' ';
		case 't': return '\t';
		case '\\': return '\\';
		case '&': return '&';
		default: return -1;
	}
}

/**
 * Gets the next char from the list, from a backwards point of view
 * Upon retrieving the last char, the element holding the char in the list
 * is freed
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
		return NULL;
}

/**
 * Returns a string that is the next word in the list
 */
char* nextWord(d_list list) {
	char c = NULL;
	int size = nextWordLen(list);
	int i = 0;
	if (size == 0) return NULL;
	char *word = calloc(size + 1, sizeof(char));
	while (i < size && (c = nextChar(list)) && c != -1) {
		word[i] = c;
		i++
	}

	if (!c)
		return ;
	else if (c == -1)
		return -1;
	else
		return

}