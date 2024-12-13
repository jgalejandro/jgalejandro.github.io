#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int partition(int *L, int left, int right);
void swap(int *a, int *b);
void quicksort(int *L, int start, int end);

int partition(int *L, int left, int right)
{
    int pivot = left;
    int p_val = L[pivot]; //pivote

    while (left < right)
    {
        while (L[left] <= p_val)
            left++;
        while (L[right] > p_val)
            right--;
        if (left < right)
            swap(&L[left], &L[right]);
    }
    swap(&L[pivot], &L[right]);
    return right;
}

void swap(int *a, int *b)
{
    int temp = *a;
    *a = *b;
    *b = temp;
}

void quicksort(int *L, int start, int end)
{
    if (start >= end)
        return;
    int splitPoint = partition(L, start, end); //pivote
    quicksort(L, start, splitPoint - 1);
    quicksort(L, splitPoint + 1, end);
}

int main (void){

    int l[] = {20, -6, 5, 9, 8, -2, 0};
    size_t largo = sizeof(l)/sizeof(int);
    for (size_t i = 0; i < largo; i++){
        fprintf(stderr,"%d\t", l[i]);
    }
    printf("\n\n");
    quicksort(l, 0, largo-1);
    
    for (size_t i = 0; i < largo; i++){
        fprintf(stderr,"%d\t", l[i]);
    }
    putchar('\n');   
    
    return 0;
}