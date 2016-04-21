#include "listaVar.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct varRep{
    char *nombre;
    struct varRep *sig;
};


lista crearVar(lista l, char *x){
    struct varRep *nuevo = (struct varRep*)malloc(sizeof(struct varRep));
    if (nuevo == NULL) {
        fprintf(stderr, "Sin memoria!\n");
        exit(1);
    }
    if (!recuperaVar(l, x)) {
        nuevo->sig = l;
        nuevo->nombre = x;
    } else {
        fprintf(stderr, "Nombre de variable ya usado\n");
        exit(2);
    }

    return nuevo;
}

int recuperaVar(lista l, char *x){
    struct varRep *n = l;
    while(n != NULL) {
        if (!strcmp(n->nombre, x)) {
            // Encontrada!
            return 1;
        }
        n = n->sig;
    }
    // La variable no está.
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
