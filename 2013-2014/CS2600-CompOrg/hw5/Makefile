FILE=cache.c
OUTPUT=cache

default: runAll

run: compile run1

runAll: compile run1 run2 run3 run4

run1:
	./cache 128 1 8

run2:
	./cache 64 2 8

run3:
	./cache 128 1 16

run4:
	./cache 64 8 8

compile:
	gcc -g -o $(OUTPUT) $(FILE)

clean:
	rm -f cache

gdb:
	gcc -g -O0 -o $(OUTPUT) $(FILE)
	gdb $(OUTPUT)

dist: clean compile
	dir=`basename $$PWD`; cd ..; tar cvf $$dir.tar ./$$dir; gzip $$dir.tar
	dir=`basename $$PWD`; ls -l ../$$dir.tar.gz