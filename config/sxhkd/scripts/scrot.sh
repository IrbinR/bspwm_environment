#!/bin/bash
filename=~/Imágenes/Capturas\ de\ pantalla/captura-$(date +'%Y-%m-%d %I:%M %p').png
type=$1

if [[ $type == "-d" ]]; then
  scrot -d 5 "$filename"
  dunstify "Captura de pantalla guardada" "$filename"
elif [[ $type == "-s" ]]; then
  scrot -s "$filename"
  if [[ $? -eq 0 ]]; then
    dunstify "Captura de pantalla guardada" "$filename"
  else
    dunstify "Captura de pantalla cancelada" "Se cancelo la captura"
  fi
elif [[ $type == "-sd" ]]; then
  scrot -s -d 5 "$filename"
  if [[ $? -eq 0 ]]; then
    dunstify "Captura de pantalla guardada" "$filename"
  else
    dunstify "Captura de pantalla cancelada" "Se cancelo la captura"
  fi
else
  scrot "$filename"
  dunstify "Captura de pantalla guardada" "$filename"
fi
