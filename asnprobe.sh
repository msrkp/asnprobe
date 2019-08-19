#!/bin/bash

if [ $# -eq 0 ]
        then
                echo -e  "No args supplied\nUsage asnprobe.sh [asn.txt]";
                exit;
fi

for asn in `cat $1`; do
mkdir -p $asn

nmap --script targets-asn --script-args targets-asn.asn=$asn | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\/[0-9]\{1,3\}' > $asn/$asn.cidr.txt

while read cidr; do
        prips "$cidr" > $asn/$asn.ips.txt;
done < $asn/$asn.cidr.txt

if [ -s "$asn/$asn.ips.txt" ]
then
        echo "$asn has cidr";
        mkdir -p $asn/ports;
        while read ip; do
                sudo masscan -p1-65535,U1-65535 "$ip" > $asn/ports/$ip.ports;
        done < $asn/$asn.ips.txt
else 
        echo "$asn has empty cidr";
fi

done