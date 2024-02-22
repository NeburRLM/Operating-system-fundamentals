#!/bin/bash

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
}

creanou "dir"
