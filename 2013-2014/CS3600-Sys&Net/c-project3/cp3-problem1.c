/*
 * CS3600, Spring 2014
 * C Bootcamp, Homework 3, Problem 1
 * (c) 2012 Alan Mislove
 *
 * In this problem, your goal is to fill in the itoaaa function.
 * This function will take in a 32-bit signed integer, and will
 * return a malloc'ed char * containing the English representation
 * of the number.  A few examples are below:
 *
 * 0 -> "zero"
 * 9 -> "nine"
 * 45 -> "forty five"
 * -130 -> "negative one hundred thirty"
 * 11983 -> "eleven thousand nine hundred eighty three"
 *
 * Do not touch anything outside of the itoaaa function (you may,
 * of course, define any helper functions you wish).  You may also
 * use any of the functions in <string.h>. 
 *
 * Finally, you must make sure to free() any intermediate malloced()
 * memory before you return the result.  You should also return a 
 * char* that is malloced to be as small as necessary (the script 
 * checks for this).  For example, if you returned "forty five", you
 * should put fthis into a malloced space of 12 bytes (11 + '\0').
 *
 */

#include <string.h>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>

char *itoaaa(int i);
int nthDigitOf(int x, int n);
char* blockToString(int block);
char* tensAndUnits(int num);
char* unitToString(int num);
char* tensToString(int num);
char* getMacroVal(int block);


int main(int argc, char **argv) {
  // check for the right number of arguments
  if (argc != 2) {
    printf("Error: Usage: ./cp3-problem1 [int]\n");
    return 0;
  }

  // create the time structure
  long long arg = atoll(argv[1]);
  if (arg == (int) arg) {
    // call the function
    char *result = itoaaa((int) arg);

    // print out the result
    printf("%d is: %s\n", (int) arg, result);
  } else {
    printf("Error: Number out of range.\n");
  }

  return 0;
}

/**
 * This function should print out the English full representation
 * of the passed-in argument.  See above for more details.
 */
 char *itoaaa(int arg) {
  int block = 0;
  char *result = "";
  int negative = arg < 0;

  // make arg positive for simplicity
  if (negative) arg *= -1;

  if (arg > 0) {
    while (arg) {
      if (arg % 1000 > 0) {
        char *newBlock = blockToString(arg % 1000);
        char *macroVal = getMacroVal(block++);
        int newLength = strlen(newBlock) + strlen(macroVal) + strlen(result) + 1;
        char *temp = result;
        result = (char *) calloc(newLength, sizeof(char));
        strcpy(result, newBlock);
        strcat(result, "");
        strcat(result, macroVal);
        strcat(result, temp);
        if(strcmp(temp, "")) free(temp);
      }
      else {
        block++;
      }
      arg /= 1000;
    }

    if (negative) {
      char *temp = result;
      result = (char *) calloc(strlen("negative ") + strlen(temp) + 1, sizeof(char));
      strcpy(result, "negative ");
      strcat(result, temp);
      free(temp);
    }
  }
  else {
    result = (char*) calloc(5, sizeof(char));
    strcpy(result, "zero");
    //return result;
  }

  return result;
}



char* unitToString(int num) {
  switch(num) {
    case 1: return "one";
    case 2: return "two";
    case 3: return "three";
    case 4: return "four";
    case 5: return "five";
    case 6: return "six";
    case 7: return "seven";
    case 8: return "eight";
    case 9: return "nine";
    case 10: return "ten";
    case 11: return "eleven";
    case 12: return "twelve";
    case 13: return "thirteen";
    case 14: return "fourteen";
    case 15: return "fifteen";
    case 16: return "sixteen";
    case 17: return "seventeen";
    case 18: return "eighteen";
    case 19: return "nineteen";
    default: return "";
  }
}

char* tensToString(int num) {
  switch(num) {
    case 2: return "twenty";
    case 3: return "thirty";
    case 4: return "forty";
    case 5: return "fifty";
    case 6: return "sixty";
    case 7: return "seventy";
    case 8: return "eighty";
    case 9: return "ninety";
    default: return "";
  }
}

char* getMacroVal(int block) {
  switch(block) {
    case 1: return " thousand ";
    case 2: return " million ";
    case 3: return " billion ";
    default: return "";
  }
}

/**
* a block is a three digit section of a number that would be enclosed in 
* commas.
* For example:
* 782,456,111 has three blocks: 782, 456, and 111.
* This function takes a block and converts it into a string following the 
* format: [(digit) hundred] [tens units | number < 20]
*/
char* blockToString(int block) {
  if (block < 100)
    return tensAndUnits(block);
  else {
    char *result = NULL;

    // find pieces
    char *hundreds = unitToString(block / 100);
    char *tensUnits = tensAndUnits(block % 100);
    int hasTens = (block % 100) > 0;

    // get space
    result = (char *) calloc(strlen(hundreds) + 8 + hasTens + strlen(tensUnits) + 1,
      sizeof(char)); // + 9 +  is " hundred "

    // combine strings
    strcpy(result, hundreds);
    strcat(result, " hundred");
    if (strcmp(tensUnits, "") != 0) {
      strcat(result, " ");
      strcat(result, tensUnits);
    }

    // clean up and return
    return result;
  }
}

char* tensAndUnits(int num) {
  char *result = NULL;

  if (num < 20) {
    char *val = unitToString(num);
    result = (char *) calloc(strlen(val) + 1, sizeof(char));
    strcpy(result, val);
    return result;
  }
  else {
    char *tens = tensToString(num / 10);
    char *units = unitToString(num % 10);
    result = (char *) calloc(strlen(tens) + 1 + strlen(units) + 1, sizeof(char));
    strcpy(result, tens);
    strcat(result, " ");
    strcat(result, units);
    return result;
  }
}