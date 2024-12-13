#include <stdio.h>
#include <stdlib.h>

/* Pre: L[0]..L[i-1] está ordenada.
 * Post: L[0]..L[i] está ordenada y contiene los mismos elementos
 *   	que estaban en L[0]..L[i-1] más el elemento que estaba en i.
 */
void insertar_ordenado(int L[], size_t i) {
    int v = L[i];
    int j = i - 1;
    while (j >= 0 && L[j] > v) {
        L[j + 1] = L[j];
        j--;
    }
    L[j + 1] = v;
}

/*
 * Ordena una lista de elementos según el método de inserción.
 * Pre: los elementos de la lista deben ser comparables.
 * Post: la lista está ordenada.
 */
void ordenar_insercion(int L[], size_t n) {
    for (size_t i = 1; i < n; i++) { //aranca desde el segundo elemento del arreglo
        insertar_ordenado(L, i);
    }
}


int main(void){
    
    int l[] = {20, -6, 5, 9, 8, -2, 0};
    size_t largo = sizeof(l)/sizeof(int);
    for (size_t i = 0; i < largo; i++){
        fprintf(stderr,"%d\t", l[i]);
    }
    printf("\n\n");
    ordenar_insercion(l, largo);
    
    for (size_t i = 0; i < largo; i++){
        fprintf(stderr,"%d\t", l[i]);
    }
    putchar('\n');
    
    return 1;
}