
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             25                         ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
# set floor size
set opt(x) 12686
set opt(y) 14650

set ns_		[new Simulator]
set tracefd     [open high.tr w]
set namf	[open high.nam w]
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
		$ns_ at 100.0000 "$Ftp($j) stop" 
	}

# # Create nodes RSU
set n70 [$ns_ node] 
$n70 set X_ 128.0
$n70 set Y_ 92.0
$n70 set Z_ 0.0
$ns_ initial_node_pos $n70 200
set n71 [$ns_ node]
$n71 set X_ 2075.0
$n71 set Y_ 1456.0
$n71 set Z_ 0.0
$ns_ initial_node_pos $n71 200
set n72 [$ns_ node]
$n72 set X_ 3618.0
$n72 set Y_ 2539.0
$n72 set Z_ 0.0
$ns_ initial_node_pos $n72 200
set n73 [$ns_ node]
$n73 set X_ 5818.0
$n73 set Y_ 3839.0
$n73 set Z_ 0.0 
$ns_ initial_node_pos $n73 200
set n74 [$ns_ node]
$n74 set X_ 7118.0
$n74 set Y_ 4939.0
$n74 set Z_ 0.0 
$ns_ initial_node_pos $n74 200
set n75 [$ns_ node]
$n75 set X_ 10718.0
$n75 set Y_ 4739.0
$n75 set Z_ 0.0 
$ns_ initial_node_pos $n75 200
set n76 [$ns_ node]
$n76 set X_ 12418.0
$n76 set Y_ 4539.0
$n76 set Z_ 0.0  
$ns_ initial_node_pos $n76 200
set n77 [$ns_ node]
$n77 set X_ 5998.0
$n77 set Y_ 6589.0
$n77 set Z_ 0.0 
$ns_ initial_node_pos $n77 200
set n78 [$ns_ node]
$n78 set X_ 4878.0
$n78 set Y_ 8509.0
$n78 set Z_ 0.0 
$ns_ initial_node_pos $n78 200
set n79 [$ns_ node]
$n79 set X_ 3758.0
$n79 set Y_ 10429.0
$n79 set Z_ 0.0 
$ns_ initial_node_pos $n79 200
set n80 [$ns_ node]
$n80 set X_ 2638.0
$n80 set Y_ 12349.0
$n80 set Z_ 0.0 
$ns_ initial_node_pos $n80 200
set n81 [$ns_ node]
$n81 set X_ 1518.0
$n81 set Y_ 14539.0
$n81 set Z_ 0.0
$ns_ initial_node_pos $n81 200

# # # Create links for RSUs
$ns_ duplex-link $n70  $n71 1.5Mb 10ms DropTail
$ns_ duplex-link $n71  $n72 1.5Mb 10ms DropTail
$ns_ duplex-link $n72  $n73 1.5Mb 10ms DropTail
$ns_ duplex-link $n73  $n74 1.5Mb 10ms DropTail
$ns_ duplex-link $n74  $n75 1.5Mb 10ms DropTail
$ns_ duplex-link $n75  $n76 1.5Mb 10ms DropTail
$ns_ duplex-link $n70  $n76 1.5Mb 10ms DropTail
$ns_ duplex-link $n74  $n77 1.5Mb 10ms DropTail
$ns_ duplex-link $n77  $n78 1.5Mb 10ms DropTail
$ns_ duplex-link $n78  $n79 1.5Mb 10ms DropTail
$ns_ duplex-link $n79  $n80 1.5Mb 10ms DropTail
$ns_ duplex-link $n80  $n81 1.5Mb 10ms DropTail
$ns_ duplex-link $n70  $n81 1.5Mb 10ms DropTail
$ns_ duplex-link $n76  $n81 1.5Mb 10ms DropTail

# UDP Transport agent for the RSUs
set udp [new Agent/UDP]
$udp set class_ 2
set null [new Agent/Null]
$ns_ attach-agent $n70 $udp
$ns_ attach-agent $n71 $null
$ns_ connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns_ at 0.2 "$cbr start"

set udp1 [new Agent/UDP]
$udp1 set class_ 2
set null1 [new Agent/Null]
$ns_ attach-agent $n71 $udp1
$ns_ attach-agent $n72 $null1
$ns_ connect $udp1 $null1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$ns_ at 0.2 "$cbr1 start"

set udp2 [new Agent/UDP]
$udp2 set class_ 2
set null2 [new Agent/Null]
$ns_ attach-agent $n72 $udp2
$ns_ attach-agent $n73 $null2
$ns_ connect $udp2 $null2
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$ns_ at 0.2 "$cbr2 start"

set udp3 [new Agent/UDP]
$udp3 set class_ 2
set null3 [new Agent/Null]
$ns_ attach-agent $n73 $udp3
$ns_ attach-agent $n74 $null3
$ns_ connect $udp3 $null3
set cbr3 [new Application/Traffic/CBR]
$cbr3 attach-agent $udp3
$ns_ at 0.2 "$cbr3 start"

set udp4 [new Agent/UDP]
$udp4 set class_ 2
set null4 [new Agent/Null]
$ns_ attach-agent $n74 $udp4
$ns_ attach-agent $n75 $null4
$ns_ connect $udp4 $null4
set cbr4 [new Application/Traffic/CBR]
$cbr4 attach-agent $udp4
$ns_ at 0.2 "$cbr4 start"

set udp5 [new Agent/UDP]
$udp5 set class_ 2
set null5 [new Agent/Null]
$ns_ attach-agent $n75 $udp5
$ns_ attach-agent $n76 $null5
$ns_ connect $udp5 $null5
set cbr5 [new Application/Traffic/CBR]
$cbr5 attach-agent $udp5
$ns_ at 0.2 "$cbr5 start"

set udp6 [new Agent/UDP]
$udp6 set class_ 2
set null6 [new Agent/Null]
$ns_ attach-agent $n74 $udp6
$ns_ attach-agent $n77 $null6
$ns_ connect $udp6 $null6
set cbr6 [new Application/Traffic/CBR]
$cbr6 attach-agent $udp6
$ns_ at 0.2 "$cbr6 start"

set udp7 [new Agent/UDP]
$udp7 set class_ 2
set null7 [new Agent/Null]
$ns_ attach-agent $n70 $udp7
$ns_ attach-agent $n81 $null7
$ns_ connect $udp7 $null7
set cbr7 [new Application/Traffic/CBR]
$cbr7 attach-agent $udp7
$ns_ at 0.2 "$cbr7 start"

set udp8 [new Agent/UDP]
$udp8 set class_ 2
set null8 [new Agent/Null]
$ns_ attach-agent $n76 $udp8
$ns_ attach-agent $n81 $null8
$ns_ connect $udp8 $null8
set cbr8 [new Application/Traffic/CBR]
$cbr8 attach-agent $udp8
$ns_ at 0.2 "$cbr8 start"

set udp9 [new Agent/UDP]
$udp9 set class_ 2
set null9 [new Agent/Null]
$ns_ attach-agent $n77 $udp9
$ns_ attach-agent $n78 $null9
$ns_ connect $udp9 $null9
set cbr9 [new Application/Traffic/CBR]
$cbr9 attach-agent $udp9
$ns_ at 0.2 "$cbr9 start"

set udp10 [new Agent/UDP]
$udp10 set class_ 2
set null10 [new Agent/Null]
$ns_ attach-agent $n78 $udp10
$ns_ attach-agent $n79 $null10
$ns_ connect $udp10 $null10
set cbr10 [new Application/Traffic/CBR]
$cbr10 attach-agent $udp10
$ns_ at 0.2 "$cbr10 start"

set udp11 [new Agent/UDP]
$udp11 set class_ 2
set null11 [new Agent/Null]
$ns_ attach-agent $n79 $udp11
$ns_ attach-agent $n80 $null11
$ns_ connect $udp11 $null11
set cbr11 [new Application/Traffic/CBR]
$cbr11 attach-agent $udp11
$ns_ at 0.2 "$cbr11 start"

set udp12 [new Agent/UDP]
$udp12 set class_ 2
set null12 [new Agent/Null]
$ns_ attach-agent $n80 $udp12
$ns_ attach-agent $n81 $null12
$ns_ connect $udp12 $null12
set cbr12 [new Application/Traffic/CBR]
$cbr12 attach-agent $udp12
$ns_ at 0.2 "$cbr12 start"

$ns_ at 100.0 "$cbr stop"
$ns_ at 100.0 "$cbr1 stop"
$ns_ at 100.0 "$cbr2 stop"
$ns_ at 100.0 "$cbr3 stop"
$ns_ at 100.0 "$cbr4 stop"
$ns_ at 100.0 "$cbr5 stop"
$ns_ at 100.0 "$cbr6 stop"
$ns_ at 100.0 "$cbr7 stop"
$ns_ at 100.0 "$cbr8 stop"
$ns_ at 100.0 "$cbr9 stop"
$ns_ at 100.0 "$cbr10 stop"
$ns_ at 100.0 "$cbr11 stop"
$ns_ at 100.0 "$cbr12 stop"

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

for {set j 0} {$j < $val(nn)} {incr j} { 
	set tcp [new Agent/TCP/Newreno]
	$tcp set class_ 2
	set sink [new Agent/TCPSink]
	$ns_ attach-agent $n73 $tcp
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
	$ns_ attach-agent $n74 $tcp
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
	$ns_ attach-agent $n75 $tcp
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
	$ns_ attach-agent $n76 $tcp
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
	$ns_ attach-agent $n77 $tcp
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
	$ns_ attach-agent $n78 $tcp
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
	$ns_ attach-agent $n79 $tcp
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
	$ns_ attach-agent $n80 $tcp
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
	$ns_ attach-agent $n81 $tcp
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
    $ns_ at 100.0 "$node_($i) reset";
}
$ns_ at 100.0 "stop"
$ns_ at 100.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namf
    $ns_ flush-trace
    close $tracefd
	close $namf
}
# # $n70 label "RSU"
# # $n71 label "RSU"
# # $n72 label "RSU"

$n70 color red
$n71 color red
$n72 color red
$n73 color red
$n74 color red
$n75 color red
$n76 color red
$n77 color red
$n78 color red
$n79 color red
$n80 color red
$n81 color red

puts "Starting Simulation..."
$ns_ run

