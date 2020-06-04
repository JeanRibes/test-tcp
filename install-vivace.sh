#!/bin/bash
if [ -e /home/vagrant/pcc-vivace/tcp_pcc.ko ]
then
	echo "PCC vivace déjà compilé"
	exit 0
fi
set -e
apt-get update
apt-get install -y git build-essential "linux-headers-$(uname -r)" libelf-dev
git clone https://github.com/PCCproject/PCC-Kernel.git pcc-vivace || true
cd pcc-vivace
git checkout vivace # vivace->PPC Vivace, master->PCC Allegro
cd src
make
mv tcp_pcc.ko ../
cd ../..
