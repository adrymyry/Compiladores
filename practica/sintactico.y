%{
    #include "tabla_sim.h"
    #include "codigo.h"
    #include <stdio.h>
    #include <string.h>
    void yyerror(char const *msg);
    extern int yylineno;
    extern int yylex();
    int contador = 1;
    tablaVar variables;
    tablaCad cadenas;
%}

/* Definicion de tipos de datos para símbolos de la gramática */
%union {
    int entero;
    char *cadena;
    codigo c;
}

%token PROGRAMA VAR ENTERO COMIENZO FIN SI ENTONCES SINO
%token MIENTRAS HACER IMPRIMIR LEER PYC DOSP PUNTO COMA
%token MAS MENOS MULT PARI PARD DIV ASSIGN

/* Tokens asociados a tipos de datos */
%token <entero> NUM
%token <cadena> ID
%token <cadena> CADENA

%type <c> expression

/* Prioridades de terminales de menos a mas */
/* Y asociatividad izquierda */
%left MAS MENOS
%left MULT DIV
%left UMENOS

%expect 2


%%
/* Reglas de produccion */
program             :   PROGRAMA ID PARI PARD PYC declarations compound_statement PUNTO
                            {
                                printf("program -> programa id [%s] (); declarations compound_statement .\n", $2);
                                imprimirTablaCad(cadenas);
                                imprimirTablaVar(variables);
                            }
                    ;
declarations        :   declarations VAR identifier_list DOSP type PYC
                            {
                                printf("declarations -> declarations var identifier_list : type ;\n");
                            }
                    |   error PYC
                            {
                                fprintf(stderr, "Error sintáctico en declaración de variables.\n");
                            }
                    |
                            {
                                printf("declarations -> lambda\n");
                            }
                    ;

identifier_list     :   ID
                            {
                                printf("identifier_list -> id [%s]\n", $1);
                                char* aux = concatena("_", $1);
                                variables = crearVar(variables, aux, yylineno);
                            }
                    |   identifier_list COMA ID
                            {
                                printf("identifier_list -> identifier_list , id [%s]\n", $3);
                                char* aux = concatena("_", $3);
                                variables = crearVar(variables, aux, yylineno);
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
                    |   error FIN
                            {
                                fprintf(stderr, "Error sintáctico en bloque de sentecias\n");
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
                                printf("statement -> id [%s] := expression\n", $1);
                                if (!recuperaVar(variables, $1)){
                                    fprintf(stderr, "La variable %s no ha sido declarada\n", $1);
                                }
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
                                printf("print_item -> cadena [%s]\n", $1);
                                char * aux = concatenaInt("$str", contador);
                                cadenas = crearCad(cadenas, &aux, $1);
                                if (!strcmp(concatenaInt("$str", contador), aux)) {
                                    contador++;
                                }
                            }
                    ;
read_list           :   ID
                            {
                                printf("read_list-> id [%s]\n", $1);
                                if (!recuperaVar(variables, $1)){
                                    fprintf(stderr, "La variable %s no ha sido declarada\n", $1);
                                }
                            }
                    |   read_list COMA ID
                            {
                                printf("read_list-> read_list , id [%s]\n", $3);
                                if (!recuperaVar(variables, $3)){
                                    fprintf(stderr, "La variable %s no ha sido declarada\n", $3);
                                }
                            }
                    ;
expression          :   expression MAS expression
                            {
                                printf("expression -> expression + expression\n");
                                concatenarCodigo($1, $3);
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla("add", reg, obtenerTemp($1), obtenerTemp($3));
                                $$ = $1;
                                concatenarCuadrupla($$, aux);
                                liberar_reg(obtenerTemp($1));
                                liberar_reg(obtenerTemp($3));

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
                                $$ = $2;
                            }
                    |   ID
                            {
                                printf("expression -> id [%s]\n", $1);
                                if (!recuperaVar(variables, $1)){
                                    fprintf(stderr, "La variable %s no ha sido declarada\n", $1);
                                }
                                else {
                                  char * reg = obtenerReg();
                                  cuadrupla aux = crearCuadrupla("lw", reg, concatenaInt("", $1), NULL);
                                  $$ = crearCodigo();
                                  concatenarCuadrupla($$, aux);
                                }
                            }
                    |   NUM
                            {
                                printf("expression -> num [=%d]\n", $1);
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla("li", reg, concatenaInt("", $1), NULL);
                                $$ = crearCodigo();
                                concatenarCuadrupla($$, aux);
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
    borrarTablaVar(variables);
    borrarTablaCad(cadenas);
    return 0;
}
