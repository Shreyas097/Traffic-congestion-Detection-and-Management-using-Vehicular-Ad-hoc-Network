BEGIN{
}
{
event=$1;
time=$2;
node_source=$3;
pkt_size=$6;
node_destination=$4;
datarate=1000000;
if(event=="s"){
	sent++;
        sentSize+=pkt_size;
		if(!startTime || (time<startTime)){
		startTime=1.0;
		}
}
if(event=="r"){
	receive++;
		if(time>stopTime){
		stopTime=time;
		}
	recvdSize+=pkt_size;	
}
if(event=="d"){
	drop++;
		if(time>stopTime){
		stopTime=time;
		}
	dropsi+=pkt_size;	
}
}
END{
printf("Sent packets\t %d\n",sent)
printf("Dropped packets\t %d\n",drop)
printf("Received packets %d\n",receive)
printf("Size of data_sent %d\n",sentSize)
printf("Size of the received data %d\n",recvdSize)
printf("Size of dropped packets\t %d\n",dropsi)
printf("Packet Delivery Ratio %.2f\n",(receive/sent)*100);
G = (sentSize/((stopTime-startTime)*datarate))*8;
printf("G : %.2f\n",G);
th =G*(2.7^(-2*G)) ;
printf("Average Throughput in kbps= %.2f\tStartTime=%.2f\tStopTime=%.2f\n",th,startTime,stopTime);
}
