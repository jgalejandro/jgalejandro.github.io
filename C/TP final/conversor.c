#include <stdio.h>
#include <stdint.h>
#include <ctype.h>
#include <stdlib.h>
#include "imagen_ej5.h"
#include "pixel_ej5.h"

int main(int argc, char *argv[]){
	if(argc != 4){
		fprintf(stderr, "[USO] ./name <file_input.ppm> <file_output.bmp> <file_output.ppm>\n");
		return 1;
	}
	
	FILE *f_t = fopen(argv[1], "rt");
	if(f_t == NULL){
		fprintf(stderr, "Ocurrio un error al abrir el archivo\n");
		return 1;
	}

	imagen_t *imagen = imagen_leer_PPM(f_t);

	if (imagen == NULL){
		fprintf(stderr,"Error al leer la imagen\n");
		return 1;
	}
	
	
	FILE *f_t2 = fopen(argv[2], "wt");
	if(f_t2 == NULL){
		fprintf(stderr, "ERROR\n");
		fclose(f_t);
		return 1;
	}

	imagen_escribir_PPM(imagen, f_t2);

	FILE *f_b = fopen(argv[2], "wb");
	if(f_b == NULL){
		fprintf(stderr, "Ocurrio un error\n");
		fclose(f_t);
		fclose(f_t2);
		return 1;
	}
	fprintf(stderr, "%zd %zd\n", imagen->ancho, imagen->alto);
	imagen_escribir_BMP(imagen, f_b);

	fclose(f_b);
	fclose(f_t);
	fclose(f_t2);
	imagen_destruir(imagen);
	return 0;
}