#ifndef __LISTAVAR__
#define __LISTAVAR__

typedef struct varRep *lista;

lista crearVar(lista l, char *x, int valor);
int recuperaVar(lista l, char *x);
void borrar(lista l);

#endif
