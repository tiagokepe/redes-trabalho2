#!/usr/bin/gnuplot -persist 

# Impressão feita em um arquivo de imagem:
set term png
set out 'entrega.png'

set title "Taxa de entrega"

set xlabel "Mensagens por segundo"
set ylabel "% de acerto"

#set xrange [1:10000]
#set yrange [0:100]


plot "entrega.out"  using 1:2 title "Taxa media de entrega" with linespoints
