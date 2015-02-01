#!/bin/bash
#################################
#	ROUTING SCRIPT		#
#      Clément Mouline		#
#	  ALPHA 0.1		#
#################################


echo -n "Interface LAN (ex: \"eth0\"): "; read intLAN
echo -n "Interface WAN (ex: \"eth1\"): "; read intWAN
echo -n "Adresse reseau LAN (ex: \"10.128.0.0\"): "; read ipLAN
echo -n "Adresse reseau WAN (ex: \"42.42.42.0\"): "; read ipWAN
echo -n "CIDR LAN (ex: \"16\"): "; read cidrLAN
echo -n "CIDR WAN (ex: \"24\"): "; read cidrWAN
echo -n "Adresse ip intrafece LAN (ex: \"10.128.0.1\"): "; read ipIntLAN
echo -n "Adresse ip interface WAN (ex: \"42.42.42.42\"): "; read ipIntWAN
echo -n "Passerelle par defaut (ex: \"42.42.42.1\"): "; read defaultGateway

#CONFIGURATION DES INTERFACES
killall NetworkManager
killall dhclient
ifconfig $intLAN down
ifconfig $intWAN down
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 > /proc/sys/net/ipv4/ip_forward
ifconfig $intLAN up; ifconfig $intLAN $ipIntLAN/$cidrLAN
ifconfig $intWAN up; ifconfig $intWAN $ipIntWAN/$cidrWAN
route add -net default gw $defaultGateway dev $intWAN

#CLEANNING UP IPTABLES TABLES
iptables -t filter -F
iptables -t filter -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -X
iptables -t mangle -F

#MASQUERADE
iptables -t nat -A POSTROUTING -s $ipLAN/$cidrLAN -j SNAT --to-source $ipIntWAN

#REGLES FORWARD
#iptables -t filter -P FORWARD DROP
#iptables -t filter -A FORWARD -i $intWAN -d $ipLAN/$cidrLAN -m state --state RELATED,ESTABLISHED -j ACCEPT #ACCEPTER LES CONNEXIONS EXISTANTES ET ATTENDUES EN ENTREE NAT
#iptables -t filter -A FORWARD -i $intWAN -d $ipLAN/$cidrLAN -p tcp --sport 80 -m state --state NEW -j ACCEPT #ACCEPTER LES CONNEXIONS ISSUES DU PAT
#iptables -t filter -A FORWARD -i $intLAN -s $ipLAN/$cidrLAN -p tcp --dport 80 -j ACCEPT
#iptables -t filter -A FORWARD -i $intLAN -s $ipLAN/$cidrLAN -d 173.252.96.0/19 -j REJECT --reject-with icmp-net-prohibited #REJETER LA CONNAXION A UN HOST
#iptables -t filter -A FORWARD -i $intLAN -s $ipLAN/$cidrLAN -p tcp -m multiport --dports 53,80,443,465,587,993,2222 -j ACCEPT #ACCEPTER CES PORTS EN TCP
#iptables -t filter -A FORWARD -i $intLAN -s $ipLAN/$cidrLAN -p udp -m multiport --dports 53 -j ACCEPT #ACCEPTER  CES PORTS EN UDP
#iptables -t filter -A FORWARD -i $intLAN -s $ipLAN/$cidrLAN -p icmp -j ACCEPT #ICMP
#iptables -t filter -A FORWARD -i $intLAN -s $ipLAN/$cidrLAN -j REJECT --reject-with icmp-net-prohibited

#PORT FORWARDING
#iptables -t nat -A PREROUTING -d $ipIntWAN -p tcp --dport 80 -j DNAT --to-destination  10.128.0.42
