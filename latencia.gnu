#!/usr/bin/gnuplot -persist 

# Impressão feita em um arquivo de imagem:
set term png
set out 'latencia.png'

set title "Latência"

set xlabel "Mensagens por segundo"
set ylabel "Tempo de resposta, em segundos"

set xrange [1:10000]
set yrange [0:0.3]


plot "latencia.out"  using 1:2 title "Tempo de respoata médio" with linespoints
