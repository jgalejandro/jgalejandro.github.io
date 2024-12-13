#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <ctype.h>
#include <stdlib.h>

#define MASK_LSB 0x0000FF 
#define MASK_MEDSB 0x00FF00
#define MASK_MSB 0xFF0000 

#define SHIFT_MSB 16
#define SHIFT_MEDSB 8

void escribir_int16_little_endian(FILE *f, int16_t v){
    uint8_t vector [2];
    vector[0] = v & MASK_LSB;
    vector[1] = (v & MASK_MEDSB) >> SHIFT_MEDSB;

    uint16_t c = (vector[1] << SHIFT_MEDSB) | (vector[0]);

    fwrite(&c, sizeof(uint16_t), 1, f);
}

void escribir_int32_little_endian(FILE *f, int32_t v){
    uint8_t vector[3];
    vector[0] = (v & MASK_MSB) >> SHIFT_MSB;
    vector[1] = (v & MASK_MEDSB) >> SHIFT_MEDSB;
    vector[2] = v & MASK_LSB;
   
    int32_t bgr = (vector[0] << SHIFT_MSB)|(vector[1] << SHIFT_MEDSB)|(vector[2]);
    fwrite(&bgr, sizeof(int32_t), 1,f);
}




