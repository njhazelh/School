/*
 * CS3600, Spring 2013
 * Project 1 Starter Code
 * (c) 2013 Alan Mislove
 *
 * You should use this (very simple) starter code as a basis for
 * building your shell.  Please see the project handout for more
 * details.
 */

#ifndef _3600sh_h
#define _3600sh_h

#define _BSD_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdbool.h>

void do_exit();
void getInput(int *numArgs, char ***args);
void freeStrings(int numArgs, char **args);
void analyzeAndRun(int numArgs, char **args);

#endif 
