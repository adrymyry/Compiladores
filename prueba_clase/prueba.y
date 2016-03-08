%{
    #include <stdio.h>
    void yyerror(char const *msg);
    extern int yylineno;
    extern int yylex();
    int contador = 0;
%}

%token MAS MENOS POR DIV PARI PARD NUM PYC

%%
/* Reglas de produccion */
entrada : entrada PYC { contador++; } e
                                    { printf("entrada->entrada;e [%d=%d]\n", contador, $4); }
        | { contador++; } e
                                    { printf("entrada->e [%d=%d]\n", contador,$2);}
        ;

e   : e MAS t           { printf("e->e+t\n");
                          $$ = $1+$3;
                        }
    | e MENOS t         { printf("e->e-t\n");
                          $$ = $1-$3;
                        }
    | t                 { printf("e->t|n\n");
                          $$ = $1;
                        }
    ;

t   : t POR f           { printf("t->t*f\n");
                          $$ = $1*$3;
                        }
    | t DIV f           { printf("t->t/f\n");
                          $$ = $1/$3;
                        }
    | f                 { printf("t->f\n");
                          $$ = $1;
                        }
    ;

f   : PARI e PARD       { printf("f->(e)\n");
                          $$ = $2;
                        }
    | MENOS f           { printf("f->-f\n");
                          $$ = -$2;
                        }
    | NUM               { printf("f->NUM [=%d]\n", $1);
                          $$ = $1;
                        }
    ;

%%

/* Tratamiento de errores */
void yyerror(char const *msg) {
    fprintf(stderr, "Error sintáctico %d: %s\n", yylineno, msg);
}

int main(void) {
    yyparse();
    return 0;
}
