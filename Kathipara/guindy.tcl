set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             61                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
# set floor size
set opt(x) 4703
set opt(y) 4638

set ns_		[new Simulator]
set tracefd     [open guindy.tr w]
set namf	[open guindy.nam w]
$ns_ namtrace-all-wireless $namf $opt(x) $opt(y)
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $opt(x) $opt(y)

#
# Create God
#
create-god $val(nn)


# configure node

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -wiredRouting ON \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace ON \
			 -movementTrace ON			
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
		$ns_ initial_node_pos $node_($i) 100
	}



source mobility.tcl

#TCP connection for vehicles	
	for {set j 0} {$j < $val(nn)} {incr j} { 
             
        set Tcp($j) [new Agent/TCP] 
        $ns_ attach-agent $node_($j) $Tcp($j) 
        $Tcp($j) set fid_ $j 
        $Tcp($j) set packetSize_ 512 
        $Tcp($j) set window_ 20 
        $Tcp($j) set windowInit_ 1 
        $Tcp($j) set maxcwnd_ 0 
		
        #Set TCPSink 
        set TcpSink($j) [new Agent/TCPSink] 
        $ns_ attach-agent $node_($j) $TcpSink($j) 
        $TcpSink($j) set packetSize_ 210 
		
        #Set Trafic Source     
        set Ftp($j) [new Application/FTP] 
        $Ftp($j) attach-agent $Tcp($j) 
        $Ftp($j) set maxpkts_ 2048 
        }

		
	for {set j 0} {$j < $val(nn)} {incr j} { 
		for {set k 0} {$k < $val(nn)} {incr k } {
			if {$k == $j} {
				continue
			}
		$ns_ connect	$Tcp($j) $TcpSink($k)
			
		}
	}
	
	for {set j 0} {$j < $val(nn)} {incr j} { 
		$ns_ at 0.50000 "$Ftp($j) start" 
		$ns_ at 600.0000 "$Ftp($j) stop" 
	}

# # Create nodes RSU
set n70 [$ns_ node] 
$n70 set X_ 128.0
$n70 set Y_ 92.0
$n70 set Z_ 0.0
set n71 [$ns_ node]
$n71 set X_ 2075.0
$n71 set Y_ 1456.0
$n71 set Z_ 0.0
set n72 [$ns_ node]
$n72 set X_ 3618.0
$n72 set Y_ 2539.0
$n72 set Z_ 0.0
# set n73 [$ns_ node]
# $n72 set X_ 1118.0
# $n72 set Y_ 739.0
# $n72 set Z_ 0.0 
# set n74 [$ns_ node]
# $n72 set X_ 3618.0
# $n72 set Y_ 3239.0
# $n72 set Z_ 0.0 

# # # Create links for RSUs
$ns_ duplex-link $n70  $n71 1.5Mb 10ms DropTail
$ns_ duplex-link $n71  $n72 1.5Mb 10ms DropTail
#$ns_ duplex-link $n70  $n73 1.5Mb 10ms DropTail
#$ns_ duplex-link $n70  $n73 1.5Mb 10ms DropTail


# UDP Transport agent for the RSUs
set udp [new Agent/UDP]
$udp set class_ 2
set null [new Agent/Null]
$ns_ attach-agent $n71 $udp
$ns_ attach-agent $n72 $null
$ns_ connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns_ at 0.2 "$cbr start"

set udp1 [new Agent/UDP]
$udp1 set class_ 2
set null1 [new Agent/Null]
$ns_ attach-agent $n71 $udp1
$ns_ attach-agent $n70 $null1
$ns_ connect $udp1 $null1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$ns_ at 0.2 "$cbr1 start"

$ns_ at 600.0 "$cbr stop"
$ns_ at 600.0 "$cbr1 stop"

#Tcp connection for RSU & vehicles
for {set j 0} {$j < $val(nn)} {incr j} { 
	set tcp [new Agent/TCP/Newreno]
	$tcp set class_ 2
	set sink [new Agent/TCPSink]
	$ns_ attach-agent $n70 $tcp
	$ns_ attach-agent $node_($j) $sink
	$ns_ connect $tcp $sink
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ns_ at 0.5 "$ftp start"
}

for {set j 0} {$j < $val(nn)} {incr j} { 
	set tcp [new Agent/TCP/Newreno]
	$tcp set class_ 2
	set sink [new Agent/TCPSink]
	$ns_ attach-agent $n71 $tcp
	$ns_ attach-agent $node_($j) $sink
	$ns_ connect $tcp $sink
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ns_ at 0.5 "$ftp start"
}

for {set j 0} {$j < $val(nn)} {incr j} { 
	set tcp [new Agent/TCP/Newreno]
	$tcp set class_ 2
	set sink [new Agent/TCPSink]
	$ns_ attach-agent $n72 $tcp
	$ns_ attach-agent $node_($j) $sink
	$ns_ connect $tcp $sink
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ns_ at 0.5 "$ftp start"
}
	
$ns_ color 1 "black" 
$ns_ color 2 "red" 	
$ns_ color 3 "green"

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 600.0 "$node_($i) reset";
}
$ns_ at 600.0 "stop"
$ns_ at 600.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namf
    $ns_ flush-trace
    close $tracefd
	close $namf
}
# $n70 label "RSU"
# $n71 label "RSU"
# $n72 label "RSU"

$n70 color red
$n71 color red
$n72 color red

puts "Starting Simulation..."
$ns_ run

