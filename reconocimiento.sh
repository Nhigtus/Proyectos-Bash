#!/usr/bin/env bash

# Colores para que la salida sea más legible

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

#-------------------------------------------------

if [ -z "$1" ]; then

  echo -e "${RED} [!] Usa el script de la siguiente manera: $0 <IP o Dominio>${RESET}"
  exit 1

fi

TARGET="$1"
SCAN_FILE="scan_$TARGET.xml"

opciones=(
  " [+] Todos los puertos (TCP 1-65535, SYN, Agresivo)"
  " [+] Todos los puertos (TCP 1-65535, SYN, Normal)"
  " [+] Los 1000 puertos mas comunes"
  " [+] Evacion de Firewall"
  " [+] Paranoico" 
  " [+] Descubrimiento de Host "
)

# Cambiamos el PS3 para personalizar el mensaje del select (por defecto aparece '#? ')
PS3="[+] Introduce una opción [1-${#opciones[@]}]:"
  
select opt in "${opciones[@]}"; do 
  case $REPLY in 
    
    1)
      echo -e "\n${RED}[!] advertencia este escaneo es muy agresivo y puede saturar la red si no es lo suficientemente
      \nrobusta precione ctrl + c si desea cancelar.${RESET}"
      echo -e "\n${GREEN}[+] Escaneo de todos los puertos${RESET}"
      sudo nmap -Pn -sS -p- -T4 --min-rate 1000 -n "$TARGET"
      break 
      ;;
    2)
      echo -e "\n${RED}[!]Este escaneo se puede tardar dependiendo de la su red.${RESET}"
      sudo nmap -Pn -sS -p- -T3 -n "$TARGET"
      break 
      ;;

    3) echo -e "\n${GREEN}[+] Escaneado el top 1000 puertos de:${TARGET} ${RESET}"
      sudo nmap -Pn -sS -n "$TARGET"
      break 
      ;;
    4)
      echo -e "\n${GREEN}[+] Evacion de Firewall en ${TARGET}  (decoys + fragmentación)${RESET}"
      sudo nmap -Pn -f -D RND:10 -sS -n "$TARGET" 
      break 
      ;;
    5)
      echo -e"\n${GREEN}[+] Modo Paranoico${RESET}"
      echo -e"\n${RED}[!] Este escaneo puede durar aproximadamente unos 3.5 dias creo que te alcanza para un cafe o mas ...${RESET}"
      sudo nmap -Pn -T0 -sS -n "$TARGET" 
      break 
      ;;
    6)
      echo "${GREEN}[!] Descubrimirntos de host.${RESET}"
        sudo nmap -sn "$TARGET"
        break 
        ;;
    *)
      echo -e "\n${RED}[!] Opcion no invalida mi querido dislexico vuelve a elegir.${RESET}"
      ;;
    esac
done

if [! -f "$SCAN_FILE"]; then
  echo -e "\n${RED} El archivo ${SCAN_FILE} no fue posible encontrarlo.${RESET}"
  exit 1
fi

echo -e "\n extrallendo puertos abiertos de ${TARGET}"
OPEN_PORTS=$(xmllint --xpath '//port[state/@state="open"]/@portid' "$SCAN_FILE" 2>/dev/null | grep -oP 'portid="\K[^"]+' | paste -sd, -)

