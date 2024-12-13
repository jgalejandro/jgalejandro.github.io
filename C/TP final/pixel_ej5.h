#ifndef PIXEL_H
#define PIXEL_H

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdint.h>

typedef uint32_t pixel_t;

typedef uint8_t componente_t;

pixel_t pixel_desde_rgb(componente_t rojo, componente_t verde, componente_t azul);

componente_t pixel_get_rojo(pixel_t p);

componente_t pixel_get_verde(pixel_t p);

componente_t pixel_get_azul(pixel_t p);

#endif