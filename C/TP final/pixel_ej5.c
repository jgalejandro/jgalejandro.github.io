#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <ctype.h>
#include <stdlib.h>

#define MAX_ANCHO 1000
#define MAX_ALTO 1000
#define MASK_R 0XFF0000
#define MASK_G 0x00FF00
#define MASK_B 0x0000FF
#define SHIFT_R 16
#define SHIFT_G 8
#define SHIFT_B 0

typedef uint8_t componente_t;

typedef uint32_t pixel_t;

typedef pixel_t (*funcion_t)(pixel_t, int);

typedef enum{
    INVERTIR, SATURAR, CAMBIAR_GAMA, CAMBIAR_BRILLO, CAMBIAR_CONTRASTE, FILTRO_MEZCLAR, SEPIA, MONOCROMO, TOASTER, VALENCIA
}filtro_t;

static int leer_entero(FILE *f){
    int c, aux;
    char str[10];
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

pixel_t pixel_desde_rgb(componente_t rojo, componente_t verde, componente_t azul){
    return (rojo << SHIFT_R) | (verde << SHIFT_G) | (azul << SHIFT_B);
}

componente_t pixel_get_rojo(pixel_t p){
    return (p & MASK_R) >> SHIFT_R;
}

componente_t pixel_get_verde(pixel_t p){
    return (p & MASK_G) >> SHIFT_G;
}

componente_t pixel_get_azul(pixel_t p){
    return (p & MASK_B) >>SHIFT_B;
}

typedef struct {
    char nombre[30];
    pixel_t tonalidad;
}color_referencia_t;

color_referencia_t diccionario_color[] = {
    {"black", 0x000000},
    {"white", 0xFFFFFF},
    {"red", 0xFF0000},
    {"lime", 0x00FF00},
    {"bule", 0x0000FF},
    {"yellow",0xFFFF00},
    {"cyan", 0x00FFFF},
    {"magenta", 0xFF00FF},
    {"silver", 0xC0C0C0},
    {"grey", 0x808080},
    {"maroon", 0x800000},
    {"olive", 0x808000},
    {"green", 0x008000},
    {"purple", 0x800080},
    {"teal",  0x008080},
    {"neavy", 0x000080}
};

pixel_t pixel_desde_nombre(const char *nombre){
    for(size_t i = 0; i < sizeof(diccionario_color)/sizeof(diccionario_color[0]); i++){
        if(!strcmp(diccionario_color[i].nombre, nombre)){
            return diccionario_color[i].tonalidad;
        }
    }
    return diccionario_color[0].tonalidad;
}

void pixel_a_hsv(pixel_t p, short *h, float *s, float *v) {
    float rp = pixel_get_rojo(p) / 255.0;
    float vp = pixel_get_verde(p) / 255.0;
    float ap = pixel_get_azul(p) / 255.0;

    float cmax = rp > vp ? rp : vp;
    cmax = cmax > ap ? cmax : ap;

    float cmin = rp < vp ? rp : vp;
    cmin = cmin < ap ? cmin : ap;

    float delta = cmax - cmin;

    if(delta == 0)
        *h = 0;
    else if(cmax == rp)
        *h = (int)(60 * (vp - ap) / delta + 360.5) % 360;
    else if(cmax == vp)
        *h = (int)(60 * (ap - rp) / delta + 120.5) % 360;
    else
        *h = (int)(60 * (rp - vp) / delta + 240.5) % 360;

    *s = cmax == 0 ? 0 : (delta / cmax);
    *v = cmax;
}

pixel_t pixel_desde_hsv(short h, float s, float v) {
    float c = s * v;
    float x = c * (1 - fabs(fmodf(h / 60.0, 2) - 1));
    float m = v - c;

    float r = 0, v_ = 0, a = 0;

    if(h < 60)
        r = c, v_ = x;
    else if(h < 120)
        v_ = c, r = x;
    else if(h < 180)
        v_ = c, a = x;
    else if(h < 240)
        a = c, v_ = x;
    else if(h < 300)
        a = c, r = x;
    else
        r = c, a = x;

    return pixel_desde_rgb((r + m) * 255, (v_ + m) * 255, (a + m) * 255);
}


pixel_t filtro_invertir(pixel_t p, int _) {
    return pixel_desde_rgb(255 - pixel_get_rojo(p), 255 - pixel_get_verde(p), 255 - pixel_get_azul(p));
}

pixel_t filtro_saturar(pixel_t p, int porcentaje) {
    short h;
    float s, v;
    pixel_a_hsv(p, &h, &s, &v);

    s *= (1 + porcentaje / 100.0);

    if(s < 0)
        s = 0;
    else if(s > 1)
        s = 1;

    return pixel_desde_hsv(h, s, v);
}

pixel_t filtro_cambiar_gama(pixel_t p, int desplazamiento) {
    short h;
    float s, v;
    pixel_a_hsv(p, &h, &s, &v);

    h = (h + desplazamiento) % 360;

    return pixel_desde_hsv(h, s, v);
}

pixel_t filtro_cambiar_brillo(pixel_t p, int porcentaje) {
    short h;
    float s, v;
    pixel_a_hsv(p, &h, &s, &v);

    v += porcentaje / 100.;

    if(v < 0)
        v = 0;
    else if(v > 1)
        v = 1;

    return pixel_desde_hsv(h, s, v);
}

pixel_t filtro_cambiar_contraste(pixel_t p, int porcentaje) {
    short h;
    float s, v;
    pixel_a_hsv(p, &h, &s, &v);

    v *= 1 + porcentaje / 100.;

    if(v < 0)
        v = 0;
    else if(v > 1)
        v = 1;

    return pixel_desde_hsv(h, s, v);
}

pixel_t filtro_mezclar(pixel_t p, int color) {
    pixel_t c = color;

    return pixel_desde_rgb(
        (pixel_get_rojo(p) + pixel_get_rojo(c)) / 2,
        (pixel_get_verde(p) + pixel_get_verde(c)) / 2,
        (pixel_get_azul(p) + pixel_get_azul(c)) / 2);
}

pixel_t filtro_sepia(pixel_t p, int _) {
    componente_t r = pixel_get_rojo(p);
    componente_t v = pixel_get_verde(p);
    componente_t a = pixel_get_azul(p);

    int rn = r * 0.393 + v * 0.769 + a * 0.189;
    int vn = r * 0.349 + v * 0.686 + a * 0.168;
    int an = r * 0.272 + v * 0.534 + a * 0.131;

    if(rn > 255) rn = 255;
    if(vn > 255) vn = 255;
    if(an > 255) an = 255;

    return pixel_desde_rgb(rn, vn, an);
}

pixel_t filtro_monocromo(pixel_t p, int porcentaje_umbral) {
    short h;
    float s, v;
    pixel_a_hsv(p, &h, &s, &v);

    return (v > porcentaje_umbral / 100.) ? pixel_desde_rgb(255, 255, 255) : pixel_desde_rgb(0, 0, 0);
}

pixel_t filtro_toaster(pixel_t p, int _) {
    p = filtro_mezclar(p, pixel_desde_rgb(51, 0, 0));

    short h;
    float s, v;
    pixel_a_hsv(p, &h, &s, &v);

    v = v * 1.5 + 0.2;
    s *= 0.8;
    h = (h + 20) % 360;

    if(v > 1)
        v = 1;

    return pixel_desde_hsv(h, s, v);
}

pixel_t filtro_valencia(pixel_t p, int _) {
    float r = pixel_get_rojo(p) / 100.;
    float ve = pixel_get_verde(p) / 100.;
    float a = pixel_get_azul(p) / 100.;

    r = 0.23 + r - 2 * 0.23 * r;
    ve = 0.01 + ve - 2 * 0.01 * ve;
    a = 0.22 + a - 2 * 0.22 * a;

    if(r > 1) r = 1;
    if(ve > 1) ve = 1;
    if(a > 1) a = 1;

    if(r < 0) r = 0;
    if(ve < 0) ve = 0;
    if(a < 0) a = 0;

    p = filtro_mezclar(p, pixel_desde_rgb(r * 255, ve * 255, a * 255));

    short h;
    float s, v;
    pixel_a_hsv(p, &h, &s, &v);

    v = v * 1.08 - 0.08;
    if(v > 1)
        v = 1;
    if(v < 0)
        v = 0;

    p = pixel_desde_hsv(h, s, v);
    pixel_t c = filtro_sepia(p, 0);

    return pixel_desde_rgb(
        pixel_get_rojo(p) * 0.92 + pixel_get_rojo(c) * 0.08,
        pixel_get_verde(p) * 0.92 + pixel_get_verde(c) * 0.08,
        pixel_get_azul(p) * 0.92 + pixel_get_azul(c) * 0.08);
}

typedef struct{
    char nombre[30];
    int parametros;
    funcion_t filtro;
}conjuntof_t;


conjuntof_t filtros[] = {
    [INVERTIR] = {"invertir", 0, filtro_invertir},
    [SATURAR] = {"saturar", 1, filtro_saturar},
    [CAMBIAR_GAMA] = {"gama", 1, filtro_cambiar_gama},
    [CAMBIAR_BRILLO] = {"brillo", 1, filtro_cambiar_brillo},
    [CAMBIAR_CONTRASTE] = {"contraste", 1, filtro_cambiar_contraste},
    [FILTRO_MEZCLAR] = {"mezclar", 1, filtro_mezclar},
    [SEPIA] = {"sepia", 0, filtro_sepia},
    [MONOCROMO] = {"monocromo", 1, filtro_monocromo},
    [TOASTER] = {"toaster", 0, filtro_toaster},
    [VALENCIA] = {"valencia", 0, filtro_valencia}
};

bool cadena_a_filtro(const char *nombre, filtro_t *filtro){
    size_t n = sizeof(filtros)/sizeof(filtros[0]);
    for(size_t i = 0; i < n; i++){
        if(!strcmp(nombre,filtros[i].nombre)){
            *filtro = i;
            return true;
        }
    }
    return false;
}

int numero_de_parametros(filtro_t filtro){
    return filtros[filtro].parametros;
}

void aplicar_filtro(pixel_t imagen[MAX_ALTO][MAX_ANCHO], size_t ancho, size_t alto, filtro_t filtro, int parametro){
    for(size_t i = 0; i < alto; i++){
        for(size_t j = 0; j < ancho; j++){
            imagen[i][j] = filtros[filtro].filtro(imagen[i][j], parametro);
        }
    }   
}

bool leer_imagen(pixel_t imagen[MAX_ALTO][MAX_ANCHO], size_t *ancho, size_t *alto, FILE *f) {
    char aux[10];
    fgets(aux, 10, stdin);
    if(strcmp(aux, "P3\n"))
        return false;

    *ancho = leer_entero(f);
    *alto = leer_entero(f);
    int max = leer_entero(f);

    if(max != 255)
        return false;

    if(*ancho > MAX_ANCHO || *alto > MAX_ALTO)
        return false;

    for(int y = 0; y < *alto; y++)
        for(int x = 0; x < *ancho; x++) {
            componente_t rojo = leer_entero(f);
            componente_t verde = leer_entero(f);
            componente_t azul = leer_entero(f);
            imagen[y][x] = pixel_desde_rgb(rojo, verde, azul);
        }

    return true;
}

void imprimir_imagen(pixel_t imagen[MAX_ALTO][MAX_ANCHO], size_t ancho, size_t alto) {
    printf("P3\n");
    printf("%zd %zd 255\n", ancho, alto);

    for(int y = 0; y < alto; y++)
        for(int x = 0; x < ancho; x++) {
            pixel_t pixel = imagen[y][x];
            printf("%d %d %d\n", pixel_get_rojo(pixel), pixel_get_verde(pixel), pixel_get_azul(pixel));
        }
}


