#!/bin/bash

# 3.- Crearem una funció en bash mesactual.sh i en python mesactual.py que compari la data de modificació de dos arxius i 
# ens escrigui per la sortida estàndard la ruta absoluta de l'arxiu modificat més actual.


mesactual() {					#declaració de la funció mesactual 
    	if [ "$1" -nt "$2" ]; then		#comprovem si un arxiu és més recent que un altre
        	echo "$(realpath "$1")"		#imprimim el path del fitxer 1 en cas de que aquest sigui el més recent
    	else
        	echo "$(realpath "$2")"		#sinò, imprimim el path del fitxer 2 en cas de que aquest sigui el més recent
    	fi
}

mesactual "compfitxer1.fitxer" "compfitxer2.fitxer"

