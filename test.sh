#!/bin/bash
for i in scalable bbr yeah vegas illinois bic hybla highspeed westwood nv htcp cdg veno lp;do
	modprobe "tcp_$i"
done

#for i in $(sysctl net.ipv4.tcp_available_congestion_control | awk -F'=' '{print $2}'); do
#	echo "Pour activer TCP $i, entrez la commande:"
# 	echo "sysctl -w net.ipv4.tcp_congestion_control=$i"
#	echo "\n"
#done
DOWNFILE=$(mktemp)
UPFILE=$(mktemp)
mkdir -p /vagrant/resultats
chown vagrant:vagrant /vagrant/resultats
test_download () { # 1er argument: nom de l'algo
	for x in $(seq 1 10); do
		res=$(curl -w "%{time_total},%{size_download},%{speed_download}" -k -4 -o NUL https://www.insa-lyon.fr/sites/www.insa-lyon.fr/files/styles/slider_home/public/slider/taxe-apprentissage_insalyon-2020.png 2>&1|tail -n1)
		time_total=$(echo $res | cut -f1 -d',')
		size_download=$(echo $res | cut -f2 -d',')
		speed_download=$(echo $res | cut -f3 -d',')
		echo "$1,$res" >> $DOWNFILE
		echo "${time_total}s, ${speed_download}o/s  (${size_download}o)  <<(DOWN)-- $1"
	done
}

curl http://bouygues.testdebit.info/1M/1M.jpg > 1M.jpg
test_upload () { #1er arg: algo
	for x in $(seq 1 10); do
		res=$(curl -w "%{time_total},%{size_upload},%{speed_upload}" -k -4 -o NUL -F "filecontent=@1M.jpg" http://bouygues.testdebit.info 2>&1 | tail -n1)
		echo "$1,$res" >> $UPFILE
		echo "$res  --(UP)>> $1"
	done
}
echo "téléchargement d'une image depuis l'INSA,,," > $DOWNFILE
echo "algo,temps(s),taille(octets),débit utile(o/s)" >> $DOWNFILE

echo "envoi d'une image de 1Mo vers testdebit bouyges,,," > $UPFILE
echo "algo,temps(s),taille(octets),débit utile(o/s)" >> $UPFILE

echo "tests TCP"
for algo in $(sysctl net.ipv4.tcp_available_congestion_control | awk -F'=' '{print $2}'); do
 	sysctl -w net.ipv4.tcp_congestion_control=$algo > /dev/null
	test_download "$(sysctl net.ipv4.tcp_congestion_control | awk -F' = ' '{print $2}')"
	test_upload "$(sysctl net.ipv4.tcp_congestion_control | awk -F' = ' '{print $2}')"
done

echo "tests PCC"
echo "pcc allegro"
rmmod tcp_pcc > /dev/null
insmod /home/vagrant/pcc-allegro/tcp_pcc.ko
sysctl -w net.ipv4.tcp_congestion_control=pcc > /dev/null
test_download "vivace"
test_upload "vivace"
echo "pcc vivace"
sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null #on désactive pcc allegro avant de l'enlever
rmmod tcp_pcc
insmod /home/vagrant/pcc-vivace/tcp_pcc.ko
sysctl -w net.ipv4.tcp_congestion_control=pcc > /dev/null
test_download "allegro"
test_upload "allegro"
cp $UPFILE /vagrant/resultats/
cp $DOWNFILE /vagrant/resultats/
chown vagrant:vagrant /vagrant/resultats/*
echo "consultez les résultats descendants dans ce fichier : $(echo $DOWNFILE|cut -f3 -d'/')"
echo "consultez les résultats montat dans ce fichier : $(echo $UPFILE|cut -f3 -d'/')"

echo "Pour relancer le test, tapez la commande:"
echo "vagrant provision"
echo "(redémarrage à cause d'un bug où on ne peut pas changer la version de PCC)"
poweroff