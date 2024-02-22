#!/usr/bin/env python3

import subprocess
import os
import sys
import shutil
from pathlib import Path
from decimal import Decimal




def tipus(path):
    val = 0
    if os.path.isfile(path):
        val = 1
    if os.path.isdir(path):
        val = 2
    if not os.path.isfile(path) and not os.path.isdir(path):
        val = 3
    return val


def mesactual(path1, path2):
    if os.path.getmtime(path1) > os.path.getmtime(path2):
        with open("recents.log", "w") as f:
            f.write(os.path.realpath(path1))
    else:
        with open("recents.log", "w") as f:
            f.write(os.path.realpath(path2))



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
   print(f"Percentatge de similitud: {simil:d}%")
   print("Líneas diferents:")
   for line in non_empty_lines[1:]:
      print(line)

   if tipus(fitxer1) == 1 and tipus(fitxer2) == 1:
      mesactual(fitxer1, fitxer2)

 
    
    


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




def creanou(path):
    with open('recents.log', 'r') as f:	#obrim el fitxer recents.log en mode lectura
        for linea in f:			#iterem sobre cada línea del fitxer recents.log
            ruta = linea.strip()	#obtenim cada ruta
            directorio_destino = os.path.join(path, *ruta.split('/')[1:-1]) #creem els directorios si no existen
            if not os.path.exists(directorio_destino):
                os.makedirs(directorio_destino)
            # Copiem els fitxers amb les dades de modificacions 
            archivo_origen = ruta
            archivo_destino = os.path.join(path, ruta.strip('/'))
            shutil.copy2(archivo_origen, archivo_destino)






if len(sys.argv) == 4:  # Comprobamos que el usuario ha introducido correctamente 3 argumentos
    # Guardamos los argumentos en dos variables para después, en caso de que sean ficheros, llamar a la función "mesactual" para guardar el fichero más reciente en un archivo de salida "recents.log".
    # Esto lo hacemos para diferenciar el $1 y $2 en caso de que sean directorios.
    global fitxer1
    fitxer1 = sys.argv[1]
    global fitxer2 
    fitxer2 = sys.argv[2]
    
    #Eliminem el fitxer recents.log per refresecar les sortides d'execucions anteriors 
    if os.path.exists("/home/milax/FSO/PRACTICA/p1/recents.log") and os.getcwd() == "/home/milax/FSO/PRACTICA/p1":
       os.remove("recents.log")
    # Comprobamos si los dos primeros argumentos son ficheros y el tercero es un directorio
    if tipus(sys.argv[1]) == 1 and tipus(sys.argv[2]) == 1 and tipus(sys.argv[3]) == 2:
        # En este caso, como los dos primeros argumentos serán ficheros, llamamos a la función "compfitxer" para que sólo se haga la comparación de estos dos ficheros.
        compfitxer(sys.argv[1], sys.argv[2])
        creanou(sys.argv[3])
    # Comprobamos si los dos primeros argumentos son directorios y el tercero es un directorio
    elif tipus(sys.argv[1]) == 2 and tipus(sys.argv[2]) == 2 and tipus(sys.argv[3]) == 2:
        # En este caso, como los dos primeros argumentos serán directorios, llamamos a la función "comptot" para que se haga la comparación a nivel de ficheros/directorios recursivamente.
        comptot(sys.argv[1], sys.argv[2])
        creanou(sys.argv[3])
    # Si no se cumple ninguna condición anterior, salimos de la ejecución.
    else:
        print("Has de passar fitxer/fitxer/directori o directori/directori/directori", file=sys.stderr)
        sys.exit(1)
else:
    # Si el usuario no pasa 3 argumentos, salimos de la ejecución.
    print("Error: has de passar 3 arguments", file=sys.stderr)
    sys.exit(1)




