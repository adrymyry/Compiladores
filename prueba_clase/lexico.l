%{
	#include "prueba.tab.h"
	#include <stdio.h>
	#include <string.h>
	int inicio_comentario = 0;
%}

%x comentario

 /* Letra */
L [a-zA-ZñÑáéíóúüÁÉÍÓÚÜ]
 /* Digito */
D [0-9]
 /* Cualquier caracter */
C .

%%

{D}+							{ printf("Num: %s\n", yytext);
								  yylval= atoi(yytext);
								  return NUM; }
"("	 							{ printf("PARI\n");
								  return PARI; }
")"	 							{ printf("PARD\n");
								  return PARD; }
;	 							{ printf("PYC\n");
								  return PYC; }
"+"	 							{ printf("MAS\n");
								  return MAS; }
-	 							{ printf("MENOS\n");
								  return MENOS; }
"*"	 							{ printf("POR\n");
								  return POR; }
"/"	 							{ printf("DIV\n");
								  return DIV; }
[ \t\r\n]+						{ }
.	{ printf("Error léxico en %d: %s\n", yylineno, yytext); }

%%
