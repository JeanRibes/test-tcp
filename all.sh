#!/bin/bash
for i in scalable bbr yeah vegas illinois bic hybla highspeed westwood nv htcp cdg veno lp;do
	modprobe "tcp_$i"
done

#for i in $(sysctl net.ipv4.tcp_available_congestion_control | awk -F'=' '{print $2}'); do
#	echo "Pour activer TCP $i, entrez la commande:"
# 	echo "sysctl -w net.ipv4.tcp_congestion_control=$i"
#	echo "\n"
#done
FILE=$(mktemp)

test_debit () { # 1er argument: nom de l'algo
	res=$(curl -w "%{time_total},%{size_download},%{speed_download}" https://www.insa-lyon.fr/sites/www.insa-lyon.fr/files/styles/slider_home/public/slider/taxe-apprentissage_insalyon-2020.png -o /dev/null 2>&1|tail -n1)
	time_total=$(echo $res | cut -f1 -d',')
	size_download=$(echo $res | cut -f2 -d',')
	speed_download=$(echo $res | cut -f3 -d',')
	echo "$1,$res" >> $FILE
	echo "${time_total}s, ${speed_download}o/s  (${size_download}o)  <<-- $1"
}

echo "algo,temps(s),taille(octets),vitesse(o/s)" > $FILE

echo "test de débit"
for algo in $(sysctl net.ipv4.tcp_available_congestion_control | awk -F'=' '{print $2}'); do
 	sysctl -w net.ipv4.tcp_congestion_control=$algo > /dev/null
	test_debit "$(sysctl net.ipv4.tcp_congestion_control | awk -F' = ' '{print $2}')"
done

echo "tests PCC"
echo "pcc allegro"
rmmod tcp_pcc > /dev/null
insmod /home/vagrant/pcc-allegro/tcp_pcc.ko
sysctl -w net.ipv4.tcp_congestion_control=pcc > /dev/null
test_debit "vivace"

echo "pcc vivace"
sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null #on désactive pcc allegro avant de l'enlever
rmmod tcp_pcc
insmod /home/vagrant/pcc-vivace/tcp_pcc.ko
sysctl -w net.ipv4.tcp_congestion_control=pcc > /dev/null
test_debit "allegro"
echo "consultez les résultats dans ce fichier : $FILE"
