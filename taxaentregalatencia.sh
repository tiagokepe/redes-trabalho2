#!/bin/bash

### Declaração de parâmetros
	SAIDATE=entrega.out
	SAIDALA=latencia.out

	latencia=$((0))
	taxa_entrega=$((0))
	media_latencia=$((0))
	media_entrega=$((0))
### Fim da declaração


if [ -f $SAIDATE ]; then
     rm $SAIDATE
fi
if [ -f $SAIDALA ]; then
     rm $SAIDALA
fi
	  
# i contém o número de mensagens por segundo para cada conjunto de simulações.
for i in 1 10 100 1000 10000
	do
		echo "Simulações com $i mensagem(ns) por segundo"
		# 3 simulações são realizadas para cada valor
		for j in $( seq 1 3 )
			do
				ns ethernet.tcl $i $RANDOM
				taxa_entrega=$( cat simulacao$i.tr | cut -d " " -f 1,12 |  uniq | awk -f entrega.awk)
				latencia=$( cat simulacao$i.tr | awk -f latencia.awk )
				media_entrega=$( echo "scale=10; $media_entrega + $taxa_entrega " | bc )
				media_latencia=$( echo "scale=10; $media_latencia + $latencia " | bc )
			done
		
		media_entrega=$( echo "scale=10; $media_entrega / $j" | bc )
		media_latencia=$( echo "scale=10; $media_latencia / $j" | bc )
		
		echo "$i $media_entrega" >>$SAIDATE
		echo "$i $media_latencia" >>$SAIDALA
		
		media_entrega=$((0))
		media_latencia=$((0))
	done

#Gerando gráfico
./entrega.gnu
./latencia.gnu
