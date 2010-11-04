# Declaração de parâmetros globais


set opt(tr)	"out.tr"
set opt(namtr)	"out.nam"

# Número de maquinas 70
set opt(maquina)	70
# Número de switches 11
set opt(swi) 	11

# Tamanho dos pacotes -- Lembrete: Achar uma forma de gerar pacotes de tamanho aleatório.
set opt(packsize) 10000

#Intervalo entre envio de pacotes
set opt(tempo) 0.1

# Semente para número aleatório
set opt(seed) 1200

# nº de origens
set opt(origins) 10

# nº de destinos
set opt(destinations) 2

# Início e fim de transmissão de dados
set opt(inicio_tr) 0.2
set opt(fim_tr) 19.9

# Duração da simulacao

set opt(duracao) 20

### Fim de declaração de variáveis


# Declaração de procedimentos


proc finish {} {
	global ns opt trfd ntrfd
	$ns flush-trace
	close $trfd
    close $ntrfd
	exec nam $opt(namtr) &
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
		$ns duplex-link-op $swi($i) $swi(0) orient right-down
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

		
		#Conecta as origens com destinos
		for {set j 0} {$j < $opt(origins)} {incr j} {
			$ns connect $udp($j) $destination($i)
		}
	}
	puts ""
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
#Para executar no NAM
set ntrfd [create-namtrace] 


# Construção da rede
criar-topologia

# Escolhe origens e destinos e os conecta
criar-conexao

# Decide quando começar e terminar a transmissão de dados
transmitir-dados



# Finalização
$ns at $opt(duracao) "finish"

$ns run
