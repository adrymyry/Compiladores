%{
    #include "listaVar.h"
    #include <stdio.h>
    void yyerror(char const *msg);
    extern int yylineno;
    extern int yylex();
    int contador = 0;
    lista variables;
%}

/* Definicion de tipos de datos para símbolos de la gramática */
%union {
    int entero;
    char *cadena;
}

%token MAS MENOS POR DIV PARI PARD PYC IGUAL

/* Tokens asociados a tipos de datos */
%token <entero> NUM
%token <cadena> ID
/* No terminales asociados a tipos de datos */
%type <entero> e asig

/* Prioridades de terminales de menos a mas */
/* Y asociatividad izquierda */
%left MAS MENOS
%left POR DIV
%left UMENOS


%%
/* Reglas de produccion */
entrada : entrada { contador++; } asig  { printf("entrada->entrada;asig [%d=%d]\n", contador, $3); }
        | { contador++; } asig              { printf("entrada->asig [%d=%d]\n", contador,$2);}
        | error PYC                         { printf("Error durante análisis de entrada\n"); }
        ;

asig    : ID IGUAL e   PYC                  { printf("%s=e\n", $1); $$ = $3;
                                              variables = crearVar(variables, $1, $3);
                                            }

e       : e MAS e                           { printf("e->e+e\n");
                                              $$ = $1+$3;
                                            }
        | e MENOS e                         { printf("e->e-e\n");
                                              $$ = $1-$3;
                                            }

        | e POR e                           { printf("e->e*e\n");
                                              $$ = $1*$3;
                                            }
        | e DIV e                           { printf("e->e/e\n");
                                              $$ = $1/$3;
                                            }
        | PARI e PARD                       { printf("e->(e)\n");
                                              $$ = $2;
                                            }
        | MENOS e                           { printf("e->-e\n");
                                              $$ = -$2;
                                            }
        | NUM                               { printf("e->NUM [=%d]\n", $1);
                                              $$ = $1;
                                            }
        | ID                                { printf("e->%s\n", $1);
                                              $$ = recuperaVar(variables, $1);
                                              free($1);
                                            }
        ;

%%

/* Tratamiento de errores */
void yyerror(char const *msg) {
    fprintf(stderr, "Error sintáctico %d: %s\n", yylineno, msg);
}

int main(void) {
    yydebug=0; //Para que no salga el debug
    yyparse();
    borrar(variables);
    return 0;
}
