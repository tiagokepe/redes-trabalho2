#!/bin/bash

### Declaração de parâmetros
	SAIDA=entrega.out
	taxa_entrega=$((0))
	media_entrega=$((0))
### Fim da declaração


if [ -f $SAIDA ]; then
     rm $SAIDA
fi
	  
# i contém o número de mensagens por segundo para cada conjunto de simulações.
for i in 1 10 100 1000 10000
	do
		echo "Simulações com $i mensagem(ns) por segundo"
		# 3 simulações são realizadas para cada valor
		for j in $( seq 1 3 )
			do
				ns ethernet.tcl $i $RANDOM
				taxa_entrega=$( cat simulacao$i.tr | cut -d " " -f 1,12 | grep --color=NEVER -e "^[+d]" | uniq | awk -f entrega.awk)
				media_entrega=$( echo "scale=10; $media_entrega + $taxa_entrega " | bc )
			done
		media_entrega=$( echo "scale=10; $media_entrega / $j" | bc )
		echo "$i $media_entrega" >>$SAIDA
		media_entrega=$((0))
	done

#Gerando gráfico
./entrega.gnu
