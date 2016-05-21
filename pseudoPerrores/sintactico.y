%{
    #include "tabla_sim.h"
    #include "codigo.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <sys/types.h>
    #include <sys/stat.h>
    #include <fcntl.h>
    void yyerror(char const *msg);
    extern int yylineno;
    extern FILE *yyin;
    extern int yylex();
    const char * ficheroSalida;
    
    int ncadenas = 1;
    tablaVar variables;
    tablaCad cadenas;
    int netiquetas = 1;
    int errores = 0;
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
%token PARA MENOR MAYOR IGUAL NOT

/* Tokens asociados a tipos de datos */
%token <entero> NUM
%token <cadena> ID
%token <cadena> CADENA

%type <c> expression statement statement_list optional_statements compound_statement
%type <c> read_list print_list print_item boolean_expression

/* Prioridades de terminales de menos a mas */
/* Y asociatividad izquierda */

%left MENOR IGUAL MAYOR
%left NOT

%left MAS MENOS
%left MULT DIV
%left UMENOS

// Se espera un conflicto debido a gramática ambigua. Sentencias if-then-if-then-else
// Bison realiza la elección correcta para resolver el conflicto
%expect 1


%%
/* Reglas de produccion */
program             :   PROGRAMA ID PARI PARD PYC declarations compound_statement PUNTO
                            {
                                //printf("program -> programa id [%s] (); declarations compound_statement .\n", $2);
                                if (!errores){
                                    freopen(ficheroSalida, "w", stdout);
                                    
                                    printf("##################\n");
                                    printf("# Seccion de datos\n");
                                    printf("\t.data\n\n");
                                    imprimirTablaCad(cadenas);
                                    imprimirTablaVar(variables);

                                    printf("\n###################\n");
                                    printf("# Seccion de codigo\n");
                                    printf("\t.text\n\n");
                                    printf("\t.globl main\n");
                                    printf("main:\n");
                                    printf("\t# Aqui comienzan las instrucciones del programa\n");
                                    imprimirCodigo($7);
                                    printf("\n###################\n");
                                    printf("# Fin\n");
                                    printf("\tjr $ra");
                                    // Liberar codigo
                                    free($2);
                                    liberarCodigo($7);
                                    fclose(stdout);
                                }


                            }
                    |   PROGRAMA ID PARI PARD PYC declarations compound_statement
                            {
                              fprintf(stderr, "\tError sintáctico. Falta el punto final\n");
                              errores++;
                            }
                    ;
declarations        :   declarations VAR identifier_list DOSP type PYC
                            {
                                //printf("declarations -> declarations var identifier_list : type ;\n");
                            }
                    |   declarations VAR error DOSP type PYC
                            {
                                fprintf(stderr, "\tError sintáctico en lista de variables.\n");
                                errores++;
                            }
                    |   declarations error PYC
                            {
                                fprintf(stderr, "\tError sintáctico en declaración de variables.\n");
                                errores++;
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
                    |   error COMA ID
                            {
                                fprintf(stderr, "\tError sintáctico. Falta el identificador de una variable\n");
                                errores++;
                                // Introduce el otro identificador en tabla de símbolos para evitar errores asociados
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
                    |   COMIENZO error FIN
                            {
                                fprintf(stderr, "\tError sintáctico en bloque de sentencias \n");
                                errores++;
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
                    |   statement_list statement
                            {
                                /*printf("statement_list -> statement_list ; statement\n");*/
                                concatenarCodigo($1, $2);
                                $$ = $1;
                            }
                    ;

statement           :   ID ASSIGN expression PYC
                            {
                                /*printf("statement -> id [%s] := expression\n", $1);*/
                                char* aux = concatena("_", $1);
                                if (!recuperaVar(variables, aux)){
                                    fprintf(stderr, "La variable %s no ha sido declarada (linea %d)\n", $1, yylineno);
                                    $$ = $3;// ? DUDA
                                } else {
                                    cuadrupla store = crearCuadrupla(strdup("sw"), obtenerTemp($3), aux, NULL);
                                    concatenarCuadrupla($3, store);
                                    liberarReg(obtenerTemp($3));
                                    $$ = $3;
                                }
                            }
                    |   compound_statement PYC
                            {
                                /*printf("statement -> compound_statement\n");*/
                                $$ = $1;
                            }
                    |   SI PARI boolean_expression PARD ENTONCES statement SINO statement
                            {
                                /*printf("statement -> si expression entonces statement si-no statement\n");*/
                                char * etiqueta1 = concatenaInt("$l", netiquetas);
                                char * etiqueta2 = concatenaInt("$l", netiquetas+1);
                                netiquetas+=2;

                                concatenarCuadrupla($3, crearCuadrupla(strdup("beqz"), obtenerTemp($3), etiqueta1, NULL));
                                liberarReg(obtenerTemp($3));
                                concatenarCodigo($3, $6);
                                concatenarCuadrupla($3, crearCuadrupla(strdup("b"), etiqueta2, NULL, NULL));
                                concatenarCuadrupla($3, crearCuadrupla(etiqueta1, NULL, NULL, NULL));
                                concatenarCodigo($3, $8);
                                concatenarCuadrupla($3, crearCuadrupla(etiqueta2, NULL, NULL, NULL));

                                $$ = $3;
                            }
                    |   SI PARI boolean_expression PARD ENTONCES statement
                            {
                                /*printf("statement -> si expression entonces statement\n");*/
                                char * etiqueta = concatenaInt("$l", netiquetas);
                                netiquetas++;

                                concatenarCuadrupla($3, crearCuadrupla(strdup("beqz"), obtenerTemp($3), etiqueta, NULL));
                                liberarReg(obtenerTemp($3));
                                concatenarCodigo($3, $6);
                                concatenarCuadrupla($3, crearCuadrupla(etiqueta, NULL, NULL, NULL));
                                $$ = $3;
                            }
                    |   MIENTRAS PARI boolean_expression PARD HACER statement
                            {
                                /*printf("statement -> mientras expression hacer statement\n");*/
                                char * etiqueta1 = concatenaInt("$l", netiquetas);
                                char * etiqueta2 = concatenaInt("$l", netiquetas+1);
                                netiquetas+=2;

                                codigo mientras = crearCodigo();
                                concatenarCuadrupla(mientras, crearCuadrupla(etiqueta1, NULL, NULL, NULL));
                                concatenarCodigo(mientras, $3);
                                concatenarCuadrupla(mientras, crearCuadrupla(strdup("beqz"), obtenerTemp($3), etiqueta2, NULL));
                                liberarReg(obtenerTemp($3));
                                concatenarCodigo(mientras, $6);
                                concatenarCuadrupla(mientras, crearCuadrupla(strdup("b"), etiqueta1, NULL, NULL));
                                concatenarCuadrupla(mientras, crearCuadrupla(etiqueta2, NULL, NULL, NULL));

                                $$ = mientras;
                            }
                    |   HACER statement MIENTRAS PARI boolean_expression PARD
                            {
                                char * etiqueta1 = concatenaInt("$l", netiquetas);
                                netiquetas++;

                                codigo hacer = crearCodigo();
                                concatenarCuadrupla(hacer, crearCuadrupla(etiqueta1, NULL,NULL,NULL));
                                concatenarCodigo(hacer, $2);
                                concatenarCodigo(hacer, $5);
                                concatenarCuadrupla(hacer, crearCuadrupla(strdup("bnez"), obtenerTemp($5), etiqueta1, NULL));
                                liberarReg(obtenerTemp($5));

                                $$ = hacer;
                            }
                    |   PARA PARI ID ASSIGN expression PYC boolean_expression PYC expression PARD HACER statement
                            {
                                char * etiqueta1 = concatenaInt("$l", netiquetas);
                                char * etiqueta2 = concatenaInt("$l", netiquetas+1);
                                char * etiqueta3 = concatenaInt("$l", netiquetas+2);
                                netiquetas+=3;

                                codigo para = crearCodigo();
                                // Inicializar
                                char* id = concatena("_", $3);
                                if (!recuperaVar(variables, id)){
                                    fprintf(stderr, "La variable %s no ha sido declarada (línea %d)\n", $3, yylineno);
                                    errores++;
                                } else {
                                    //concatenarCuadrupla(para, crearCuadrupla("HOLAA", NULL, NULL, NULL));
                                    concatenarCodigo(para, $5);
                                    cuadrupla store = crearCuadrupla(strdup("sw"), obtenerTemp($5), id, NULL);
                                    concatenarCuadrupla(para, store);
                                }
                                concatenarCuadrupla(para, crearCuadrupla(etiqueta1, NULL,NULL,NULL));
                                // Condicion;
                                concatenarCodigo(para, $7);
                                concatenarCuadrupla(para, crearCuadrupla(strdup("beqz"), obtenerTemp($7), etiqueta2, NULL));
                                liberarReg(obtenerTemp($7));
                                // Cuerpo for
                                concatenarCodigo(para, $12);
                                // Actualizacion
                                concatenarCodigo(para, $9);
                                concatenarCuadrupla(para, crearCuadrupla(strdup("sw"), obtenerTemp($9), id, NULL));
                                liberarReg(obtenerTemp($9));
                                // Continuar
                                concatenarCuadrupla(para, crearCuadrupla(strdup("b"), etiqueta1, NULL, NULL));
                                concatenarCuadrupla(para, crearCuadrupla(etiqueta2, NULL, NULL, NULL));
                                $$ = para;

                            }
                    |   IMPRIMIR print_list PYC
                            {
                                /*printf("statement -> imprimir print_list\n");*/
                                $$ = $2;
                            }
                    |   LEER read_list PYC
                            {
                                /*printf("statement -> leer read_list\n");*/
                                $$ = $2;
                            }
                    |   error PYC
                            {
                                fprintf(stderr, "\tError sintáctico en sentencia.\n");
                                errores++;
                                $$ = crearCodigo();
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
                                concatenarCuadrupla(imprime, crearCuadrupla(strdup("move"), strdup("$a0"), obtenerTemp($1), NULL));
                                concatenarCuadrupla(imprime, crearCuadrupla(strdup("li"), strdup("$v0"), concatenaInt("", 1), NULL));
                                concatenarCuadrupla(imprime, crearCuadrupla(strdup("syscall"), NULL, NULL, NULL));
                                liberarReg(obtenerTemp($1));

                                concatenarCodigo($1, imprime);
                                $$ = $1;
                            }
                    |   CADENA
                            {
                                /*printf("print_item -> cadena [%s]\n", $1);*/
                                char * aux = concatenaInt(strdup("$str"), ncadenas);
                                cadenas = crearCad(cadenas, &aux, $1);
                                if (!strcmp(concatenaInt(strdup("$str"), ncadenas), aux)) {
                                    ncadenas++;
                                }
                                codigo imprime = crearCodigo();
                                concatenarCuadrupla(imprime, crearCuadrupla(strdup("la"), strdup("$a0"), aux, NULL));
                                concatenarCuadrupla(imprime, crearCuadrupla(strdup("li"), strdup("$v0"), concatenaInt("", 4), NULL));
                                concatenarCuadrupla(imprime, crearCuadrupla(strdup("syscall"), NULL, NULL, NULL));

                                $$ = imprime;
                            }
                    ;
read_list           :   ID
                            {
                                /*printf("read_list-> id [%s]\n", $1);*/
                                char* aux = concatena("_", $1);
                                if (!recuperaVar(variables, aux)){
                                    fprintf(stderr, "La variable %s no ha sido declarada (línea %d)\n", $1, yylineno);
                                    $$ = crearCodigo();
                                    errores++;
                                } else {
                                    codigo lee = crearCodigo();
                                    concatenarCuadrupla(lee, crearCuadrupla(strdup("li"), strdup("$v0"), concatenaInt("", 5), NULL));
                                    concatenarCuadrupla(lee, crearCuadrupla(strdup("syscall"), NULL, NULL, NULL));
                                    concatenarCuadrupla(lee, crearCuadrupla(strdup("sw"), strdup("$v0"), aux, NULL));

                                    $$ = lee;
                                }
                            }
                    |   read_list COMA ID
                            {
                                /*printf("read_list-> read_list , id [%s]\n", $3);*/
                                char* aux = concatena("_", $3);
                                if (!recuperaVar(variables, aux)){
                                    fprintf(stderr, "La variable %s no ha sido declarada (línea %d)\n", $3, yylineno);
                                    $$ = $1;
                                    errores++;
                                } else {
                                    codigo lee = crearCodigo();
                                    concatenarCuadrupla(lee, crearCuadrupla(strdup("li"), strdup("$v0"), concatenaInt("", 5), NULL));
                                    concatenarCuadrupla(lee, crearCuadrupla(strdup("syscall"), NULL, NULL, NULL));
                                    concatenarCuadrupla(lee, crearCuadrupla(strdup("sw"), strdup("$v0"), aux, NULL));

                                    concatenarCodigo($1, lee);
                                    $$ = $1;
                                }
                            }
                    ;
boolean_expression  :   boolean_expression IGUAL boolean_expression
                            {
                                // seq
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla(strdup("seq"), reg, obtenerTemp($1), obtenerTemp($3));
                                liberarReg(obtenerTemp($1));
                                liberarReg(obtenerTemp($3));
                                concatenarCodigo($1, $3);
                                concatenarCuadrupla($1, aux);
                                $$ = $1;
                            }
                    |   boolean_expression MENOR MAYOR boolean_expression
                            {
                                // sne
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla(strdup("sne"), reg, obtenerTemp($1), obtenerTemp($4));
                                liberarReg(obtenerTemp($1));
                                liberarReg(obtenerTemp($4));
                                concatenarCodigo($1, $4);
                                concatenarCuadrupla($1, aux);
                                $$ = $1;
                            }
                    |   boolean_expression MAYOR boolean_expression
                            {
                                // sgt
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla(strdup("sgt"), reg, obtenerTemp($1), obtenerTemp($3));
                                liberarReg(obtenerTemp($1));
                                liberarReg(obtenerTemp($3));
                                concatenarCodigo($1, $3);
                                concatenarCuadrupla($1, aux);
                                $$ = $1;
                            }
                    |   boolean_expression MENOR boolean_expression
                            {
                                // slt
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla(strdup("slt"), reg, obtenerTemp($1), obtenerTemp($3));
                                liberarReg(obtenerTemp($1));
                                liberarReg(obtenerTemp($3));
                                concatenarCodigo($1, $3);
                                concatenarCuadrupla($1, aux);
                                $$ = $1;
                            }
                    |   boolean_expression MAYOR IGUAL boolean_expression
                            {
                                // sge
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla(strdup("sge"), reg, obtenerTemp($1), obtenerTemp($4));
                                liberarReg(obtenerTemp($1));
                                liberarReg(obtenerTemp($4));
                                concatenarCodigo($1, $4);
                                concatenarCuadrupla($1, aux);
                                $$ = $1;
                            }
                    |   boolean_expression MENOR IGUAL boolean_expression
                            {
                                // sle
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla(strdup("sle"), reg, obtenerTemp($1), obtenerTemp($4));
                                liberarReg(obtenerTemp($1));
                                liberarReg(obtenerTemp($4));
                                concatenarCodigo($1, $4);
                                concatenarCuadrupla($1, aux);
                                $$ = $1;
                            }
                    |   NOT boolean_expression
                            {
                                cuadrupla aux = crearCuadrupla(strdup("xori"), obtenerTemp($2), obtenerTemp($2), strdup("1"));
                                $$ = $2;
                                concatenarCuadrupla($$, aux);
                            }
                    |   expression
                            {
                                $$ = $1;
                            }
                    ;

expression          :   expression MAS expression
                            {
                                /*printf("expression -> expression + expression\n");*/
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla(strdup("add"), reg, obtenerTemp($1), obtenerTemp($3));
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
                                cuadrupla aux = crearCuadrupla(strdup("sub"), reg, obtenerTemp($1), obtenerTemp($3));
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
                                cuadrupla aux = crearCuadrupla(strdup("mult"), reg, obtenerTemp($1), obtenerTemp($3));
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
                                cuadrupla aux = crearCuadrupla(strdup("div"), reg, obtenerTemp($1), obtenerTemp($3));
                                liberarReg(obtenerTemp($1));
                                liberarReg(obtenerTemp($3));
                                concatenarCodigo($1, $3);
                                concatenarCuadrupla($1, aux);
                                $$ = $1;
                            }
                    |   MENOS expression %prec UMENOS
                            {
                                /*printf("expression -> - expression\n");*/
                                cuadrupla aux = crearCuadrupla(strdup("neg"), obtenerTemp($2), obtenerTemp($2), NULL);
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
                                    fprintf(stderr, "La variable %s no ha sido declarada (línea %d)\n", $1, yylineno);
                                    $$ = crearCodigo();
                                    errores++;
                                }
                                else {
                                  char * reg = obtenerReg();
                                  cuadrupla aux = crearCuadrupla(strdup("lw"), reg, iden, NULL);
                                  $$ = crearCodigo();
                                  concatenarCuadrupla($$, aux);
                                }
                            }
                    |   NUM
                            {
                                /*printf("expression -> num [=%d]\n", $1);*/
                                char * reg = obtenerReg();
                                cuadrupla aux = crearCuadrupla(strdup("li"), reg, concatenaInt("", $1), NULL);
                                $$ = crearCodigo();
                                concatenarCuadrupla($$, aux);
                            }
                    ;

%%

/* Tratamiento de errores */
void yyerror(char const *msg) {
    fprintf(stderr, "Error sintáctico (línea %d): %s\n", yylineno, msg);
    errores++;
}

int main(int argc, char const *argv[]) {

    if (argc < 2 || argc > 4) {
        printf("Uso: %s <fichero> [-o <nombre fichero de salida>]\n", argv[0]);
        exit(1);
    }

    FILE *f_in = fopen(argv[1], "r");
    if (f_in == NULL) {
        printf("Archivo %s no existe\n", argv[1]);
        exit(2);
    }

    yydebug=0; //Para que no salga el debug
    yyin = f_in;
    
    if (argc==2) ficheroSalida = "codigo.s";
    else ficheroSalida = argv[3];
    
    yyparse();

    fclose(f_in);
    borrarTablaVar(variables);
    borrarTablaCad(cadenas);
    return 0;
}
