%{
	#include "lexico.h"
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

main 							{ printf("MAIN\n");
								  return MAIN; }
print 							{ printf("PRINT\n");
								  return PRINT; }
({L}|_|$)({L}|_|$|{D})*			{ printf("Id: %s\n",yytext);
								  return ID; }
{D}+							{ printf("Num: %s\n", yytext);
								  return NUM; }
"("	 							{ printf("PARI\n");
								  return PARI; }
")"	 							{ printf("PARD\n");
								  return PARD; }
"{"	 							{ printf("LLAVEI\n");
								  return LLAVEI; }
"}"	 							{ printf("LLAVED\n");
								  return LLAVED; }
;	 							{ printf("PYC\n");
								  return PYC; }
,	 							{ printf("COMA\n");
								  return COMA; }
"+"	 							{ printf("MAS\n");
								  return MAS; }
-	 							{ printf("MENOS\n");
								  return MENOS; }
=	 							{ printf("IGUAL\n");
								  return IGUAL; }

"//"{C}*\n						{ printf("COMMENT\n"); }
[ \n\t\r]						{ }
\"([^"\n]+|\\\"[^"\n]*\\\")*\"	{ printf("Cadena: %s\n", yytext);
								  return CADENA; }

"/*"							{ BEGIN(comentario);
								  inicio_comentario = yylineno; }
<comentario>.|\n 				{ }
<comentario><<EOF>> 			{ printf("Comentario no cerrado en la línea %d\n", inicio_comentario);
 								  return 0; }
<comentario>"*/" 				{ BEGIN(0); }

[^a-zA-Z0-9(),+\-= \n\t\r"/]+	{ printf("Error léxico en %d: %s\n", yylineno, yytext); }

%%
