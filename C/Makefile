PROGRAM = conversor_bmp
CFLAGS = -Wall -pedantic -std=c99 -g
CC = gcc

all : $(PROGRAM)

$(PROGRAM) : conversor.o formato_ej5.o pixel_ej5.o imagen_ej5.o 
	$(CC) $(CFLAGS) conversor.o formato_ej5.o pixel_ej5.o imagen_ej5.o -o $(PROGRAM) -lm

formato_ej5.o : formato_ej5.c formato_ej5.h
	$(CC) $(CFLAGS) -c formato_ej5.c

pixel_ej5.o : pixel_ej5.c pixel_ej5.h
	$(CC) $(CFLAGS) -c pixel_ej5.c 

imagen_t.o : imagen_ej5.c imagen_ej5.h pixel_ej5.h formato_ej5.h
	$(CC) $(CFLAGS) -c imagen_ej5.c

conversor.o : conversor.c imagen_ej5.h
	$(CC) $(CFLAGS) -c conversor.c 

clean :
	rm -vf *.o $(PROGRAM) 


