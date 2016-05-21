programa main ();
var a, b, c, i: entero;
comienzo
   a:=1;
   b:=0;
   c:=3;
   
   para (i:=0; i<2; i+1) hacer
   comienzo
       si (not a) entonces imprimir "not", "\n";
       si (c = b) entonces imprimir "igual", "\n";
       si (a <> b) entonces imprimir "distinto", "\n";
       si (a > b) entonces imprimir "mayor", "\n";
       si (b < a) entonces imprimir "menor","\n";
       si (a >= b) entonces imprimir "mayorigual","\n";
       si (b <= a) entonces imprimir "menorigual","\n";
       si (a+b > c) entonces imprimir "complejo","\n";
       si-no imprimir "incomplejo","\n";
       imprimir "\n";
       a:=0;
       b:=4;
   fin;
   hacer
     comienzo
        imprimir "Bucle hacer ", a, "\n";
        a:=a+1;
     fin;
   mientras (a < 2)
fin.