%{
    #include "listaVar.h"
    #include <stdio.h>
    void yyerror(char const *msg);
    extern int yylineno;
    extern int yylex();
    int contador = 0;
    lista variables;
    lista cadenas;
%}

/* Definicion de tipos de datos para símbolos de la gramática */
%union {
    int entero;
    char *cadena;
}

%token PROGRAMA VAR ENTERO COMIENZO FIN SI ENTONCES SINO
%token MIENTRAS HACER IMPRIMIR LEER PYC DOSP PUNTO COMA
%token MAS MENOS MULT PARI PARD DIV ASSIGN

/* Tokens asociados a tipos de datos */
%token <entero> NUM
%token <cadena> ID
%token <cadena> CADENA

/* No terminales asociados a tipos de datos */
%type <entero> expression statement read_list

/* Prioridades de terminales de menos a mas */
/* Y asociatividad izquierda */
%left MAS MENOS
%left MULT DIV
%left UMENOS


%%
/* Reglas de produccion */
program             :   PROGRAMA ID PARI PARD PYC declarations compound_statement PUNTO
                            {
                                printf("program -> programa id(); declarations compound_statement .\n") ;
                            }
                    ;
declarations        :   declarations VAR identifier_list DOSP type PYC
                            {
                                printf("declarations -> declarations var identifier_list : type ;\n");
                            }
                    |
                            {
                                printf("declarations -> lambda\n");
                            }
                    ;

identifier_list     :   ID
                            {
                                printf("identifier_list -> id\n");
                            }
                    |   identifier_list COMA ID
                            {
                                printf("identifier_list -> identifier_list , id\n");
                            }
                    ;

type                :   ENTERO
                            {
                                printf("type -> entero\n");
                            }
                    ;

compound_statement  :   COMIENZO optional_statements FIN
                            {
                                printf("compound_statement -> comienzo optional_statements fin\n");
                            }
                    ;

optional_statements :   statement_list
                            {
                                printf("optional_statements -> statement_list\n");
                            }
                    |
                            {
                                printf("optional_statements -> lambda\n");
                            }
                    ;

statement_list      :   statement
                            {
                                printf("statement_list -> statement\n");
                            }
                    |   statement_list PYC statement
                            {
                                printf("statement_list -> statement_list ; statement\n");
                            }
                    ;

statement           :   ID ASSIGN expression
                            {
                                printf("statement -> id := expression\n");
                            }
                    |   compound_statement
                            {
                                printf("statement -> compound_statement\n");
                            }
                    |   SI expression ENTONCES statement SINO statement
                            {
                                printf("statement -> si expression entonces statement si-no statement\n");
                            }
                    |   SI expression ENTONCES statement
                            {
                                printf("statement -> si expression entonces statement\n");
                            }
                    |   MIENTRAS expression HACER statement
                            {
                                printf("statement -> mientras expression hacer statement\n");
                            }
                    |   IMPRIMIR print_list
                            {
                                printf("statement -> imprimir print_list\n");
                            }
                    |   LEER read_list
                            {
                                printf("statement -> leer read_list\n");
                            }
                    ;
print_list          :   print_item
                            {
                                printf("print_list -> print_item\n");
                            }
                    |   print_list COMA print_item
                            {
                                printf("print_list -> print_list , print_item\n");
                            }
                    ;
print_item          :   expression
                            {
                                printf("print_item -> expression\n");
                            }
                    |   CADENA
                            {
                                printf("print_item -> cadena\n");
                            }
                    ;
read_list           :   ID
                            {
                                printf("read_list-> id\n");
                                /*printf("read_list-> id (%s)\n", $1);
                                $$ =recuperaVar(variables, $1);
                                free($1);*/
                            }
                    |   read_list COMA ID
                            {
                                printf("read_list-> read_list , id\n");
                                /*printf("read_list-> read_list , id(%s)\n", $1);
                                $$ =recuperaVar(variables, $1);
                                free($1);*/
                            }
                    ;
expression          :   expression MAS expression
                            {
                                printf("expression -> expression + expression\n");
                            }
                    |   expression MENOS expression
                            {
                                printf("expression -> expression - expression\n");
                            }
                    |   expression MULT expression
                            {
                                printf("expression -> expression * expression\n");
                            }
                    |   expression DIV expression
                            {
                                printf("expression -> expression / expression\n");
                            }
                    |   MENOS expression %prec UMENOS
                            {
                                printf("expression -> - expression\n");
                            }
                    |   PARI expression PARD
                            {
                                printf("expression -> ( expression )\n");
                            }
                    |   ID
                            {
                                printf("expression -> id\n");
                                /*printf("expression -> id(%s)\n", $1);
                                $$ =recuperaVar(variables, $1);
                                free($1);*/
                            }
                    |   NUM
                            {
                                printf("expression -> num ");
                            }
                    ;

%%

/* Tratamiento de errores */
void yyerror(char const *msg) {
    fprintf(stderr, "Error sintáctico (linea %d): %s\n", yylineno, msg);
}

int main(void) {
    yydebug=0; //Para que no salga el debug
    yyparse();
    borrar(variables);
    borrar(cadenas);
    return 0;
}
