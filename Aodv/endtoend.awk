BEGIN {
 
}
{
 event=$1;
  time=$2;
  node_source=$3;
  pkt_size=$6;
  node_destination=$4;
  packet_id=$12;
 if(packet_id>count)count=packet_id;
 if(queuetime[packet_id]==0 && (event=="+" && node_destination==3)) {
  queuetime[packet_id]=time;
   }
 if(event!="d" && node_destination==3){
 if(event=="r" && node_destination==3){
     endtime[packet_id]=time;
}
}else{
endtime[packet_id]=-1;
}
if(event=="r" && node_destination==3){
received++;
if(time>stopTime){
stopTime=time;
}
receivedSize+=pkt_size;
}
}
END{
for(packet_id=0;packet_id<=count;packet_id++){
start=queuetime[packet_id];
end=endtime[packet_id];
if(end!=-1){

id = packet_id;
packet_duration=end-start;
if(start<end)
   printf("%d %f\n",id,packet_duration,start);
   printf("%d %f\n",id,packet_duration) > "endtoend.txt";
}
}
}