#!/bin/bash

# 2.- Crearem una funció de la bash  compfitxer.sh que donats dos arxius de text els compari i tregui per la sortida d'error les línies diferents i 
# per la sortida estàndard un percentatge de similitud ((la suma de totes les línies iguals / lasuma de totes les línies comparades) * 100). 
# Per a fer la comparació de fitxers usarem la comanda diff. Considerarem que les línies en blanc, els caràcters en blanc duplicats, 
# i la diferència entre majúscules i minúscules no comptin a nivell de diferència.


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

echo "Prova1"
compfitxer "Prova1/compfitxer1.fitxer" "Prova1/compfitxer2.fitxer"
echo ""
echo "Prova2"
compfitxer "Prova2/compfitxer1.fitxer" "Prova2/compfitxer2.fitxer"
echo ""
echo "Prova3"
compfitxer "Prova3/compfitxer1.fitxer" "Prova3/compfitxer2.fitxer"

