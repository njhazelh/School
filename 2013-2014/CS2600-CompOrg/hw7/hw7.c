/* Nicholas Jones
 * Computer Organization: 11/27/2013
 * Hw 7
 */


/* See Chapter 5 of Advanced UNIX Programming:  http://www.basepath.com/aup/
 *   for further related examples of systems programming.  (That home page
 *   has pointers to download this chapter free.
 *
 * Copyright (c) Gene Cooperman, 2006; May be freely copied as long as this
 *   copyright notice remains.  There is no warranty.
 */

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>
 #include <fcntl.h>

#define MAXLINE 200
#define MAXARGS 20

#define PIPE_CHAR "|"
#define BACKGROUND_CHAR "&"
#define IN_CHAR "<"
#define OUT_CHAR ">"
#define STDIN 0
#define STDOUT 1

#define NULLP (pid_t)-1

pid_t childpid1 = NULLP;
pid_t childpid2 = NULLP;

static char * getword(char *begin, char **end_ptr) {
    char *end = begin;

    // Trim leading spaces
    while ( *begin == ' ' )
        begin++;

    // prep counter
    end = begin;

    // run to end of word, line, or first space
    while ( *end != '\0' && *end != '\n' && *end != ' ')
        end++;

    // No Input, so return NULL
    if (end == begin)
        return NULL;

    // Else: terminate word
    *end = '\0';
    *end_ptr = end;

    // If it's a variable, expand it.
    if (begin[0] == '$') {
        begin = getenv(begin+1); // begin+1, to skip past '$'

        // error if expansion undefined.
    	if (begin == NULL) {
    	    perror("getenv");
    	    begin = "UNDEFINED";
        }
    }

    // Return pointer to first char of the word.
    return begin;
}



/*
 * argc is _count_ of args (*argcp == argc); argv is array of arg _values_
 */
static void getargs(char cmd[], int *argcp, char *argv[])
{
    char *cmdp = cmd;
    char *end;
    int i = 0;

    // fgets creates null-terminated string. stdin is pre-defined C constant
    // for standard intput.  feof(stdin) tests for file:end-of-file.
    if (fgets(cmd, MAXLINE, stdin) == NULL && feof(stdin)) {
        fprintf(stderr, "Couldn't read from standard input. End of file? Exiting ...\n");
        exit(1);  // any non-zero value for exit means failure.
    }

    while (((cmdp = getword(cmdp, &end)) != NULL) && (*cmdp != '#')) {
        //store the location of the first char of this word.
        argv[i++] = cmdp;

        // "end" brings us only to the '\0' at end of string
        cmdp = end + 1;
    }

    // Create additional null word at end for safety.
    argv[i] = NULL;

    // Set number of args in argv
    *argcp = i;
}



/* handler for SIGINT
 * Should only be called by a parent process.
 */
void handler(int sig) {
    assert(sig == SIGINT);

    // Pass SIGINT to child
    if (childpid2 == NULLP && childpid1 == NULLP) // main, so don't exit
        return;
    else if (childpid2 == NULLP)
        kill(childpid1, SIGINT); // send SIGINT to child1
    else {
        kill(childpid1, SIGINT); // send SIGINT to child1
        kill(childpid2, SIGINT); // send SIGINT to child2
    }
}



static void executePipe(int argc1, char *argv1[], int argc2, char *argv2[]) {
    int pipe_fd[2];
    int fd;

    pipe(pipe_fd);

    if((childpid1 = fork()) == 0) { // child1
        signal(SIGINT, SIG_DFL);
        close(STDOUT);
        dup(pipe_fd[1]);
        close(pipe_fd[1]);
        // Executes command in argv[0];  It searches for that file in
        // the directories specified by the environment variable PATH.
        if (-1 == execvp(argv1[0], argv1)) {
            perror("execvp");
            fprintf(stderr, "  (couldn't find command)\n");
        }
        // Never gets here.
    }
    else if ((childpid2 = fork()) == 0) { // child2
        signal(SIGINT, SIG_DFL);
        close(STDIN);
        dup(pipe_fd[0]);
        close(pipe_fd[1]);
        // Executes command in argv[0];  It searches for that file in
        // the directories specified by the environment variable PATH.
        if (-1 == execvp(argv2[0], argv2)) {
            perror("execvp");
            fprintf(stderr, "  (couldn't find command)\n");
        }
        // Never gets here.
    }
    else {
        int status;
        close(pipe_fd[1]);
        close(pipe_fd[0]);
        wait(NULL);
        wait(NULL);
    }

    childpid1 = NULLP;
    childpid2 = NULLP;

    return;
}


static void executeInBackground(int argc, char *argv[]) {
    childpid1 = fork();

    if (childpid1 == -1) { // parent: (returned error)
        perror("fork"); /* perror => print error string of last system call */
        fprintf(stderr, "  (failed to execute command)\n");
    }
    else if (childpid1 == 0) { // child
        signal(SIGINT, SIG_DFL); // set SIGINT handler to default

        // Executes command in argv[0];  It searches for that file in
        // the directories specified by the environment variable PATH.
        if (-1 == execvp(argv[0], argv)) {
            perror("execvp");
            fprintf(stderr, "  (couldn't find command)\n");
        }
        // Never gets here.
    }

    childpid1 = NULLP;
    return;
}


static void executeFromFile(int argc, char *argv[], char *inputFile) {
    pid_t childpid1 = fork();

    if (childpid1 == 0) { // child
        signal(SIGINT, SIG_DFL); // set SIGINT handler to default

        // set stdin to inputFile
        close(STDIN);
        int fd = open(inputFile, O_RDONLY); 

        // check for error opening file.
        if (fd == -1)
            perror("open for reading");

        // Executes command in argv[0];  It searches for that file in
        // the directories specified by the environment variable PATH.
        if (-1 == execvp(argv[0], argv)) {
            perror("execvp");
            fprintf(stderr, "  (couldn't find command)\n");
        }
    }
    else if (childpid1 == -1) { // parent (returned error)
        perror("fork"); /* perror => print error string of last system call */
        printf("  (failed to execute command)\n");
    }
    else { // parent
        // wait for child
        waitpid(childpid1, NULL, 0);
    }

    childpid1 = NULLP;
    return;
}


static void executeToFile(int argc, char *argv[], char *outputFile) {
    pid_t childpid1 = fork();

    if (childpid1 == 0) { // child
        signal(SIGINT, SIG_DFL); // set SIGINT handler to default

        // set stdout to file
        close(STDOUT);
        int fd = open(outputFile, O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR);

        // check for error opening file.
        if (fd == -1)
            perror("open for writing");

        // Executes command in argv[0];  It searches for that file in
        // the directories specified by the environment variable PATH.
        if (-1 == execvp(argv[0], argv)) {
            perror("execvp");
            fprintf(stderr, "  (couldn't find command)\n");
        }
    }
    else if (childpid1 == -1) { // parent (returned error)
        perror("fork"); /* perror => print error string of last system call */
        printf("  (failed to execute command)\n");
    }
    else { // parent
        // wait for child to finish.
        waitpid(childpid1, NULL, 0);
    }

    childpid1 = NULLP;
    return;
}

static void executeNormal(int argc, char *argv[])
{
    childpid1 = fork();

    if (childpid1 == -1) { // parent (returned error)
        perror("fork"); /* perror => print error string of last system call */
        printf("  (failed to execute command)\n");
    }
    else if (childpid1 == 0) { /* child:  in child, childpid was set to 0 */

        signal(SIGINT, SIG_DFL);

        // Executes command in argv[0];  It searches for that file in
        // the directories specified by the environment variable PATH.
        if (-1 == execvp(argv[0], argv)) {
          perror("execvp");
          printf("  (couldn't find command)\n");
        }

        // NOT REACHED unless error occurred
        exit(1);
    }
    else  /* parent:  in parent, childpid was set to pid of child process */
        waitpid(childpid1, NULL, 0);  /* wait until child process finishes */

    childpid1 = NULLP;

    return;
}




/*
 * Check for exit or logout commands.
 * THEN
 * Run through the args checking for special I/O cases.
 * If encounter special case, send to correct execute function.
 * else execute normally.
 */
static void analyzeAndRun(int argc, char *argv[]) {

    // Check first for built-in commands.
    if ((argc > 0 && ((strcmp(argv[0], "exit") == 0) ||
                      (strcmp(argv[0], "logout") == 0))))
        exit(0);

    // Else: Run on args
    int i;

    for (i = 0; i<argc && argv[i] != NULL; i++) {
        char *word = argv[i];

        // Check for pipe character: |
        // usage: command1 args1 | command2 args2
        if (strcmp(word, PIPE_CHAR) == 0) {
            // Check syntax
            if (i == 0 || i == argc-1) {
                fprintf(stderr, "pipe needs two commands");
                return;
            }

            // End array early.
            argv[i] = NULL;
            executePipe(i, argv, argc-i-1, argv+i+1);
            return;
        }

        // Check for file-in character: <
        // usage: command args < inputfile
        else if (strcmp(word, IN_CHAR) == 0) {
            // Check syntax
            if (argv[i+1] == NULL) {
                fprintf(stderr, "Needs input file.");
                return;
            }

            char *inputFile = argv[i+1];
            argv[i] == NULL;
            argv[i+1]== NULL;

            int j;
            for (j=0; i+j<argc; j++)
                argv[i+j] = argv[i+j+2];

            executeFromFile(argc-1, argv, inputFile);
            return;
        }

        // Check for file-out character: >
        // usage: command args > outputfile
        else if (strcmp(word, OUT_CHAR) == 0) {
            // Check syntax
            if (argv[i+1] == NULL) {
                fprintf(stderr, "Needs output file.");
                return;
            }

            char *outputFile = argv[i+1];
            argv[i] == NULL;
            argv[i+1] == NULL;

            int j;
            for (j=0; i+j<argc; j++)
                argv[i+j] = argv[i+j+2];

            executeToFile(argc, argv, outputFile);
            return;
        }

        // Check for background character: &
        // usage: command args &
        else if (strcmp(word, BACKGROUND_CHAR) == 0) {
            // Check syntax
            if (i != argc-1) {
                fprintf(stderr, "& can only be the last arg");
                return;
            }

            // End array early.
            argv[i] = NULL;
            executeInBackground(argc-1, argv);
            return;
        }
    }
    // END OF LOOP

    // No Special I/O
    executeNormal(argc, argv);
    return;
}



int main(int argc, char *argv[])
{
    char cmd[MAXLINE];
    char *childargv[MAXARGS];
    int  childargc;

    signal(SIGINT, handler);
    
    // Redirect stdin to file
    if (argc > 1) {

        // If file executable, redirect stdin to it.
        if (!access(argv[1],X_OK))
            freopen(argv[1], "r", stdin);

        // Otherwise, args bad, exit with error.
        else {
            fputs("Cannot execute given file\n", stderr);
            exit(1);
        }
    }

    while (true) {
        // printf uses %d, %s, %x, etc.  See 'man 3 printf'
        printf("%% ");

        // flush from output buffer to terminal itself 
        fflush(stdout);

        // childargc and childargv are output args
        // getargs sets them.
    	getargs(cmd, &childargc, childargv);

        // check args for special I/O, termination... and run.
        if (argc > 0)
            analyzeAndRun(childargc, childargv);
    }

    // unless infinity ends, execution should never get here.
    fprintf(stderr, "Infinity ended. Black Magic?");
}
