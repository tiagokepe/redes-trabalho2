{
	if ( $1 == "+" )
	{
		if ( envio[$12] == "" )
			envio[$12] = $2
	}
	else if( $1 == "r" )
	{
		#Destino final é igual ao nó de chegada.
		if ( $4 == $10 )
		{
			recebimento[$12] = $2
		}
			
	}
}
END{
	media = 0
	contador = 0
	arraySize = length(envio);
	for ( i = 0;i< arraySize;i++)
	{
		if ( ( envio[i] != "" ) && ( recebimento[i] != "" ) )
		{
			resposta = recebimento[i] - envio[i]
			
			if ( resposta < 0 )
			{
				print("Algo deu errado.")
			}
			else
			{
				contador++
				media= media + resposta
			}
		}
	}
	if ( media > 0 )
		media = media / contador
	
	print(media)
}
