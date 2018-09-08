set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             100                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
# set floor size
set opt(x) 500
set opt(y) 500

set ns_		[new Simulator]
set tracefd     [open aodv.tr w]
set namf	[open aodv.nam w]
$ns_ namtrace-all-wireless $namf $opt(x) $opt(y)
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $opt(x) $opt(y)

#
# Create God
#
create-god $val(nn)

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

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
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace ON \
			 -movementTrace ON			
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;
		$ns_ initial_node_pos $node_($i) 20
		$node_($i) set X_ [ expr 10+round(rand()*480) ]
        $node_($i) set Y_ [ expr 10+round(rand()*380) ]
        $node_($i) set Z_ 0.0
	}
	
	for {set i 0} {$i < $val(nn) } { incr i } {
        $ns_ at [ expr 15+round(rand()*60) ] "$node_($i) setdest [ expr 10+round(rand()*480) ] [ expr 10+round(rand()*380) ] [ expr 2+round(rand()*15) ]"
        
    }




# Setup traffic flow between nodes
# TCP connections between node_(0) and node_(1)
for {set i 0} {$i < $val(nn) } {incr i} {
		set tcp($i) [new Agent/TCP]
		$tcp($i) set class_ 2
		set sink($i) [new Agent/TCPSink]
		$ns_ attach-agent $node_($i) $tcp($i)
		$ns_ attach-agent $node_($i) $sink($i)
		set ftp($i) [new Application/FTP]
		$ftp($i) attach-agent $tcp($i)
		incr k
}

$ns_ connect $tcp(0) $sink(1)
$ns_ connect $tcp(1) $sink(2)
$ns_ connect $tcp(2) $sink(3)
$ns_ connect $tcp(3) $sink(4)
$ns_ connect $tcp(4) $sink(0)

$ns_ at 1.0 "$ftp(0) start" 
$ns_ at 2.0 "$ftp(1) start" 
$ns_ at 3.0 "$ftp(2) start" 
$ns_ at 4.0 "$ftp(3) start" 
$ns_ at 4.0 "$ftp(4) start" 

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 100.0 "$node_($i) reset";
}
$ns_ at 100.0 "stop"
$ns_ at 100.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
	exec nam aodv.nam &
}

puts "Starting Simulation..."
$ns_ run

