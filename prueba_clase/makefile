prueba: lex.yy.c main.c
		gcc lex.yy.c main.c -lfl -o prueba

lex.yy.c: lexico.l lexico.h
		flex --yylineno lexico.l

clean:
		rm -f prueba lex.yy.c

run: prueba prueba.txt
		./prueba prueba.txt

MAC: lex.yy.c main.c
	gcc lex.yy.c main.c -ll -o prueba
