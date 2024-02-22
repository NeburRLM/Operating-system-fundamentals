#!/bin/bash

# 1.- Crearem una funció bash tipus.sh que donat un arxiu que li passem per
# paràmetre ens retorna 1 si és de tipus fitxer, 2 si és de tipus directori i 3 si és
# de qualsevol altre tipus. (retorn de l’script, no per la sortida estàndard)

function tipus() {					#funció tipus
	if [ -f "$1" ]; then				#mira si el paràmetre que li passem és un fitxer
        	return 1				#si és un fitxer, retorna 1
	fi	
    	if [ -d "$1" ]; then				#mira si el paràmetre que li passem és un directori
        	return 2				#si es un directori, retorna 2
    	fi
	if ! [ -f "$1" ] && ! [ -d "$1" ]; then		#mira si el paràmetre que li passem no és ni un fitxer ni un directori
        	return 3				#si es compleix les condicions anteriors, retorna un 3
    	fi
}


#PROVA FUNCIONAMENT
tipus "provaTipus.fitxer"				#Cridem a la funció tipus i li passem un argument (fitxer)
echo "$?"						#Resulta de la prova = 1
	
tipus "provaTipus.directori"				#Cridem a la funció tipus i li passem un argument (directori)
echo "$?"						#Resulta de la prova = 2

tipus "noExisteix.???"					#Cridem a la funció tipus i li passem un argument (altre)
echo "$?"						#Resulta de la prova = 3

tipus "softlink.txt"					#Cridem a la funció tipus i li passem un fitxer especial (softlink)
echo "$?"						#Resulta de la prova = 1
