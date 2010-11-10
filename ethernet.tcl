# Declaração de parâmetros globais

# Número de maquinas 70
set opt(maquina)	70
# Número de switches 11
set opt(swi) 	11

# Tamanho dos pacotes -- Lembrete: Achar uma forma de gerar pacotes de tamanho aleatório.
set opt(packsize) 1000

# Obs: Pacotes Ethernet -> 64 até 1518 bytes.

# nº de origens
set opt(origins) 10

# nº de destinos
set opt(destinations) 2

# Início e fim de transmissão de dados
set opt(inicio_tr) 1.5
set opt(fim_tr) 181.5

# Duração da simulacao

set opt(duracao) 190

#Limite da fila - somente testes
set opt(queuelimit) 2

# Recebe por linha de comando a quantidade de pacotes por segundo e a semente
if { $argc != 2} {
     puts stderr {Uso: ns ethernet.tcl pacotes_por_segundo seed}
     exit 1
}

# Quantidade de pacotes por segundo
set opt(packsec) [lindex $argv 0]

# Arquivos de saída
set opt(tr)	"/dev/shm/simulacao$opt(packsec).tr"
set opt(namtr) "/dev/shm/out$opt(packsec).nam"

# Semente para número aleatório
set opt(seed) [lindex $argv 1]

#Intervalo entre envio de pacotes = ( 1 segundo/ número de pacotes por segundo )
set opt(tempo) [expr 1.0/$opt(packsec)]
### Fim de declaração de variáveis


# Declaração de procedimentos


proc finish {} {
	global ns opt trfd ntrfd
	$ns flush-trace
	close $trfd
#    close $ntrfd
	#exec nam $opt(namtr) &
	exit 0
}


proc create-trace {} {
		global ns opt

		set trfd [open $opt(tr) w]
		$ns trace-all $trfd
		return $trfd
}

proc create-namtrace {} {
	global ns opt

	set ntrfd [open $opt(namtr) w]
	$ns namtrace-all $ntrfd
}

proc criar-topologia {} {
	global ns opt swi maquina


	# Switch do topo da hierarquia
	set swi(0) [$ns node ]
	$swi(0) shape box

	# Switches intermediarios

	set num  $opt(swi)


	for {set i 1} { $i < $num} {incr i} {
		set swi($i) [ $ns node ]
		$swi($i) shape box
		## Liga ao switch pai
		$ns duplex-link $swi($i) $swi(0) 1Gbps 10ms DropTail
	#	$ns queue-limit $swi($i) $swi(0) $opt(queuelimit)
	}

	# Máquinas 

	set num $opt(maquina)
	set intermediarios [expr $opt(swi) -1 ]

	for {set i 0} { $i < $num} {incr i} {
		set maquina($i) [ $ns node ]
		$maquina($i) color blue

		set index [expr ($i % $intermediarios )+1 ]
		## Liga a switches intermediarios
		$ns duplex-link $maquina($i) $swi($index) 100Mbps 10ms DropTail
	#	$ns queue-limit $maquina($i) $swi($index) $opt(queuelimit)
	}


}

proc criar-conexao {} {
	global ns opt maquina seed
	global defaultRNG
	global cbr udp
	$defaultRNG seed $opt(seed)

	# Variável que gerará números aletaórios para escolhermos destinos e origens
	set unif [new RandomVariable/Uniform]
	$unif set min_ 0.0
	$unif set max_  [expr $opt(maquina)-1]

	puts "Origens:"
	# Escolhe origens
	for {set i 0} {$i < $opt(origins)} {incr i} {
		set index [expr round([$unif value])]
		puts -nonewline "[expr $index + $opt(swi)] ,"
		#Agente UDP
		set udp($i) [ new Agent/UDP ]
		$udp($i) set class_ 1
		$ns attach-agent $maquina($index) $udp($i)
		
		# Gerador de pacotes
		set cbr($i) [ new Application/Traffic/CBR ]
		$cbr($i) set packetSize_ $opt(packsize)
		$cbr($i) set interval_ $opt(tempo)
		$cbr($i) set random_ false

		$cbr($i) attach-agent $udp($i)
	}
	puts ""

	puts "Destinos:"
	# Escolhe destinos
	for {set i 0} {$i < $opt(destinations)} {incr i} {
		set index [expr round([$unif value])]
		puts -nonewline "[expr $index + $opt(swi)] ,"
		set destination($i) [new Agent/Null]
		$ns attach-agent $maquina($index) $destination($i)
	}
	puts ""

		#Conecta origens com destinos
	for {set i 0} {$i < $opt(origins)} {incr i} {
		set index_conexao [expr $i%$opt(destinations)]
		$ns connect $udp($i) $destination($index_conexao)
	}

# Verificar se é possível conectar todas as origens a todos os destinos. Aparentemente ele apenas manda mensagens para o último receptor conectado.
#	for {set i 0} {$i < $opt(origins)} {incr i} {
#		#set index_conexao [expr $i%$opt(destinations)]
#		for {set j 0} {$j < $opt(destinations)} {incr j} {
#			$ns connect $udp($i) $destination($j)
#		}
#	}
}

proc transmitir-dados {} {

	global ns cbr opt

	#inicia transmissão dos dados
	for {set i 0} {$i < $opt(origins)} {incr i} {
		 $ns at $opt(inicio_tr) "$cbr($i) start"
	}

	#finaliza transmissão dos dados
	for {set i 0} {$i < $opt(origins)} {incr i} {
		 $ns at $opt(fim_tr) "$cbr($i) stop"
	}
}

### Fim da declaração de procedimentos

##### Main #######

set ns [new Simulator]


#Colore pacotes de nós da classe 1
$ns color 1 red

# Log a ser analisado
set trfd [create-trace] 
#Para executar no NAM - Evite executá-lo se quiser evitar longos testes.
#set ntrfd [create-namtrace] 


# Construção da rede
criar-topologia

# Escolhe origens e destinos e os conecta
criar-conexao

# Decide quando começar e terminar a transmissão de dados
transmitir-dados



# Finalização
$ns at $opt(duracao) "finish"

$ns run
