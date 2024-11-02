#!/bin/bash

#Detecta todos los monitores conectados
monitores=$(xrandr | grep " connected" | awk '{print $1}')

# Configura la mejor resolución disponible para cada monitor
for monitor in $monitores; do
  # Obtiene la mejor resolución disponible para el monitor actual
  resolucion=$(xrandr | grep -A 1 "$monitor" | grep -oP '\d+x\d+')

  # Aplica la resolución
  xrandr --output "$monitor" --mode "$resolucion"
done
