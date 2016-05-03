#include "codigo.h"
#include <stdio.h>

int main(int argc, char const *argv[]) {

    codigo l = crearCodigo();
    for (int i = 0; i < 2; i++) {
        l = concatenarCuadrupla(l, crearCuadrupla("add", concatenaInt("", i), concatenaInt("", i-1), concatenaInt("", i+1)));
    }
    imprimirCodigo(l);
    printf("\n\n\n");
    codigo l2 = crearCodigo();
    for (int i = 0; i < 2; i++) {
        l2 = concatenarCuadrupla(l2, crearCuadrupla("mult", concatenaInt("", i), concatenaInt("", i-1), concatenaInt("", i+1)));
    }
    imprimirCodigo(l2);
    printf("\n\n\n");
    l = concatenarCodigo(l,l2);
    imprimirCodigo(l);
}
