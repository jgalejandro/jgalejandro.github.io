#ifndef IMAGEN_H
#define IMAGEN_H

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdint.h>

typedef unsigned char pixeles_t;

typedef struct {
	pixeles_t **lienzo;
	size_t ancho, alto;
}imagen_t;

void imagen_destruir(imagen_t *imagen);

imagen_t *imagen_leer_PPM(FILE *f);

void imagen_escribir_PPM(const imagen_t *imagen, FILE *f);

imagen_t *imagen_recortar(const imagen_t *imagen, size_t x0, size_t y0, size_t ancho, size_t alto);

imagen_t *imagen_clonar(const imagen_t *imagen);

void imagen_escribir_BMP(const imagen_t *imagen, FILE *f);

#endif