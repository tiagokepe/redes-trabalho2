BEGIN{
#Conta todos os pacotes enviados
	total = 0
# COnta pacotes perdidos
	perdidos = 0
}
{
	if ( $1 == "+" )
	{
		total++
	}
	else if ( $1 == "d" ) 
	{
		perdidos++
	}
}
END{
	print((1-(perdidos/total))*100)
}

