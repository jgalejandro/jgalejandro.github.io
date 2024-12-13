#ifndef FORMATO_EJ5_H
#define FORMATO_EJ5_H

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <ctype.h>
#include <stdlib.h>

#define MASK_LSB 0xFF
#define MASK_MSB 0xFF00
#define MASK_MSB32 0xFF000000
#define MASK_LSB32 0xFF0000
#define SHIFT_1BT 8
#define SHIFT_3BT 24

void escribir_int16_little_endian(FILE *f, int16_t v);

void escribir_int32_little_endian(FILE *f, int32_t v);

#endif