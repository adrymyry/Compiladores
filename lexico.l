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

programa 						{ printf("PROGRAMA\n");
								  return PROGRAMA; }
var 							{ printf("VAR\n");
								  return VAR; }
entero 							{ printf("ENTERO\n");
								  return ENTERO; }
comienzo 						{ printf("COMIENZO\n");
							  	  return COMIENZO; }
fin 							{ printf("FIN\n");
								  return FIN; }
si 								{ printf("SI\n");
								  return SI; }
entonces 						{ printf("ENTONCES\n");
							  	  return ENTONCES; }
sino 							{ printf("SINO\n");
								  return SINO; }
mientras 						{ printf("MIENTRAS\n");
								  return MIENTRAS; }
hacer 							{ printf("HACER\n");
							  	  return HACER; }
imprimir 						{ printf("IMPRIMIR\n");
								  return IMPRIMIR; }
leer 							{ printf("LEER\n");
								  return LEER; }

({L}|_)({L}|_|{D})*				{ if (strlen(yytext)>16) {
								  	printf("Error léxico en %d: Identificador %s no válido\n", yylineno, yytext);
							  	  } else {
									printf("Id: %s\n", yytext);
    								return ID;
								  }
								}

{D}+							{ unsigned long long max = 2147483648LL;
								  printf("%llu\n", max);
								  if (atoll(yytext) > max) {
									printf("Error léxico en %d: Entero %s no válido\n", yylineno, yytext);
								  } else {
									printf("Num: %s\n", yytext);
									return NUM;
								  }
							   	}

 /* \!([^"\n]+|\\\")*\" */
\"([^"\n]+|\\\"[^"\n]*\\\")*\"	{ printf("Cadena: %s\n", yytext);
								  return CADENA; }
;	 							{ printf("PYC\n");
								  return PYC; }
:	 							{ printf("DOSP\n");
								  return DOSP; }
"."	 							{ printf("PUNTO\n");
								  return PUNTO; }
,	 							{ printf("COMA\n");
								  return COMA; }
"+"	 							{ printf("MAS\n");
								  return MAS; }
-	 							{ printf("MENOS\n");
								  return MENOS; }
"*"	 							{ printf("MULT\n");
  								  return MULT; }
"("	 							{ printf("PARI\n");
								  return PARI; }
")"	 							{ printf("PARD\n");
								  return PARD; }
"/"	 							{ printf("DIV\n");
								  return DIV; }
:=	 							{ printf("ASSIGN\n");
								  return ASSIGN; }


"//"{C}*\n						{ printf("COMMENT\n"); }
[ \n\t\r]						{ }


"(*"							{ BEGIN(comentario);
								  inicio_comentario = yylineno; }
<comentario>.|\n 				{ }
<comentario><<EOF>> 			{ printf("Comentario no cerrado en la línea %d\n", inicio_comentario);
 								  return 0; }
<comentario>"*)" 				{ BEGIN(0); }

[^a-zA-Z0-9(),+\-= \n\t\r"/]+	{ printf("Error léxico en %d: %s\n", yylineno, yytext); }

%%
