/**
 * Victor Monterroso, Nicholas Jones
 * Shellception: Running shells inside of shells inside of shells! Eventually, you lose track of which shell layer you are in!
 * CS3600, Spring 2013
 * Project 1 Starter Code
 * (c) 2013 Alan Mislove
 *
 * You should use this (very simple) starter code as a basis for 
 * building your shell.  Please see the project handout for more
 * details.
 */

#include "3600sh.h"
#include "staque.h"
#include "string_queue.h"

#define USE(x) (x) = (x)
#define INPUT_FILE_CHAR "<"
#define OUTPUT_FILE_CHAR ">"
#define OUT_ERR_FILE_CHAR "2>"
#define BACKGROUND_CHAR "&"
#define STDIN 0
#define STDOUT 1
#define STDERR 2

/*Prototypes*/
void preFork(string_queue *queue, int numArgs, char **args, char **input, char **output, char **err, bool *syntaxErr);       
char escChar(char c);
bool invalidAmpersand (int numArgs, char **args);
bool isRedirString(char *string);

/*Global variables
* lastLine: this variable serves to keep track of whether we have reached the last command, in which case, we exit the shell 
* invalidEsc: Do we have an invalid escape character? If no print an error message, which we do inside our analyzeAndRun function
* amperCount: keeps track of the number of un-escaped ampersand characters we encounter, which helsp us determine if we have a valid 
* background command or not
*/
bool lastLine = false;
char HOST_NAME[128]; 
bool invalidEsc = false;
int  amperCount = 0;
bool back = false;

int main(int argc, char*argv[]) {
  // Code which sets stdout to be unbuffered
  // This is necessary for testing; do not change these lines
  USE(argc);
  USE(argv);
  setvbuf(stdout, NULL, _IONBF, 0);

  gethostname(HOST_NAME, sizeof(HOST_NAME));
  
  //A pointer to the first string in an array of strings that will be set up by other c file
  char **args = NULL;
  //A count of the number of arguments we have, which is also set inside our other c file
  int numArgs = 0;

  //We keep prompting for a command until we hit an EOF or the user types in "exit"
  while (!lastLine) {
      printf("%s@%s:%s> ", getenv("USER"), HOST_NAME, getenv("PWD"));
      getInput(&numArgs, &args);
      analyzeAndRun(numArgs, args);
      freeStrings(numArgs, args);
  }

  do_exit();

  return 0;
}
//End of main

/*
* Once the strings that have been allocated memory have been used, 
* this function frees the memory by freeing the individual strings and
* then freeing the null pointer at the end
*/
void freeStrings(int numArgs, char **args) {
  for (int i = 0; i < numArgs; i++)
    free(args[i]);

    free(args);
}

/**
* Given the address to an integer and a pointer to an array of strings
* we read from input and the format the strings appropriately using a doubly
* linked list structure, where the appropriate characters are filtered.
*/
void getInput(int *numArgs, char ***args) {
  char c = '\0';
  //A pointer to our doubly linked list structure
  d_list *list = newlist();
         
  //read from standard input until we hit a newline character or an EOF     
  while ((c = getc(stdin)) != '\n' && !feof(stdin)) {
        //If we read an ampersand character, increment the global count for ampersand characters seen
        //and separate it from whatever is around it
        if (c == '&') {
           addChar(list, ' ', false);
           addChar(list, '&', false);
           addChar(list, ' ', false);   
           amperCount++;
           continue;
        }
        //If we don't see a backslash, insert character into doubly linked list with escape field to false   
        if(c != '\\') 
           addChar(list, c, false);
        //If we do see a backslash character, eat it, read the next char and then deal with it appropriately   
        else { 
           c = getc(stdin);
           c = escChar(c);
           //If we hit an '\' and an n, it is a newline character, get out of the loop
           if (c == 'n') {
              toStringList(list, numArgs, args);
              return;
            }
            //If we didn't see a '\n' add the appropriate character to our list. 
            else {
                 addChar(list, c, true);
            }
        }
    }

    //If we exitted the while loop because of an EOF we just read the last line
    if (c == EOF)
        lastLine = true;
        
    /*Turn all the characters that have been fed into our structure into a list of strings
    *and set the number of arguments
    */    
    toStringList(list, numArgs, args);
    
    return;
}

/*This function exits, with the required message at the end*/
void do_exit() {
  printf("So long and thanks for all the fish!\n");
  exit(0);
}

/**
 * First, we check to see if there are any errors, such as invalid syntax or invalid ampersands
 * If we find an error, we return the appropriate error message and return
 * If we don't find an error, we fork and run the command
 */
void analyzeAndRun(int numArgs, char **args) {
    char *input = NULL;
    char *output = NULL;
    char *err = NULL;
    bool syntaxErr = false;
    string_queue *queue = newStringQueue();

    pid_t pid = (pid_t)-1;

    if (args[0] && strcmp(args[0], "exit") == 0) {
        freeStrings(numArgs, args);
        do_exit();
    }
    if (numArgs == 0)
        return;
        
    //Is there an invalidAmpersand?     
    if (invalidAmpersand(numArgs, args)) {
       fprintf(stderr,"Error: Invalid syntax.\n");
       return;
    }
    
    //Is there an invalid escape sequence?        
    if (invalidEsc) {
       invalidEsc = false; //setting it back to false for next instruction
       fprintf(stderr,"Error: Unrecognized escape sequence.\n");
       return;         
    }
         
      //Sets the stage up for fork, redirection and whether or not a background process is in order
      char **inptr = &input;
      char **outptr = &output;
      char **errptr = &err;
      preFork(queue, numArgs, args, inptr, outptr, errptr, &syntaxErr);
      
      //Is there an invalidAmpersand?     
      if (syntaxErr) {
         fprintf(stderr,"Error: Invalid syntax.\n");
         return;
      }
    
       //Fork!!!!
       pid = fork();

    if (pid < 0) {
        printf("error: Could not launch fork\n");
        return;
    }
    if (pid == 0) {
          if (input) {
            // set stdout to file
            close(STDIN);
            int fd = open(input, O_RDONLY);

            // check for error opening file.
            if (fd == -1) {
                fprintf(stderr, "Error: Unable to open redirection file.\n");
                exit(0);
            }
        }
        if (output) {
            // set stdout to file
            close(STDOUT);
            int fd = open(output, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);

            // check for error opening file.
            if (fd == -1) {
                fprintf(stderr, "Error: Unable to open redirection file.\n");
                exit(0);
            }
        }
        if (err) {
            // set stdout to file
            int errDup = dup(2);
            close(STDERR);
            int fd = open(err, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);

            // check for error opening file.
            if (fd == -1) {
                dup2(errDup, 2);
                fprintf(stderr, "Error: Unable to open redirection file.\n");
                exit(0);
            }
            else {
              close(errDup);
            }
        }

        char **cmd =  NULL;
        toStringArray(&cmd, queue);

        for (int j = 0; cmd[j]; j++) {
          if (!cmd[j + 1] && strcmp(cmd[j], "&") == 0) {
            free(cmd[j]);
            cmd[j] = NULL;
          }
        }
        
        /*Have the child process execute command via execvp*/
        execvp(cmd[0], cmd);
        if (errno == EACCES)
            fprintf(stderr, "Error: Permission denied.\n");
        else
            fprintf(stderr, "Error: Command not found.\n");
        exit(1);
    }
        //Is this a background process?           
        else if (!back)
             waitpid(pid, NULL, 0);
        else
            return;
}

/*
 * Checks the input to set up redirection and whether
 * or not a background command has been given
 * Need: numArgs, args, queue, background, input, output, err
 */
void preFork(string_queue *queue, int numArgs, char **args, char **input, char **output, char **err, bool *syntaxErr) {
    bool inRedirects = false;

     //Loops through the arguments to check if there is a redirection character 
     for (int i = 0; i < numArgs; i++) {
        //the ith argument in the list of arguments
        char *argument = args[i];
         
        if (strcmp(argument, INPUT_FILE_CHAR) == 0) {
            inRedirects = true;
            //Is there an argument after the redirection character? If not, there is an error.                
            if (args[i + 1] && !isRedirString(args[i+ 1]) && !(*input))
                *input = args[++i];
            else {
                *syntaxErr = true;
                return;
            }
        }
        //Checks for output redirection
        else if (strcmp(argument, OUTPUT_FILE_CHAR) == 0) {
            inRedirects = true;
            //If no argument after '>', then an error 
            if (args[i + 1] && !isRedirString(args[i+ 1]) && !(*output))    
                *output = args[++i];
            else {
                *syntaxErr = true;
                return;
            }
        }
        //Checks for redirecting standard error
        else if (strcmp(argument, OUT_ERR_FILE_CHAR) == 0) {
            inRedirects = true;
            if (args[i + 1] && !isRedirString(args[i+ 1]) && !(*err))
                *err = args[++i];
                //If there is no argument after error redirection, there is an error
            else {
                *syntaxErr = true;
                return;
            }
        }
        //If not a special character, add it to our queue of strings
        else if (inRedirects && strcmp(argument, "&") != 0) {
            *syntaxErr = true;
            return;
        }
        else
            addString(queue, args[i]);
    }
    
    //End of function
    return;
}

/*Is this string a redirection string?*/
bool isRedirString(char *str) {
  return strcmp(str, BACKGROUND_CHAR) == 0 ||
         strcmp(str, INPUT_FILE_CHAR) == 0 ||
         strcmp(str, OUTPUT_FILE_CHAR) == 0 ||
         strcmp(str, OUT_ERR_FILE_CHAR) == 0;
}

/*
* Given that we have seen an escape character '\', return the appropriate char to be inserted into our list structure
* If it isn't a valid escape sequence, insert that character anyway since we won't actually execute anything since we
* take not that it is invalid and print the error message. 
*/
char escChar(char c) {
    if (c == '\\') 
      return '\\';
    else if (c == ' ')
      return ' ';
    else if (c == 't')
      return '\t';
    else if (c == '&')
      return '&';
    else if (c == 'n')
      return 'n';
    else {
      invalidEsc = true;
      return c; //By setting the invalid boolean to true, the command won't be sent to execvp
    }
}

/*
 * Were there any ampserand characters in the input?
 * If so, check to see that it is a proper command
 * If it isn't return false
 * Note: numArgs is always going to be greater than 0 since we check that 
 *       before we call this functino
 */ 
bool invalidAmpersand (int numArgs, char **args) {
    //Did we see an ampersand?  
    if (amperCount > 0) {
       //If we saw more than one ampersand, it is incorrect syntax            
       if (amperCount > 1) {
          amperCount = 0; //set the count to 0 for next instruction
          back = false;
          return true;               
       }
       //There is one ampersand, was it the last argument?
       else { 
            amperCount = 0; //resetting amperCount for next instruction
            char *lastArg = args[numArgs-1]; //last argument
            //If the last argument is an ampersand, we have a valid ampersand command
            if (strcmp("&", lastArg) == 0) {
               back = true;
               return false;                
            }
            else {
               back = false;
               return true;     
            }   
       }               
    }
    //If we didn't see an ampersand, we do not have an invalid ampersand command
    else {
         back = false; 
         return false;
    }
}

