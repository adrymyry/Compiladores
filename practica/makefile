prueba: lex.yy.c sintactico.tab.c listaVar.c listaVar.h
		gcc lex.yy.c sintactico.tab.c listaVar.c -lfl -o prueba

lex.yy.c: lexico.l lexico.h
		flex --yylineno lexico.l

sintactico.tab.c sintactico.tab.h : sintactico.y
		bison -d -v -t sintactico.y

clean:
		rm -f prueba lex.yy.c sintactico.tab.*

run: prueba prueba.txt
		./prueba < prueba.txt

MAC: lex.yy.c main.c
	gcc lex.yy.c main.c -ll -o prueba
