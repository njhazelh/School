#include <stdio.h>

#define IN 1
#define OUT 0

int prob1A() {
    char x1[100] = "The quick brown fox jumped over the lazy dog.";
    int i, c, n1, nw, nc, state;

    state = OUT;
    n1 = nw = nc = 0;

    for (i = 0; x1[i] != '\0' ; i++) {
        ++nc;
        if (x1[i] == '\n')
            ++n1;
        if (x1[i] == ' ' || x1[i] == '\n' || x1[i] == '\t')
            state = OUT;
        else if (state == OUT) {
            state = IN;
            ++nw;
        }
    }
    printf("%d %d %d\n",n1,nw,nc);
}

int prob1B() {
    char x1[100] = "The quick brown fox jumped over the lazy dog.";
    int i, c, n1, nw, nc, state;

    state = OUT;
    n1 = nw = nc = 0;

    for (i = 0; *(x1 + i) != '\0' ; i++) {
        ++nc;
        if (*(x1 + i) == '\n')
            ++n1;
        if (*(x1 + i) == ' ' || *(x1 + i) == '\n' || *(x1 + i) == '\t')
            state = OUT;
        else if (state == OUT) {
            state = IN;
            ++nw;
        }
    }
    printf("%d %d %d\n",n1,nw,nc);
}

int prob1C() {
    char x1[100] = "The quick brown fox jumped over the lazy dog.";
    int c, n1, nw, nc, state;

    state = OUT;
    n1 = nw = nc = 0;

    char *x1ptr;
    for (x1ptr = x1; *x1ptr != '\0' ; x1ptr++) {
        ++nc;
        if (*x1ptr == '\n')
            ++n1;
        if (*x1ptr == ' ' || *x1ptr == '\n' || *x1ptr == '\t')
            state = OUT;
        else if (state == OUT) {
            state = IN;
            ++nw;
        }
    }
    printf("%d %d %d\n",n1,nw,nc);
}

int prob2A() {
    char x1[100] = "The 25 quick brown foxes jumped over the 27 lazy dogs 17 times.";
    int c, i, nwhite, nother;
    int ndigit[10];

    nwhite = nother = 0;
    for (i = 0; i < 10; ++i)
        ndigit[i] = 0;

    for (i = 0; (c = x1[i]) != '\0'; i++) {
        if (c >= '0' && c <= '9')
            ++ndigit[c - '0']; 
        else if (c == ' ' || c == '\n' || c == '\t')
            ++nwhite;
        else
            ++nother;
    }

    printf("digits =");
    for(i = 0; i < 10; i++)
        printf(" %d", ndigit[i]);
    printf(", whitespace = %d, other = %d\n", nwhite, nother);
}

int prob2B() {
    char x1[100] = "The 25 quick brown foxes jumped over the 27 lazy dogs 17 times.";
    int c, i, nwhite, nother;
    int ndigit[10];

    nwhite = nother = 0;
    for (i = 0; i < 10; ++i)
        *(ndigit + i) = 0;

    for (i = 0; (c = *(x1 + i)) != '\0'; i++) {
        if (c >= '0' && c <= '9')
            ++(*(ndigit + c - '0'));
        else if (c == ' ' || c == '\n' || c == '\t')
            ++nwhite;
        else
            ++nother;
    }

    printf("digits =");
    for(i = 0; i < 10; i++)
        printf(" %d", *(ndigit + i));
    printf(", whitespace = %d, other = %d\n", nwhite, nother);
}

int prob2C() {
    char x1[100] = "The 25 quick brown foxes jumped over the 27 lazy dogs 17 times.";
    int c, i, nwhite, nother;
    int ndigit[10];

    nwhite = nother = 0;
    int *ndigitptr;
    for (ndigitptr = ndigit; ndigitptr - ndigit < 10; ++ndigitptr)
        *ndigitptr = 0;

    char *x1ptr;
    for (x1ptr = x1; (c = *x1ptr) != '\0'; x1ptr++) {
        if (c >= '0' && c <= '9')
            ++*(ndigit + c - '0'); 
        else if (c == ' ' || c == '\n' || c == '\t')
            ++nwhite;
        else
            ++nother;
    }

    printf("digits =");
    for (ndigitptr = ndigit; ndigitptr - ndigit < 10; ++ndigitptr)
        printf(" %d", *ndigitptr);
    printf(", whitespace = %d, other = %d\n", nwhite, nother);
}


int main( int argc, const char* argv[] ) {
    prob1A();
    prob1B();
    prob1C();
    prob2A();
    prob2B();
    prob2C();
}