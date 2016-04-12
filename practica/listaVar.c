#include "listaVar.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct varRep{
    char *nombre;
    int valor;
    struct varRep *sig;
};


lista crearVar(lista l, char *x, int valor){
    struct varRep *nuevo = (struct varRep*)malloc(sizeof(struct varRep));
    if (nuevo == NULL) {
        fprintf(stderr, "Sin memoria!\n");
        exit(1);
    }
    nuevo->sig = l;
    nuevo->nombre = x;
    nuevo->valor = valor;
    return nuevo;
}

int recuperaVar(lista l, char *x){
    struct varRep *n = l;
    while(n != NULL) {
        if (!strcmp(n->nombre, x)) {
            // Encontrada!
            return n->valor;
        }
        n = n->sig;
    }
    // La variable no está. Considero que vale 0
    return 0;
}

void borrar(lista l){
    struct varRep *aux = l;
    while(l != NULL){
        l = aux->sig;
        free(aux->nombre);
        free(aux);
        aux = l;
    }
}
