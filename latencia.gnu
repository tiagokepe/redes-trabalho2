#!/usr/bin/gnuplot -persist 

# Impressão feita em um arquivo de imagem:
set term png
set out 'latencia.png'

set title "Latência"

set xlabel "Mensagens por segundo"
set ylabel "Segundos"

#set xrange [1:10000]
#set yrange [0:0.3]


plot "latencia.out"  using 1:2 title "Latência média" with linespoints
