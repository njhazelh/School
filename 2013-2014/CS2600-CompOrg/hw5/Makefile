FILE=cache.c
OUTPUT=cache
NEWLINE= @echo ""

default: runAll

run: compile run1

runAll: compile run1 run2 run3 run4

run1:
	@echo -e "Running 128 1 8\n---------------"
	@./cache 128 1 8
	$(NEWLINE)

run2:
	@echo -e "Running 64 2 8\n--------------"
	@./cache 64 2 8
	$(NEWLINE)

run3:
	@echo -e "Running 128 1 16\n----------------"
	@./cache 128 1 16
	$(NEWLINE)

run4:
	@echo -e "Running 64 8 8\n--------------"
	@./cache 64 8 8
	$(NEWLINE)

output: compile
	@./cache 128 1 8 > test1.txt
	@./cache 64 2 8 > test2.txt
	@./cache 128 1 16 > test3.txt
	@./cache 64 8 8 > test4.txt
	@echo Done

compile:
	@gcc -g -o $(OUTPUT) $(FILE)
	@echo "Compiled."
	$(NEWLINE)

clean:
	@rm -f cache

gdb:
	@gcc -g -O0 -o $(OUTPUT) $(FILE)
	@gdb $(OUTPUT)

dist: clean compile
	dir=`basename $$PWD`; cd ..; tar cvf $$dir.tar ./$$dir; gzip $$dir.tar
	dir=`basename $$PWD`; ls -l ../$$dir.tar.gz