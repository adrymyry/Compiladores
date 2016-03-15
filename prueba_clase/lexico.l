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

{D}+							{ yylval.entero = atoi(yytext);
								  return NUM; }
"("	 							{ return PARI; }
")"	 							{ return PARD; }
;	 							{ return PYC; }
"+"	 							{ return MAS; }
-	 							{ return MENOS; }
"*"	 							{ return POR; }
"/"	 							{ return DIV; }
= 						  		{ return IGUAL; }
[a-z]+		  					{ yylval.cadena = strdup(yytext);
								  return ID; }
[ \t\r\n]+						{ }
.								{ printf("Error léxico en %d: %s\n", yylineno, yytext); }

%%
