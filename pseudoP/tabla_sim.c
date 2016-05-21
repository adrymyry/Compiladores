#include "tabla_sim.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct varRep{
    char *nombre;
    int linea;
    struct varRep *sig;
};

struct cadRep{
    char *nombre;
    char *contenido;
    struct cadRep *sig;
};

tablaVar crearVar(tablaVar t, char *x, int line){
    struct varRep *nuevo = (struct varRep*)malloc(sizeof(struct varRep));
    if (nuevo == NULL) {
        fprintf(stderr, "Sin memoria!\n");
        exit(1);
    }
    int comprueba = recuperaVar(t, x);
    if (!comprueba) {
        nuevo->sig = t;
        nuevo->nombre = x;
        nuevo->linea = line;
    } else {
        fprintf(stderr, "Nombre de variable ya usada en linea %d\n", comprueba);
        exit(2);
    }

    return nuevo;
}

int recuperaVar(tablaVar t, char *x){
    struct varRep *n = t;
    while(n != NULL) {
        if (!strcmp(n->nombre, x)) {
            // Encontrada!
            return n->linea;
        }
        n = n->sig;
    }
    // La variable no está.
    return 0;
}

void borrarTablaVar(tablaVar t){
    struct varRep *aux = t;
    while(t != NULL){
        t = aux->sig;
        free(aux->nombre);
        free(aux);
        aux = t;
    }
}

void imprimirTablaVarAux(tablaVar t) {
    if (t->sig!=NULL) {
        imprimirTablaVarAux(t->sig);
    }
    printf("%s:\n\t.word 0\n", t->nombre);

}

void imprimirTablaVar(tablaVar t){
    printf("\n#Variables globales\n");

    imprimirTablaVarAux(t);
    // while(t != NULL){
    //     printf("%s:\n\t.word 0\n", t->nombre);
    //     t = t->sig;
    // }
}

tablaCad crearCad(tablaCad t, char **x, char *c){
    char * aux = recuperaCad(t, c);
    if (aux!=NULL) {
        *x=aux;
        return t;
    }

    struct cadRep *nuevo = (struct cadRep*)malloc(sizeof(struct cadRep));
    if (nuevo == NULL) {
        fprintf(stderr, "Sin memoria!\n");
        exit(1);
    }

    nuevo->sig = t;
    nuevo->nombre = *x;
    nuevo->contenido = c;

    return nuevo;
}

char * recuperaCad(tablaCad t, char *c){
    struct cadRep *n = t;
    while(n != NULL) {
        if (!strcmp(n->contenido, c)) {
            // Encontrada!
            return n->nombre;
        }
        n = n->sig;
    }
    // La cadena no está.
    return NULL;
}

void borrarTablaCad(tablaCad t){
    struct cadRep *aux = t;
    while(t != NULL){
        t = aux->sig;
        free(aux->nombre);
        free(aux->contenido);
        free(aux);
        aux = t;
    }
}

void imprimirTablaCadAux(tablaCad t) {
    if (t->sig!=NULL) {
        imprimirTablaCadAux(t->sig);
    }
    printf("%s:\n\t.asciiz %s\n", t->nombre, t->contenido);

}

void imprimirTablaCad(tablaCad t){
    if (t!=NULL) {
        printf("#Cadenas del programa\n");
        imprimirTablaCadAux(t);
    }

    // while(t != NULL){
    //     printf("%s:\n\t.asciiz %s\n", t->nombre, t->contenido);
    //     t = t->sig;
    // }
}
