%{
	#include "codigo.h"
	#include "sintactico.tab.h"
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

programa 									{ return PROGRAMA; }
var 										{ return VAR; }
entero 										{ return ENTERO; }
comienzo 									{ return COMIENZO; }
fin 										{ return FIN; }
si 											{ return SI; }
entonces 									{ return ENTONCES; }
si-no 										{ return SINO; }
mientras 									{ return MIENTRAS; }
hacer 										{ return HACER; }
imprimir 									{ return IMPRIMIR; }
leer 										{ return LEER; }
para										{ return PARA;}
not											{ return NOT; }

({L}|_)({L}|_|{D}){0,15}	{ yylval.cadena = strdup(yytext);
														return ID;
													}
({L}|_)({L}|_|{D}){16,}		{ printf("Error léxico en línea %d: Identificador %s no válido.\n", yylineno, yytext); }
{D}+											{ long long max = (long long)1<<31;
													  if (atoll(yytext) > max) {
															printf("Error léxico en línea %d: Entero %s no válido.\n", yylineno, yytext);
													  } else {
															yylval.entero = atoi(yytext);
															return NUM;
													  }
											   	}


\"([^"\n]+|\\\")*\"				{ yylval.cadena = strdup(yytext);
														return CADENA; }
\"([^"\n]+|\\\")*					{ printf("Error léxico en línea %d, cadena no cerrada: %s\n", yylineno, yytext); }

;	 												{ return PYC; }
:	 												{ return DOSP; }
"."	 											{ return PUNTO; }
,	 												{ return COMA; }
"+"	 											{ return MAS; }
-	 												{ return MENOS; }
"*"	 											{ return MULT; }
"("	 											{ return PARI; }
")"	 											{ return PARD; }
"/"	 											{ return DIV; }
:=	 											{ return ASSIGN; }
"<"												{ return MENOR; }
">"												{ return MAYOR; }
"="												{ return IGUAL;	}


"//"{C}*\n								{ }
[ \n\t\r]									{ }


"(*"											{ BEGIN(comentario);
								  					inicio_comentario = yylineno; }
<comentario>.|\n 					{ }
<comentario><<EOF>> 			{ printf("Comentario no cerrado en la línea %d\n", inicio_comentario);
 								  					return 0; }
<comentario>"*)" 					{ BEGIN(0); }

[^a-zA-ZñÑáéíóúüÁÉÍÓÚÜ0-9(),+\-_\*\.;<>= \n\t\r"/]+	{ printf("Error léxico en %d: %s\n", yylineno, yytext); }

%%
