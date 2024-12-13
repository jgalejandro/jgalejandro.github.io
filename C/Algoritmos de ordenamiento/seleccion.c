#include <stdio.h>
#include <stdlib.h>

void swap(int L[], size_t i, size_t j);
size_t pos_min(int L[], size_t desde, size_t hasta);
void ordenar_seleccion(int L[], size_t n);

/** Intercambia los elementos de L en los índices i y j */ 
void swap(int L[], size_t i, size_t j) {
    int aux = L[i];
    L[i] = L[j];
    L[j] = aux;
}

/** Devuelve la posición del elemento mínimo en L entre
 *  los índices `desde` y `hasta` (inclusive).  */
size_t pos_min(int L[], size_t desde, size_t hasta) {
    size_t pos_min = desde;
    for (size_t i = desde + 1; i <= hasta; i++) {
        if (L[i] < L[pos_min]) {
            pos_min = i;
        }
    }
    return pos_min;
}

/** Ordena una lista de elementos según el método de selección.
 *  Pre: los elementos de la lista deben ser comparables.
 *  Post: la lista está ordenada.  */
void ordenar_seleccion(int L[], size_t n) {
    for (size_t i = 0; i < n - 1; i++) {
        size_t p = pos_min(L, i, n - 1); //primero busca la poscion del valor minimo
        swap(L, p, i); //cambia las posiciones de ese elemento.
    }
}



int main (void){

    int l[] = {20, -6, 5, 9, 8, -2, 0};
    for (size_t i = 0; i < sizeof(l)/sizeof(int); i++){
        fprintf(stderr,"%d\t", l[i]);
    }
    printf("\n\n");
    ordenar_seleccion(l, 7);
    
    for (size_t i = 0; i < sizeof(l)/sizeof(int); i++){
        fprintf(stderr,"%d\t", l[i]);
    }
    putchar('\n');
    return 1;
}