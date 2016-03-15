prueba: lex.yy.c prueba.tab.c listaVar.c listaVar.h
	gcc lex.yy.c prueba.tab.c listaVar.c -lfl -o prueba

lex.yy.c: lexico.l prueba.tab.h
	flex --yylineno lexico.l

prueba.tab.c prueba.tab.h: prueba.y
	bison -d prueba.y

clean:
	rm -f prueba lex.yy.c prueba.tab.*

run: prueba prueba.txt
	./prueba < prueba.txt

MAC: lex.yy.c prueba.tab.c listaVar.c listaVar.h
	gcc lex.yy.c prueba.tab.c listaVar.c -ll -o prueba
