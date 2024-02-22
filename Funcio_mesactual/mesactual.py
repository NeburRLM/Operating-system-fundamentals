#!/usr/bin/env python3

# 3.- Crearem una funció en bash mesactual.sh i en python mesactual.py que compari la data de modificació de dos arxius i 
# ens escrigui per la sortida estàndard la ruta absoluta de l'arxiu modificat més actual.


import os
import sys


def mesactual(fitxer1, fitxer2):		#declaració de la funció mesactual    
    
    if os.path.getmtime(fitxer1) > os.path.getmtime(fitxer2):	#comprovem si un arxiu és més recent que un altre
        print(os.path.abspath(fitxer1))				#imprimim el path del fitxer 1 en cas de que aquest sigui el més recent
    else:
        print(os.path.abspath(fitxer2))				#sinò, imprimim el path del fitxer 2 en cas de que aquest sigui el més recent

mesactual("compfitxer1.fitxer", "compfitxer2.fitxer")
