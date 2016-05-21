programa prueba();
var a,,c: entero;
comienzo
    imprimir "Inicio del progama\n";
    a = 0; b :=0; c := 5+2-2;
    si (a) entonces imprimir "a","\n";
    si-no si (b) entonces imprimir "No a y no b\n";
        si-no mientras (c) hacer
            comienzo
                imprimir "c = ", c, "\n"
                c := c-2+1;
            fin;
    imprimir "Final","\n";
fin.