#!/bin/bash

# 4.- Crearem una funció de la bash que compari dos directoris compdir.sh anivell de fitxers. Els directoris els rebrà per paràmetre. Per a fer-ho usarem la funció compfitxer.sh. 
# Aquesta funció crearà un arxiu recents.log amb la rutaabsoluta   dels   fitxers   modificats   més   recentment,   i   traurà   per   la   sortida
# estàndard el percentatge de similitud dels dos directoris.



function compfitxer() {				#declaració de la funció compfitxer
	# Obtenir el total de línies en ambdós fitxers (sense comptar línies en blanc ni caràcters buits d'una línia)
	#grep -> comanda de cerca segons uns patrons
	#-v -> opció de grep que inverteix la cerca, és a dir, selecciona totes les línies que no coincideixen amb el patró
	#-e -> opció de grep que permet especificar múltiples patrons
	#'^$'-> és un patró que representa una línia en blanc. ^ indica l'inici de la línia i $ indica el final de la línia
	#'^[[:space:]]*$'-> patró que representa una línia que conté caràcters en blanc. [[:space:]]* indica un conjunt de caràcters d'espai en blanc que poden aparèixer zero o més vegades, i ^ i $ indiquen l'inici i el final de la línia, respectivament.
	#wc -l -> conta les linies tenint en compte la sortida del pipe anterior
	total1=$(grep -v -e '^$' -e '^[[:space:]]*$' "$1" | wc -l)	#contem el número de línies del fitxer1 (sense tenir en compte les línies en blanc ni els caràcters en blanc)
	total2=$(grep -v -e '^$' -e '^[[:space:]]*$' "$2" | wc -l)	#contem el número de línies del fitxer2	 (sense tenir en compte les línies en blanc ni els caràcters en blanc)
	#echo "Total línies del fitxer 1: $total1"
	#echo "Total línies del fitxer 2: $total2"
	

	#Comprova si els fitxers son buits. Si ho son retornarà un error (això ho fem per a que la divisió posterior no doni error)
	if [[ $total1 -eq 0 && $total2 -eq 0 ]]; then
    		echo "Error: fitxers buits" >&2
    		exit 1
    	fi
	
	
	#mirem quin fitxer té més número de línies i ens quedarem amb el valor númeric que representarà les línies que es compararan
	if [ $total1 -ge $total2 ]; then	
  		linies_comp=$total1
	else
  		linies_comp=$total2
	fi
	#echo $linies_comp
		

	# Obtenir el nombre de línies diferents usant diff dels dos fitxers
	#-i -> fa que diff ignori les diferències entre majúscules i minúscules
	#-b -> fa que diff ignori els canvis als espais en blanc
	#-B -> fa que diff ignori les línies buides que només contenen espais en blanc
	#grep "^>" -> només té en compte les linies que treu diff amb > (que indica que es diferent la linea del fitxer2 amb la del fitxer1)
	#wc -l -> conta les linies tenint en compte la sortida del pipe anterior
	liniesDif_primerF=$(diff -i -b -B "$1" "$2" | grep "^>" | wc -l)	
	liniesDif_segonF=$(diff -i -b -B "$1" "$2" | grep "^<" | wc -l)
	linies_dif=$((liniesDif_primerF+liniesDif_segonF))	#calculem la suma total del número de línies diferents dels dos fitxers	
	#echo "$linies_dif"

	# Calcula el número de línies iguals sense tenir en compte les files en blanc, calculant la diferència de linies que es compararan (número de línies més gran entre els dos fitxers) i el número total de linies diferents a partir de la comanda anterior
	linies_iguals=$((linies_comp - linies_dif))

	# Calcula el percentatge de similitud
	simil=$((linies_iguals * 100 / linies_comp))
	if [ "$simil" -lt 0 ]; then
		simil=0
	fi

	# Mostrar el percentatge de similitud i les línies diferents
	echo "Percentatge de similitud: $simil%"
	echo "Línies diferents:"
	#Mostra per la sortida d'error només el contingut de les línies diferents, eliminant totes les línies buides de la sortida de la consulta de cada fitxer.
	#A més, imprimim la sortida de la consulta a partir de la segona línea, saltant-nos la info de les línies diferents de cada fitxer.                                     
	#^ -> indica el començament de la línia
     	#\s -> és un caràcter despai en blanc
	#* -> indica que hi ha zero o més espais en blanc
     	#$ -> indica el final de la línia
     	#/d -> és la comanda set que indica que la línia coincident ha de ser eliminada
	diff -i -b -B <(sed '/^\s*$/d' "$1") <(sed '/^\s*$/d' "$2") | tail -n +2 >&2	
			
}


function compdir() {				#declaració de la funció compdir		

	for arxiu1 in $1/*; do			#bucle de recorregut per cada arxiu dins del directori1 especificat
		nom1=$(basename $arxiu1)	#obtenim el nom de l'arxiu en el recorregut del directori1
	  	arxiu2="$2/$nom1"		#concatenem el nom del directrori2 amb el nom de l'arxiu del directori 1
	  	if [ -f $arxiu2 ]; then		#si es path especificat en el directori2, es farà la comparació
			compfitxer $arxiu1 $arxiu2	#crida a la funció compfitxer per comparar els fitxers que tenen el mateix nom y que es troben en els dos directoris diferents passats per paràmetre
	    		if [ "$arxiu1" -nt "$arxiu2" ]; then	#comprova si l'arxiu1 és més nou que l'arxiu2	
				arxiu_recent=$(realpath "$arxiu1")	#si es compleix, l'arxiu més recent serà el del directori1
	    		else
				arxiu_recent=$(realpath "$arxiu2")	#si no es compleix, l'arxiu més recent serà el del directori2	
	    		fi
	  	fi
		
	done

	if [ -z "$arxiu_recent" ]; then		#comprovem si la longitud de la cadena que guarda la variable es 0. Si és 0, llavors significarà que no s'ha trobat cap fitxers amb el mateix nom
  		echo "No s'ha trobat cap arxiu en comú"
	else
  		echo "$arxiu_recent" > recents.log #pel contrari, es guardarà el path de l'arxiu més recent que conté la variable arxiu_recent en un fitxer de text anomenat recents.log
	fi
}

echo "PROVA1"
compdir "prova1/compdir1.directori" "prova1/compdir2.directori"
echo ""
echo "PROVA2"
compdir "prova2/compdir1.directori" "prova2/compdir2.directori"
echo ""
echo "PROVA3"
compdir "prova3/compdir1.directori" "prova3/compdir2.directori"

