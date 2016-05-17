prueba: lex.yy.c sintactico.tab.c tabla_sim.c tabla_sim.h codigo.c codigo.h
		gcc -g lex.yy.c sintactico.tab.c tabla_sim.c codigo.c -lfl -o prueba

lex.yy.c: lexico.l lexico.h
		flex --yylineno lexico.l

sintactico.tab.c sintactico.tab.h : sintactico.y
		bison -d -v -t sintactico.y

clean:
		rm -f prueba lex.yy.c sintactico.tab.*

run: prueba prueba.txt
		./prueba prueba.txt

runS: prueba pruebaS.txt
		./prueba pruebaS.txt

MAC: lex.yy.c sintactico.tab.c tabla_sim.c tabla_sim.h codigo.c codigo.h
		gcc -g lex.yy.c sintactico.tab.c tabla_sim.c codigo.c -ll -o prueba
