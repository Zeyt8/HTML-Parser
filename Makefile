build: main

main: lex.yy.c
	gcc -o exec lex.yy.c -lfl

lex.yy.c: main.l
	flex main.l

clean: 
	rm lex.yy.c exec