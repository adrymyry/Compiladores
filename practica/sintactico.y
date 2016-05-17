%{
    #include "tabla_sim.h"
    #include "codigo.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    void yyerror(char const *msg);
    extern int yylineno;
    extern FILE *yyin;
    extern int yylex();
    int ncadenas = 1;
    tablaVar variables;
    tablaCad cadenas;
    int netiquetas = 1;
%}

/* Definicion de tipos de datos para símbolos de la gramática */
%union {
    int entero;
    char *cadena;
    codigo c;
}

%token PROGRAMA VAR ENTERO COMIENZO FIN SI ENTONCES SINO
%token MIENTRAS HACER IMPRIMIR LEER PYC DOSP PUNTO COMA
%token MAS MENOS MULT PARI PARD DIV ASSIGN PARA

/* Tokens asociados a tipos de datos */
%token <entero> NUM
%token <cadena> ID
%token <cadena> CADENA

%type <c> expression statement statement_list optional_statements compound_statement
%type <c> read_list print_list print_item

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
                                //printf("program -> programa id [%s] (); declarations compound_statement .\n", $2);
                                printf("##################\n");
                                printf("# Seccion de datos\n");
                                printf("\t.data\n\n");
                                imprimirTablaCad(cadenas);
                                imprimirTablaVar(variables);

                                printf("###################\n");
                                printf("# Seccion de codigo\n");
                                printf("\t.text\n\n");
                                printf("\t.global %s\n", $2);
                                printf("%s:\n", $2);
                                printf("\t# Aqui comienzan las instrucciones del programa\n");
                                imprimirCodigo($7);
                                // Liberar codigo
                                free($2);
                            }
                    ;
declarations        :   declarations VAR identifier_list DOSP type PYC
                            {
                                //printf("declarations -> declarations var identifier_list : type ;\n");
                            }
                    |   error PYC
                            {
                                fprintf(stderr, "Error sintáctico en declaración de variables.\n");
                            }
                    |
                            {
                                //printf("declarations -> lambda\n");
                            }
                    ;

identifier_list     :   ID
                            {
                                //printf("identifier_list -> id [%s]\n", $1);
                                char* aux = concatena("_", $1);
                                variables = crearVar(variables, aux, yylineno);
                            }
                    |   identifier_list COMA ID
                            {
                                /*printf("identifier_list -> identifier_list , id [%s]\n", $3);*/
                                char* aux = concatena("_", $3);
                                variables = crearVar(variables, aux, yylineno);
                            }
                    ;

type                :   ENTERO
                            {
                                /*printf("type -> entero\n");*/
                            }
                    ;

compound_statement  :   COMIENZO optional_statements FIN
                            {
                                /*printf("compound_statement -> comienzo optional_statements fin\n");*/
                                $$ = $2;
                            }
                    |   error FIN
                            {
                                fprintf(stderr, "Error sintáctico en bloque de sentecias\n");
                            }
                    ;

optional_statements :   statement_list
                            {
                                /*printf("optional_statements -> statement_list\n");*/
                                $$ = $1;
                            }
                    |
                            {
                                /*printf("optional_statements -> lambda\n");*/
                                $$ = crearCodigo();
                            }
                    ;

statement_list      :   statement
                            {
                                /*printf("statement_list -> statement\n");*/
                                $$ = $1;
                            }
                    |   statement_list PYC statement
                            {
                                /*printf("statement_list -> statement_list ; statement\n");*/
                                concatenarCodigo($1, $3);
                                $$ = $1;
                            }
                    ;

statement           :   ID ASSIGN expression
                            {
                                /*printf("statement -> id [%s] := expression\n", $1);*/
                                char* aux = concatena("_", $1);
                                if (!recuperaVar(variables, aux)){
                                    fprintf(stderr, "La variable %s no ha sido declarada\n", $1);
                                    $$ = $3;// ? DUDA
                                } else {
                                    cuadrupla store = crearCuadrupla("sw", obtenerTemp($3), aux, NULL);
                                    concatenarCuadrupla($3, store);
                                    liberarReg(obtenerTemp($3));
                                    $$ = $3;
                                }
                            }
                    |   compound_statement
                            {
                                /*printf("statement -> compound_statement\n");*/
                                $$ = $1;
                            }
                    |   SI expression ENTONCES statement SINO statement
                            {
                                /*printf("statement -> si expression entonces statement si-no statement\n");*/
                                char * etiqueta1 = concatenaInt("$l", netiquetas);
                                char * etiqueta2 = concatenaInt("$l", netiquetas+1);
                                netiquetas+=2;

                                concatenarCuadrupla($2, crearCuadrupla("beqz", obtenerTemp($2), etiqueta1, NULL));
                                liberarReg(obtenerTemp($2));
                                concatenarCodigo($2, $4);
                                concatenarCuadrupla($2, crearCuadrupla("b", etiqueta2, NULL, NULL));
                                concatenarCuadrupla($2, crearCuadrupla(etiqueta1, NULL, NULL, NULL));
                                concatenarCodigo($2, $6);
                                concatenarCuadrupla($2, crearCuadrupla(etiqueta2, NULL, NULL, NULL));

                                $$ = $2;
                            }
                    |   SI expression ENTONCES statement
                            {
                                /*printf("statement -> si expression entonces statement\n");*/
                                char * etiqueta = concatenaInt("$l", netiquetas);
                                netiquetas++;

                                concatenarCuadrupla($2, crearCuadrupla("beqz", obtenerTemp($2), etiqueta, NULL));
                                liberarReg(obtenerTemp($2));
                                concatenarCodigo($2, $4);
                                concatenarCuadrupla($2, crearCuadrupla(etiqueta, NULL, NULL, NULL));
                                $$ = $2;
                            }
                    |   MIENTRAS expression HACER statement
                            {
                                /*printf("statement -> mientras expression hacer statement\n");*/
                                char * etiqueta1 = concatenaInt("$l", netiquetas);
                                char * etiqueta2 = concatenaInt("$l", netiquetas+1);
                                netiquetas+=2;

                                codigo mientras = crearCodigo();
                                concatenarCuadrupla(mientras, crearCuadrupla(etiqueta1, NULL, NULL, NULL));
                                concatenarCodigo(mientras, $2);
                                concatenarCuadrupla(mientras, crearCuadrupla("beqz", obtenerTemp($2), etiqueta2, NULL));
                                liberarReg(obtenerTemp($2));
                                concatenarCodigo(mientras, $4);
                                concatenarCuadrupla(mientras, crearCuadrupla("b", etiqueta1, NULL, NULL));
                                concatenarCuadrupla(mientras, crearCuadrupla(etiqueta2, NULL, NULL, NULL));

                                $$ = mientras;
                            }
                    |   HACER statement MIENTRAS expression
                            {
                                char * etiqueta1 = concatenaInt("$l", netiquetas);
                                netiquetas++;

                                codigo hacer = crearCodigo();
                                concatenarCuadrupla(hacer, crearCuadrupla(etiqueta1, NULL,NULL,NULL));
                                concatenarCodigo(hacer, $2);
                                concatenarCodigo(hacer, $4);
                                concatenarCuadrupla(hacer, crearCuadrupla("bnez", obtenerTemp($4), etiqueta1, NULL));
                                liberarReg(obtenerTemp($4));

                                $$ = hacer;
                            }
                    |   PARA PARI ID ASSIGN expression PYC expression PYC expression PARD HACER statement
                            {
                                char * etiqueta1 = concatenaInt("$l", netiquetas);
                                char * etiqueta2 = concatenaInt("$l", netiquetas+1);
                                char * etiqueta3 = concatenaInt("$l", netiquetas+2);
                                netiquetas+=3;

                                codigo para = crearCodigo();
                                // Inicializar
                                char* id = concatena("_", $3);
                                if (!recuperaVar(variables, id)){
                                    fprintf(stderr, "La variable %s no ha sido declarada\n", $3);
                                } else {
                                    //concatenarCuadrupla(para, crearCuadrupla("HOLAA", NULL, NULL, NULL));
                                    concatenarCodigo(para, $5);
                                    cuadrupla store = crearCuadrupla("sw", obtenerTemp($5), id, NULL);
                                    concatenarCuadrupla(para, store);
                                }
                                concatenarCuadrupla(para, crearCuadrupla(etiqueta1, NULL,NULL,NULL));
                                // Condicion;
                                concatenarCodigo(para, $7);
                                cuadrupla aux = crearCuadrupla("sub", obtenerTemp($5), obtenerTemp($7), obtenerTemp($5));
                                liberarReg(obtenerTemp($7));
                                concatenarCuadrupla(para, crearCuadrupla("beqz", obtenerTemp($5), etiqueta2, NULL));
                                liberarReg(obtenerTemp($5));
                                // Cuerpo for
                                concatenarCodigo(para, $12);
                                // Actualizacion
                                concatenarCodigo(para, $9);
                                cuadrupla store = crearCuadrupla("sw", obtenerTemp($9), id, NULL);
                                concatenarCuadrupla(para, store);
                                liberarReg(obtenerTemp($9));
                                // Continuar
                                concatenarCuadrupla(para, crearCuadrupla("b", etiqueta1, NULL, NULL));
                                concatenarCuadrupla(para, crearCuadrupla(etiqueta2, NULL, NULL, NULL));
                                $$ = para;

                            }
                    |   IMPRIMIR print_list
                            {
                                /*printf("statement -> imprimir print_list\n");*/
                                $$ = $2;
                            }
                    |   LEER read_list
                            {
                                /*printf("statement -> leer read_list\n");*/
                                $$ = $2;
                            }
                    ;
print_list          :   print_item
                            {
                                /*printf("print_list -> print_item\n");*/
                                $$ = $1;
                            }
                    |   print_list COMA print_item
                            {
                                /*printf("print_list -> print_list , print_item\n");*/
                                concatenarCodigo($1, $3);
                                $$ = $1;
                            }
                    ;
print_item          :   expression
                            {
                                /*printf("print_item -> expression\n");*/
                                codigo imprime = crearCodigo();
                                concatenarCuadrupla(imprime, crearCuadrupla("move", "$a0", obtenerTemp($1), NULL));
                                concatenarCuadrupla(imprime, crearCuadrupla("li", "$v0", concatenaInt("", 1), NULL));
                                concatenarCuadrupla(imprime, crearCuadrupla("syscall", NULL, NULL, NULL));
                                liberarReg(obtenerTemp($1));

                                concatenarCodigo($1, imprime);
                                $$ = $1;
                            }
                    |   CADENA
                            {
                                /*printf("print_item -> cadena [%s]\n", $1);*/
                                char * aux = concatenaInt("$str", ncadenas);
                                cadenas = crearCad(cadenas, &aux, $1);
                                if (!strcmp(concatenaInt("$str", ncadenas), aux)) {
                                    ncadenas++;
                                }
                                codigo imprime = crearCodigo();
                                concatenarCuadrupla(imprime, crearCuadrupla("la", "$a0", aux, NULL));
                                concatenarCuadrupla(imprime, crearCuadrupla("li", "$v0", concatenaInt("", 4), NULL));
                                concatenarCuadrupla(imprime, crearCuadrupla("syscall", NULL, NULL, NULL));

                                $$ = imprime;
                            }
                    ;
read_list           :   ID
                            {
                                /*printf("read_list-> id [%s]\n", $1);*/
                                char* aux = concatena("_", $1);
                                if (!recuperaVar(variables, aux)){
                                    fprintf(stderr, "La variable %s no ha sido declarada\n", $1);
                                    $$ = crearCodigo();
                                } else {
                                    codigo lee = crearCodigo();
                                    concatenarCuadrupla(lee, crearCuadrupla("li", "$v0", concatenaInt("", 5), NULL));
                                    concatenarCuadrupla(lee, crearCuadrupla("syscall", NULL, NULL, NULL));
                                    concatenarCuadrupla(lee, crearCuadrupla("sw", "$v0", aux, NULL));

                                    $$ = lee;
                                }
                            }
                    |   read_list COMA ID
                            {
                                /*printf("read_list-> read_list , id [%s]\n", $3);*/
                                char* aux = concatena("_", $3);
                                if (!recuperaVar(variables, aux)){
                                    fprintf(stderr, "La variable %s no ha sido declarada\n", $3);
                                    $$ = $1;
                                } else {
                                    codigo lee = crearCodigo();
                                    concatenarCuadrupla(lee, crearCuadrupla("li", "$v0", concatenaInt("", 5), NULL));
                                    concatenarCuadrupla(lee, crearCuadrupla("syscall", NULL, NULL, NULL));
                                    concatenarCuadrupla(lee, crearCuadrupla("sw", "$v0", aux, NULL));

                                    concatenarCodigo($1, lee);
                                    $$ = $1;
                                }
                            }
                    ;
expression          :   expression MAS expression
                            {
                                /*printf("expression -> expression + expression\n");*/
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla("add", reg, obtenerTemp($1), obtenerTemp($3));
                                liberarReg(obtenerTemp($1));
                                liberarReg(obtenerTemp($3));
                                concatenarCodigo($1, $3);
                                concatenarCuadrupla($1, aux);
                                $$ = $1;
                            }
                    |   expression MENOS expression
                            {
                                /*printf("expression -> expression - expression\n");*/
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla("sub", reg, obtenerTemp($1), obtenerTemp($3));
                                liberarReg(obtenerTemp($1));
                                liberarReg(obtenerTemp($3));
                                concatenarCodigo($1, $3);
                                concatenarCuadrupla($1, aux);
                                $$ = $1;
                            }
                    |   expression MULT expression
                            {
                                /*printf("expression -> expression * expression\n");*/
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla("mult", reg, obtenerTemp($1), obtenerTemp($3));
                                liberarReg(obtenerTemp($1));
                                liberarReg(obtenerTemp($3));
                                concatenarCodigo($1, $3);
                                concatenarCuadrupla($1, aux);
                                $$ = $1;
                            }
                    |   expression DIV expression
                            {
                                /*printf("expression -> expression / expression\n");*/
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla("div", reg, obtenerTemp($1), obtenerTemp($3));
                                liberarReg(obtenerTemp($1));
                                liberarReg(obtenerTemp($3));
                                concatenarCodigo($1, $3);
                                concatenarCuadrupla($1, aux);
                                $$ = $1;
                            }
                    |   MENOS expression %prec UMENOS
                            {
                                /*printf("expression -> - expression\n");*/
                                cuadrupla aux = crearCuadrupla("neg", obtenerTemp($2), obtenerTemp($2), NULL);
                                $$ = $2;
                                concatenarCuadrupla($$, aux);
                            }
                    |   PARI expression PARD
                            {
                                /*printf("expression -> ( expression )\n");*/
                                $$ = $2;
                            }
                    |   ID
                            {
                                /*printf("expression -> id [%s]\n", $1);*/
                                char* iden = concatena("_", $1);
                                if (!recuperaVar(variables, iden)){
                                    fprintf(stderr, "La variable %s no ha sido declarada\n", $1);
                                }
                                else {
                                  char * reg = obtenerReg();
                                  cuadrupla aux = crearCuadrupla("lw", reg, iden, NULL);
                                  $$ = crearCodigo();
                                  concatenarCuadrupla($$, aux);
                                }
                            }
                    |   NUM
                            {
                                /*printf("expression -> num [=%d]\n", $1);*/
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

int main(int argc, char const *argv[]) {

    if (argc != 2) {
        printf("Uso: %s fichero\n", argv[0]);
        exit(1);
    }

    FILE *f_in = fopen(argv[1], "r");
    if (f_in == NULL) {
        printf("Archivo %s no existe\n", argv[1]);
        exit(2);
    }

    yydebug=0; //Para que no salga el debug
    yyin = f_in;
    yyparse();

    fclose(f_in);
    borrarTablaVar(variables);
    borrarTablaCad(cadenas);
    return 0;
}
