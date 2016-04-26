#include "codigo.h"
#include <stdio.h>
#include <string.h>

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
