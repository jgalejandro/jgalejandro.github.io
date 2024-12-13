#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include "pixel_ej5.h"
#include "formato_ej5.h"

#define FORMATO "P3"
#define MAXIMO 255

//typedef unsigned char pixeles_t;

typedef struct {
	pixel_t **lienzo;
	size_t ancho, alto;
}imagen_t;

void imagen_destruir(imagen_t *imagen){
	for(size_t i = 0; i < imagen->alto; i++){
		free(imagen->lienzo[i]);
	}
	free(imagen->lienzo);
	free(imagen);
}

imagen_t *_imagen_crear(size_t ancho, size_t alto){
	imagen_t *imagen = malloc(sizeof(imagen_t));
	if(imagen == NULL){
		return NULL;
	}
	imagen->ancho = ancho;
	imagen->alto = alto;
	imagen->lienzo = malloc(alto * sizeof(pixel_t *));
	if(imagen->lienzo == NULL){
		free(imagen);
		return NULL;
	}
	for(size_t i = 0; i < alto; i++){
		imagen->lienzo[i] = malloc(ancho * sizeof(pixel_t));
		if(imagen->lienzo[i] == NULL){
			imagen_destruir(imagen);
			return NULL;
		}
	}
	return imagen;
}

static int leer_entero(FILE *f){
	int c, aux;
	char str[20];
	size_t i = 0;
	while((c = fgetc(f)) != EOF){
		if(c == '#'){
			while(fgetc(f) != '\n'){}
			continue;
		}
		if(isspace(c) != 0){
			continue;
		}
		if(isdigit(c)){
			str[i++] = c;
			while((aux = fgetc(f)) != EOF){
				if(i > 20){
					return -1;
				}
				if(isspace(aux) != 0){
					str[i++] = '\0';
					return atoi(str);
				}
				str[i++] = aux;
			}
		}
	}
	return -1;
}

imagen_t *imagen_leer_PPM(FILE *f){

    imagen_t* lectura;
    char aux[100];
    fgets(aux, 100, f);
    if(!strcmp("P3",aux)){
        fprintf(stderr, "No es un PPM\n");
        return NULL;
    }
   size_t ancho =leer_entero(f);
   size_t alto = leer_entero(f);
   size_t max = leer_entero(f);

   if (max != 255){
       fprintf(stderr, "Maximo no Valido\n");
       return NULL;
   }
   

   lectura = _imagen_crear(ancho, alto);
   if (lectura == NULL){
	   return NULL;
   }
   

   for(size_t j = 0; j < alto; j++){
        for(size_t i = 0; i < ancho; i++){
            componente_t rojo = leer_entero(f);
            componente_t verde = leer_entero(f);
            componente_t azul = leer_entero(f); 
            lectura->lienzo[j][i] = pixel_desde_rgb(rojo, verde, azul);
        }
    }

   return lectura;
}

void imagen_escribir_PPM(const imagen_t *imagen, FILE *f){
    fprintf(f,"P3\n");
    fprintf(f,"%zd %zd 255\n", imagen->ancho, imagen->alto);
     for(int y = 0; y < imagen->alto; y++)
        for(int x = 0; x < imagen->ancho; x++) {
            pixel_t pixel = imagen->lienzo[y][x];
            fprintf(f,"%d %d %d\n", pixel_get_rojo(pixel), pixel_get_verde(pixel), pixel_get_azul(pixel));
        }
}

imagen_t *_imagen_cargar(imagen_t **imagen_aux, const imagen_t *imagen, size_t ancho, size_t alto, size_t x0, size_t y0){
	*imagen_aux = _imagen_crear(ancho, alto);
	if(*imagen_aux == NULL)
		return *imagen_aux;
		
	for(size_t i = 0; i < alto; i++)
		for(size_t j = 0; j < ancho; j++)
			(*imagen_aux)->lienzo[i][j] = imagen->lienzo[i + y0][j + x0];

	return *imagen_aux;	
}


imagen_t *imagen_recortar(const imagen_t *imagen, size_t x0, size_t y0, size_t ancho, size_t alto){
	size_t referencia_ancho = imagen->ancho - x0;
	size_t referencia_alto = imagen->alto - y0;
	
	imagen_t *n_imagen;
	
	if(imagen->ancho <= x0 || imagen->alto <= y0){
		return NULL;
	}
	
	if(referencia_ancho <= ancho && referencia_alto > alto){
		_imagen_cargar(&n_imagen, imagen, referencia_ancho, alto, x0, y0);
	}
	
	if(referencia_ancho  > ancho && referencia_alto <= alto){
		_imagen_cargar(&n_imagen, imagen, ancho, referencia_alto, x0, y0);
	}
	
	if(referencia_ancho >= ancho && referencia_alto >= alto){
		_imagen_cargar(&n_imagen, imagen, ancho, alto, x0, y0);	
	}
	
	if(referencia_ancho < ancho && referencia_alto < alto){
		_imagen_cargar(&n_imagen,imagen,referencia_ancho, referencia_alto, x0, y0);
	}
	
	return n_imagen;
}


imagen_t *imagen_clonar(const imagen_t *imagen){
	return imagen_recortar(imagen, 0, 0, imagen->ancho, imagen->alto);
}

void imagen_escribir_BMP(const imagen_t *imagen, FILE* f){
    char tipo[2] = "BM";
    int32_t tamano = 14 + 40 + imagen->alto * (imagen->ancho * 3 + (imagen->ancho*3)%4);
    int16_t reservado[2] = {0,0};
    int32_t offset = 54;
    int32_t tam_ancho_alto[3] = {40, imagen->ancho, imagen->alto};
    int16_t planos_bits[2] = {1,24};
    int32_t vector[6] = {0,0,0,0,0,0};

    fwrite(tipo,sizeof(char),2,f);
    escribir_int32_little_endian(f,tamano);
    fwrite(reservado,sizeof(int16_t),2,f);
    escribir_int32_little_endian(f, offset);
    
    for(size_t i = 0; i < 3; i++){
        int32_t v = tam_ancho_alto[i];
        escribir_int32_little_endian(f, v);        
    }
    for(size_t j = 0; j < 2; j++){
        int16_t w = planos_bits[j];
        escribir_int16_little_endian(f, w);        
    }
    fwrite(vector, sizeof(int32_t), 6, f);
    componente_t cero = 0;
   
    
    for(size_t j = imagen->alto ; j > 0; j--){
        for(size_t i = 0; i < imagen->ancho; i++){
                      
            int32_t x = imagen->lienzo[j-1][i]; 
            
            componente_t red = pixel_get_rojo(x);
            componente_t green = pixel_get_verde(x);
            componente_t blue = pixel_get_azul(x);
            
            fwrite(&blue, sizeof(componente_t),1,f);    
            fwrite(&green, sizeof(componente_t),1,f);
            fwrite(&red, sizeof(componente_t),1,f);
            
        }
        if((imagen->ancho*3)%4 == 0){
            continue;
        }
        for(size_t k = 0; k < 4-(imagen->ancho*3)%4; k++){
            fwrite(&cero, sizeof(componente_t),1,f);                               
 		}       
    }
}