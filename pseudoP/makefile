compilador: lex.yy.c sintactico.tab.c tabla_sim.c tabla_sim.h codigo.c codigo.h
		gcc lex.yy.c sintactico.tab.c tabla_sim.c codigo.c -lfl -o compilador

lex.yy.c: lexico.l
		flex --yylineno lexico.l

sintactico.tab.c sintactico.tab.h : sintactico.y
		bison -d -v -t sintactico.y

clean:
		rm -rf compilador lex.yy.c sintactico.tab.* *.dSYM sintactico.output

MAC: lex.yy.c sintactico.tab.c tabla_sim.c tabla_sim.h codigo.c codigo.h
		gcc lex.yy.c sintactico.tab.c tabla_sim.c codigo.c -ll -o compilador
