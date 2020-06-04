#!/bin/bash
if [ -e /home/vagrant/pcc-allegro/tcp_pcc.ko ]
then
	echo "pcc allegro déjà compilé"
	exit 0
fi
set -e
apt-get update
apt-get install -y git build-essential "linux-headers-$(uname -r)" libelf-dev
git clone https://github.com/PCCproject/PCC-Kernel.git pcc-allegro || true
cd pcc-allegro
git checkout master
cd src
make
mv tcp_pcc.ko ../
cd ../..
