#include "codigo.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char registros[] = { 0,0,0,0,0,0,0,0,0,0 };

struct cuadrupla {
  char *operacion;
  char *resultado;
  char *argumento1;
  char *argumento2;
  cuadrupla siguiente;
};

struct codigo {
  cuadrupla primera;
  cuadrupla ultima;
  char *resultado;
};

char * concatena(char* pref, char* suf){
    char aux[32];
    snprintf(aux, 32, "%s%s", pref, suf);
    return strdup(aux);
}

char * concatenaInt(char* pref, int valor){
    char aux[8];
    snprintf(aux, 8, "%s%d", pref, valor);
    return strdup(aux);
}

cuadrupla crearCuadrupla(char *op, char* res, char* arg1, char* arg2){
    cuadrupla nueva = (cuadrupla)malloc(sizeof(struct cuadrupla));
    if (nueva == NULL) {
        fprintf(stderr, "Sin memoria!\n");
        exit(1);
    }
    nueva->operacion = op;
    nueva->resultado = res;
    nueva->argumento1 = arg1;
    nueva->argumento2 = arg2;
    nueva->siguiente = NULL;

    return nueva;
}

codigo crearCodigo() {
    codigo nuevo = (codigo)malloc(sizeof(struct codigo));
    if (nuevo == NULL) {
        fprintf(stderr, "Sin memoria!\n");
        exit(1);
    }
    nuevo->primera = NULL;
    nuevo->ultima = NULL;
    nuevo->resultado = NULL;
    return nuevo;
}

codigo concatenarCuadrupla(codigo l, cuadrupla c){
    if (l->primera == NULL) {
        l->primera = c;
        l->ultima = c;
        l->resultado = c->resultado;
    } else {
        l->ultima->siguiente = c;
        l->ultima = c;
        l->resultado = c->resultado;
    }
    return l;
}

// Concatenar listas
codigo concatenarCodigo(codigo l1, codigo l2){
    if (l1->primera == NULL) {
        return l2;
    } else if (l2->primera == NULL) {
        return l1;
    } else {
        l1->ultima->siguiente = l2->primera;
        l1->ultima = l2->ultima;
        l1->resultado = l2->resultado;
        return l1;
    }
}

// Obtener registro libre
char * obtenerReg(){
    for (int i = 0; i < 10; i++) {
        if (!registros[i]) {
            registros[i] = 1;
            return concatenaInt("$t", i);
        }
    }
    fprintf(stderr, "No quedan registros disponibles\n");
    exit(3);
}

void liberarReg(char *r){
    int reg = r[2]-'0';
    registros[reg] = 0;
}

// Obtener registro temporal de codigo
char * obtenerTemp(codigo l){
    return l->resultado;
}

void imprimirCuadrupla(cuadrupla c) {
    if (c->operacion[0] == '$' && c->operacion[1] == 'l') {
        printf("%s:", c->operacion);
    } else {
        printf("\t%s", c->operacion);
        if (c->resultado != NULL) {
            printf(" %s", c->resultado);
        }
        if (c->argumento1 != NULL) {
            printf(", %s", c->argumento1);
        }
        if (c->argumento2 != NULL) {
            printf(", %s", c->argumento2);
        }
    }

    printf("\n");
}

void imprimirCodigo(codigo l){
    cuadrupla aux = l->primera;
    while(aux != NULL){
        imprimirCuadrupla(aux);
        aux = aux->siguiente;
    }
}
