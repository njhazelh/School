#include <stdlib.h>
#include <stdio.h>

typedef struct a {
	int num;
	struct a *n;
} A;


int main(int argc, char **argv) {
	A *aa = malloc(sizeof(A));
	aa->num = 123;
	aa->n = (A*) NULL;

	while(aa) {
		aa = aa->n;
		printf("a");
	}
}