#!/bin/bash



function tipus() {				#declaració de la funció tipus
	local val=0  				#variable val con valor por defecto de 0
    	if [ -f "$1" ]; then			#mira si el paràmetre que li passem és un fitxer
        	val=1  				#actualiza el valor de val a 1 si Ã©s un fitxer
    	fi
	if [ -d "$1" ]; then  			#mira si el paràmetre que li passem és un directori
        	val=2				#actualiza el valor de val a 2 si Ã©s un directori
    	fi
	if ! [ -f "$1" ] && ! [ -d "$1" ]; then	#mira si el paràmetre que li passem no és ni un fitxer ni un directori
        	val=3				#actualiza el valor de val a 3 si compleix les condicions anteriors
    	fi
    	echo "$val"  				#ens mostrarÃ  el valor retornat segons el cas
}


function mesactual() {					#declaració de la funció mesactual 
	# aquesta funció la utilitzem exclusivament quan els dos primers arguments que hagi passat l'usuari siguin fitxers
    	if [ "$1" -nt "$2" ]; then		#comprovem si un arxiu és més recent que un altre
        	echo "$(realpath "$1")" > recents.log		#imprimim el path del fitxer 1 en cas de que aquest sigui el més recent
    	else
        	echo "$(realpath "$2")"	> recents.log	#sinò, imprimim el path del fitxer 2 en cas de que aquest sigui el més recent
    	fi
}


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
	
	#En el cas de que els dos primers arguments que ha passat l'usuari siguin fitxers, cridarem a la funció mesactual que comprovarà que fitxer és més recent i escriurà el path d'aquest en el fotxer de sortida recents.log	
	if [ $(tipus "$fitxer1") -eq 1 ] &&  [ $(tipus "$fitxer2") -eq 1 ] ; then
		mesactual $fitxer1 $fitxer2
	fi
	
			
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
  		echo "$arxiu_recent" >> recents.log #pel contrari, es guardarà el path de l'arxiu més recent que conté la variable arxiu_recent en un fitxer de text anomenat recents.log
	fi
}



function comptot() {				#declaració de la funció comptot
	# Obté la llista de directoris especificada pel primer argument (directori1)
	#find -> busca tots els elements de la ubicació de la ruta especificada
	#$(cd $1 ; pwd) -> canvia el directori actual al directori especificat en el primer argument directori1 i retorna la ruta absoluta a partir del pwd
	#-type d -> especifica a la sortida del find que només busqui directoris
	dir_list1=$(find $(cd $1 ; pwd) -type d)

	# Obté la llista de directoris especificada pel segon argument (directori2)
	#find -> busca els elements de la ubicació de la ruta especificada
	#$(cd $1 ; pwd) -> canvia el directori actual al directori especificat en el segon argument directori1 i retorna la ruta absoluta a partir del pwd
	#-type d -> especifica a la sortida del find que només busqui directoris
	dir_list2=$(find $(cd $2 ; pwd) -type d)

	# Itera sobre la llista de directoris del primer argument
	for dir1 in $dir_list1; do
  	# Iterar sobre la lista de directoris del segon argument
  		for dir2 in $dir_list2; do
    			# Per cada directori1, mirem si es troba el mateix nom d'aquest en el directori2 quedant-nos només amb els noms base del directori de cada path
    			dir1_base=$(basename $dir1)
    			dir2_base=$(basename $dir2)

    			# Verifiquem si els noms del directori1 i directori2 coincideixen
    			if [ "$dir1_base" == "$dir2_base" ]; then
      				# Si els noms dels directoris coincideixen, cridem a la funció compdir per comparar el seu contingut
      				compdir $dir1 $dir2    
    			fi
  		done
	done

	# Càlcul del percentatge de similitud entre els dos directoris rebuts com a paràmetre
	# Per diferènciar aquesta part, guardarem l'argument1 i l'argument2 en la variable ruta1 i ruta2 respectivament
	ruta1="$1"
	ruta2="$2"
	
	# Obté el número de fitxers i directoris en cadascuna de les rutes
	#find -> busca tots els elements de la ubicació de la ruta especificada (en aquest cas del directori1 i directori2)
	#-type f -o -type d -> especifica a la comanda find que només busqui fitxers i directoris
	#sort -> del pipe anterior, ordenem aquests fitxers i directoris en ordre alfabètic
	#uniq -> del pipe anterior, eliminem els duplicats de la búsqueda de les dues rutes
	#wc -l -> conta el número de línies que s'obte de la consuta (comandes anteriors). D'aquesta manera obtenim el número total de fitxers i directoris trobats.
	total=$(find "$ruta1" "$ruta2" -type f -o -type d | sort | uniq | wc -l)
	#echo "$total"
	
	# Obtenim els fitxers i directoris en cada una de les dues rutes i obté el número d'elements que es troben tant en la ruta1 com en la ruta2 (coincidents)
	#comm -12 -> compara i obté el número de línies que es troben en cada una de les dues rutes (només fitxers i directoris que tenen en comú)
	#<(cd "$ruta1"; find . -type f -o -type d | sort) -> obre una subshell per poder executar la comanda find pel directori especificat (ruta1), ja que la comanda cd canviarà el directori actual només en aquella subshell i no en la shell principal
	#sort -> ordenem la sortida alfabèticament
	# <(cd "$ruta2"; find . -type f -o -type d | sort) -> fem el mateix procediment per a la ruta2
	#wc -l -> per últim, dels pipes anteriors, conta el númeo de línies (que simbolitza el número de fitxers i directoris en comú)
	coincidents=$(comm -12 <(cd "$ruta1"; find . -type f -o -type d | sort) <(cd "$ruta2"; find . -type f -o -type d | sort) | wc -l)
	#echo "$coincidents"
	
        # Calcular el percentatge de similitud entre les dues rutes rebudes com a paràmetres
	#awk -> per realitzar el càlcul pertinent del percentatge abans de que es procedeixi l'arxiu d'entrada (BEGIN)
	#{printf \"%.2f\", $coincidents * 100 / $total}") -> farà el el número total de directoris i fitxers en comú entre les dues rutes (obtingut anteriorment) per 100 (per obtenir el percentatge en un float de 2 decimals) i això o dividim pel número total de fitxers i directoris en cadascuna de les rutes
	similitud=$(awk "BEGIN {printf \"%.2f\", $coincidents * 100 / $total}")

	# Imprimim el percentatge obtingut
	echo "La similitud entre $ruta1 y $ruta2 es del $similitud%"

}



function creanou(){
	# Verifiquem si s'han passat els arguments correctes
	if [ $# -ne 1 ]; then
	  echo "Ús: $0 <directori_destí>"
	  exit 1
	fi

	# Comprovem si el fitxer recents.log existeix
	if [ ! -f recents.log ]; then
	  echo "El fitxer recents.log no existeix."
	  exit 1
	fi

	# Creem el directori destí si no existeix
	if [ ! -d $1 ]; then
	  mkdir $1
	fi

	# Llegim el fitxer recents.log i creem els fitxers i directoris corresponents
	while read line; do
	  nom=$(echo $line | cut -d " " -f 1)
	  data=$(echo $line | cut -d " " -f 2)

	  # Creem el directori corresponent
	  if [ "${nom: -1}" = "/" ]; then
	    nom="${nom%/}"
	    mkdir -p "$1/$nom"
	    touch -d "$data" "$1/$nom"
	  # Creem el fitxer corresponent
	  else
	    mkdir -p "$1/$(dirname $nom)"
	    cp "$nom" "$1/$nom"
	    touch -d "$data" "$1/$nom"
	  fi
	done < recents.log
	creanou > /dev/null 2>&1
}







if [ $# -eq 3 ]; then	# Mirem si l'usuari ha introduït correctament 3 arguments 
	# Guardem els arguments	en dos variables per a després, en el cas de que siguin fitxers, cridarem a la funció mesactual per guardar el fitxer més recent en un fitxer de sortida recents.log.
	# Això o fem per diferenciar el $1 i $2 en el cas de que siguin directoris
	fitxer1=$1
	fitxer2=$2
	
	#Eliminem el fitxer recents.log per refresecar les sortides d'execucions anteriors 
        if [ -e "/home/milax/FSO/PRACTICA/p1/recents.log" ] && [ "$PWD" == "/home/milax/FSO/PRACTICA/p1" ]; then
    		rm recents.log
	fi

	# Mirem si els dos primers arguments son fitxers i el tercer és un directori
	if [ $(tipus "$1") -eq 1 ] &&  [ $(tipus "$2") -eq 1 ] && [ $(tipus "$3") -eq 2 ]; then	
		# En aquest cas, com els dos primers arguments seran fitxers, cridem a la funció compfitxer per a que només es faci la comparació d'aquests dos fitxers		
		compfitxer "$1" "$2"
		creanou "$3" > /dev/null 2>&1		
	# Mirem si els dos primers arguments son directoris i el tercer és un directori
	elif [ $(tipus "$1") -eq 2 ] &&  [ $(tipus "$2") -eq 2 ] && [ $(tipus "$3") -eq 2 ]; then	
		# En aquest cas, com els dos primers arguments seran directoris, cridem a la funció comptot per a que es faci la comparació a nivell de fitxers/directoris recursivament
		comptot "$1" "$2"
		creanou "$3" > /dev/null 2>&1		
	# Si no es compleix cap condició anterior ens sortirem de l'execució	
	else
		echo "Has de passar fitxer/fitxer/directori o directori/directori/directori" >&2
        	exit 1
	fi
else	
	# Si l'usuari no passa 3 arguments, ens sortim de l'execució
	echo "Error: has de passar 3 arguments" >&2
        exit 1
fi
