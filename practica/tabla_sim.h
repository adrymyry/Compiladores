#ifndef __TABLA_SIM__
#define __TABLA_SIM__

typedef struct varRep *tablaVar;
typedef struct cadRep *tablaCad;

tablaVar crearVar(tablaVar t, char *x, int line);
int recuperaVar(tablaVar t, char *x);
void borrarTablaVar(tablaVar t);
void imprimirTablaVar(tablaVar t);

tablaCad crearCad(tablaCad t, char **x, char* c);
char * recuperaCad(tablaCad t, char *x);
void borrarTablaCad(tablaCad t);
void imprimirTablaCad(tablaCad t);


#endif
