#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int *merge(int l1[], size_t n1, int l2[], size_t n2);
void mergesort(int l[], size_t n);
static int *mergesort_(int l[], size_t n);

static int *mergesort_(int l[], size_t n) {
    //Caso BASE.
    if(n == 1) {
        int *r = malloc(sizeof(int));
        *r = l[0];
        return r;
    }

    size_t medio = n / 2; //"parte al medio" el arreglo.
    int *izq = mergesort_(l, medio);
    int *der = mergesort_(l + medio, n - medio);

    int *completo = merge(izq, medio, der, n - medio); //ordena las partes.

    free(izq);
    free(der);

    return completo;
}

int *merge(int l1[], size_t n1, int l2[], size_t n2) {
    size_t i1;
    size_t i2;

    int *res = malloc((n1 + n2) * sizeof(int));
    if(res == NULL)
        return NULL;
    size_t i = 0;

    i1 = 0;
    i2 = 0;
    while(i1 < n1 && i2 < n2) {
        if(l1[i1] < l2[i2]) {
            res[i++] = l1[i1++];
        }
        else
            res[i++] = l2[i2++];
    }

    while(i1 < n1) {
        res[i++] = l1[i1++];
    }

    while(i2 < n2) {
        res[i++] = l2[i2++];
    }

    return res;
}

void mergesort(int l[], size_t n) {
    int *r = mergesort_(l, n);
    memcpy(l, r, n * sizeof(int));
    free(r);
}

int main (void){

    int l[] = {20, -6, 5, 9, 8, -2, 0};
    size_t largo = sizeof(l)/sizeof(int);
    for (size_t i = 0; i < largo; i++){
        fprintf(stderr,"%d\t", l[i]);
    }
    printf("\n\n");
    mergesort(l, largo);
    
    for (size_t i = 0; i < largo; i++){
        fprintf(stderr,"%d\t", l[i]);
    }
    putchar('\n');   
    return 0;
}