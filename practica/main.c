#include "lexico.h"
#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin;
extern int yylex();

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

    yyin = f_in;
    int token;
    while ((token = yylex())) {
        printf("Token: %d\n", token);
    }

    fclose(f_in);
    return 0;
}
