set opt(tr)	"out.tr"
set opt(namtr)	"out.nam"

# Número de maquinas 70
set opt(node)	70
# Número de switches 11
set opt(swi) 	11	
# Tamanho do pacote
set opt(packsize) 1500



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
	global ns opt swi node


	# Switch do topo da hierarquia
	set swi(0) [$ns node ] 

	# Switches intermediarios

	set num  $opt(swi)


	for {set i 1} { $i < $num} {incr i} {
		set swi($i) [ $ns node ]
		## Liga ao switch pai
		$ns duplex-link $swi($i) $swi(0) 1Gbps 10ms DropTail
	}

	# Máquinas 

	set num $opt(node)
	set intermediarios [expr $opt(swi) -1 ]

	for {set i 0} { $i < $num} {incr i} {
		set node($i) [ $ns node ]
		set index [expr ($i % $intermediarios )+1 ]
		## Liga a switches intermediarios
		$ns duplex-link $node($i) $swi($index) 100Mbps 10ms DropTail 
	}


}

proc criar-conexao {} {
#	global ns opt udp cbr

	
}

##### Main #######


set ns [new Simulator]

# Log a ser analisado
set trfd [create-trace] 
#Para executar no NAM
set ntrfd [create-namtrace] 


# Construção da rede
criar-topologia

# Criação de agentes
set udp [new Agent/UDP]
$ns attach-agent $node(1)  $udp
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp

set null [new Agent/Null]
$ns attach-agent $swi(1) $null
$ns connect $udp $null


criar-conexao

$ns at 0.0 "$cbr start"

# Finalização
$ns at 180.0 "finish"

$ns run
