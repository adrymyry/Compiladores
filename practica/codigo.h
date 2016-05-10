#ifndef __CODIGO__
#define __CODIGO__

// Funciones concatenación de string
char * concatena(char* pref, char* suf);
char * concatenaInt(char* pref, int valor);


typedef struct cuadrupla *cuadrupla;
typedef struct codigo *codigo;

cuadrupla crearCuadrupla(char *op, char* res, char* arg1, char* arg2);
codigo crearCodigo();
// Añadir cuadrupla al final
codigo concatenarCuadrupla(codigo l, cuadrupla c);
// Concatenar listas
codigo concatenarCodigo(codigo l1, codigo l2);

// Obtener registro libre
char * obtenerReg();
void liberarReg(char *r);

// Obtener registro temporal de codigo
char * obtenerTemp(codigo l);
void imprimirCodigo(codigo l);

#endif
