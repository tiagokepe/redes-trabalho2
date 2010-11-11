#include <stdio.h>
#include <stdlib.h>
#define CONST_INI 1000000


int main(int argc, char *argv[])
{
	FILE *fp = fopen(argv[1],"r");

	if ( !fp ) return -1;

	char symb; /* Evento */
	double time; /* Tempo do evento */
	long long int id; /* Id do pacote */
	int no_chegada; 
	int destino;
	float destino2;
	
	/* Vetor de mensagens recebidas e enviadas. */
	double *enviadas = ( double * ) malloc(CONST_INI * sizeof(double)  );
	double *recebidas = ( double * ) malloc(CONST_INI * sizeof(double) );
	
	/* Tamanho do vetor. */
	long long int size = CONST_INI;
	long long int last = -1;
	long long contador = 0;
	double media = 0;

	/* Le ate fim do arquivo. */
	while ( !feof(fp) )
	{
		fscanf(fp," %c %lf %*[^ ] %d %*[^ ] %*[^ ] %*[^ ] %*[^ ] %*[^ ] %f %*[^ ] %lld",&symb,&time,&no_chegada,&destino2,&id); /* Leitura de uma linha do arquivo trace. */
		destino = ( int  ) destino2;
//		printf("simbolo: %c time: %lf no_chegada: %d destino: %d id: %lld\n",symb,time, no_chegada, destino,id);
		
		if ( id > ( size -1 ) ) /* Realocacao de memoria. */
		{
			enviadas = ( double * ) realloc(enviadas, sizeof(double) * ( 2 * size ) );
			recebidas = ( double * ) realloc(recebidas, sizeof(double) * ( 2 * size ) );
			size*=2;
			if ( !enviadas || !recebidas ) return -2;
		}
		if ( ( symb == '+' ) && ( id > last ) ) /* E o primeiro envio de mensagem com este id. */
		{
			enviadas[id] =  time;
		}
		else if ( symb == 'r' )
		{
			if ( no_chegada == destino ) /* Verifica se a mensagem chegou ao no final, e nao ate um switch. */
			{
				recebidas[id] = time;
				media+= recebidas[id] - enviadas[id];
				contador++;
			}
		}
		last = (id>last)?id:last;
	}

	printf("%lf\n",media/=contador); /* Calcula media */
	free(recebidas);
	free(enviadas);
	fclose(fp);
}
