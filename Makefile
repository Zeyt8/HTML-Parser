# Foca Bogdan 336CC
EXPENDABLES = exec lex.yy.o lex.yy.cc
CC = g++  

build: lex.yy.o
	$(CC) -o exec lex.yy.o -lfl

lex.yy.o: lex.yy.cc
	$(CC) -c -x c++ lex.yy.cc -lfl

lex.yy.cc: main.l
	flex --c++ main.l

clean:
	rm -f $(EXPENDABLES)