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
%type <entero> e t f asig

%%
/* Reglas de produccion */
entrada : entrada PYC { contador++; } asig  { printf("entrada->entrada;asig [%d=%d]\n", contador, $4); }
        | { contador++; } asig              { printf("entrada->asig [%d=%d]\n", contador,$2);}
        ;

asig    : ID IGUAL e                        { printf("%s=e\n", $1); $$ = $3;
                                              variables = crearVar(variables, $1, $3);
                                            }

e       : e MAS t                           { printf("e->e+t\n");
                                              $$ = $1+$3;
                                            }
        | e MENOS t                         { printf("e->e-t\n");
                                              $$ = $1-$3;
                                            }
        | t                                 { printf("e->t\n");
                                              $$ = $1;
                                            }
        ;

t       : t POR f                           { printf("t->t*f\n");
                                              $$ = $1*$3;
                                            }
        | t DIV f                           { printf("t->t/f\n");
                                              $$ = $1/$3;
                                            }
        | f                                 { printf("t->f\n");
                                              $$ = $1;
                                            }
        ;

f       : PARI e PARD                       { printf("f->(e)\n");
                                              $$ = $2;
                                            }
        | MENOS f                           { printf("f->-f\n");
                                              $$ = -$2;
                                            }
        | NUM                               { printf("f->NUM [=%d]\n", $1);
                                              $$ = $1;
                                            }
        | ID                                { printf("f->%s\n", $1);
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
    yyparse();
    borrar(variables);
    return 0;
}
