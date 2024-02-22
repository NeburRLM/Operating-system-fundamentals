#!/usr/bin/env python3


import subprocess
import os
import sys
from pathlib import Path
from decimal import Decimal


def compfitxer(file1, file2):	#declaracio de la funció compfitxer
   # Obrim els dos fitxers en mode lectura que rebem 
   with open(file1, 'r') as f1, open(file2, 'r') as f2:
      content1 = f1.readlines()
      content2 = f2.readlines()
      #les línies que no son buides les guardem en cada variable segons el fitxer 1 o 2
      lines1 = [line.strip() for line in content1 if line.strip() and not line.isspace()]
      lines2 = [line.strip() for line in content2 if line.strip() and not line.isspace()]
      #guarda la quantitat màxima de línies entre els dos fitxers
      total = max(len(lines1), len(lines2)) 
 
   # Obtenim les diferències de línies diferents entre els dos fitxers sense tenir en compte majúsucules/minúscules, caràcters en blanc, línies en blanc, les línies que contenen un espai en blanc
   diff_output = subprocess.run(['diff', '-i', '-b', '-B', '--ignore-matching-lines="^\s*$"', file1, file2], capture_output=True, text=True)

   # Separem la sortida del diff anterior en una llista de cadenes de text, on cada cadena representa una líniea de la sortida
   diff_lines = diff_output.stdout.split('\n')
   #Guardem només les línies no buides de la sortida de diff_lines
   non_empty_lines = [line for line in diff_lines if line.strip()]
   #De la sortida anterior, separem les diferències del fitxer1 i del fitxer2 en dues variables diferents
   liniesDif_primerF = len([line for line in non_empty_lines if line.startswith('>')])
   liniesDif_segonF = len([line for line in non_empty_lines if line.startswith('<')])
   #Sumem les diferències del fitxer1 i del fitxer2 per saber la quantitat total de diferències entre els dos fitxers
   linies_dif = liniesDif_primerF + liniesDif_segonF
   # Calcula el número de líneas iguals
   linies_iguals = total - linies_dif

   # Calcula el percentatge de similitud
   simil = int((linies_iguals / total) *100)
   if simil < 0:
      simil=0
   # Mostrar el percentatge de similitud y las líneas diferentes (que no siguin buides)
   print(f"Porcentaje de similitud: {simil:d}%")
   print("Líneas diferents:")
   for line in non_empty_lines[1:]:
      print(line)
 
    
    


def compdir(dir1, dir2):	#declaracio de la funció compdir
    arxiu_recent = ""		#inicialitzem la variable arxiu_recent
    for arxiu1 in os.listdir(dir1):	# Itera sobre cada fitxer en el directorio dir1	
        nom1 = os.path.basename(arxiu1)	# Obtenim el nom de l'arxiu
        arxiu1 = os.path.join(dir1, nom1) # Combina el nom de l'arxiu amb el primer directori per obtenir la ruta completa 
        arxiu2 = os.path.join(dir2, nom1) # Combina el nom de l'arxiu amb el segon directori per obtenir la ruta completa 
        if os.path.isfile(arxiu2):	#Verifica si el segon arxiu existeix
            compfitxer(arxiu1, arxiu2)	# Si existeix, cridem a la funció compfitxer per comparar els dosfitxers
            if os.path.getmtime(arxiu1) > os.path.getmtime(arxiu2):	#Verifiquem si el fitxer1 és més recent que el fitxer2
                arxiu_recent = os.path.realpath(arxiu1)
            else:							#Si no es compleix, el fitxer2 serà més recent que el fitxer1
                arxiu_recent = os.path.realpath(arxiu2)

    if not arxiu_recent:						#Si la variable arxiu_recent es buida, significarà que no s'ha trobat cap fitxer en comú
        print("No s'ha trobat cap fitxer en comú")
    else:
        with open("recents.log", "a") as f:				#En cas contrari, escriurà al fitxer recents.log el path del fitxer més recent, obtingut anteriorment	
            f.write(arxiu_recent + "\n")



def comptot(directori1, directori2):
    # Obté la llista de directoris especificada pel primer argument (directori1)
    dir_list1 = [dirpath for dirpath, dirnames, filenames in os.walk(os.path.abspath(directori1))]

    # Obté la llista de directoris especificada pel segon argument (directori2)
    dir_list2 = [dirpath for dirpath, dirnames, filenames in os.walk(os.path.abspath(directori2))]

    # Iterar sobre la llista de directoris del primer argument
    for dir1 in dir_list1:
        # Iterar sobre la llista de directoris del segon argument
        for dir2 in dir_list2:
            # Per cada directori1, mirar si té el mateix nom en el directori2
            dir1_base = os.path.basename(dir1)
            dir2_base = os.path.basename(dir2)
            if dir1_base == dir2_base:
                # Si els noms dels directoris coincideixen, cridem a la funció compdir per comparar el seu contingut
                compdir(dir1, dir2)

    # Calcular el percentatge de similitud entre els dos directoris rebuts com a paràmetre
    # Per diferenciar aquesta part, desarem l'argument1 i l'argument2 a la variable ruta1 i ruta2 respectivament
    ruta1 = directori1
    ruta2 = directori2
    
    # Calcula el número total de fitxers y directoris en ambdues rutas 
    total = subprocess.check_output(f"find {ruta1} {ruta2} -type f -o -type d | sort | uniq | wc -l", shell=True, universal_newlines=True)

    # Obté el número total de fitxers i directoris que es troben en els dos doriectoris especificats de entrada en les variables ruta1 i ruta2
    coincidents = int(subprocess.check_output(f"/bin/bash -c 'comm -12 <(cd {ruta1}; find . -type f -o -type d | sort) <(cd {ruta2}; find . -type f -o -type d | sort) | wc -l'", shell=True, universal_newlines=True))
    #print (coincidents)
	
    # Calcula el percentatge de similitud a partir dels elements coincidents i el total d'elements calculat anteriorment
    similitud = Decimal(coincidents) * Decimal(100) / Decimal(total)
    
    # Convertim el percentatge anterior en una cadena de caràcters de dos decimals
    similitud_str = "{:.2f}".format(similitud)

    print(f"La similitud entre {ruta1} y {ruta2} es del {similitud:.2f}%")






comptot("dir1","dir2")



