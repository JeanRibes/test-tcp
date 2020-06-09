#!/bin/bash

if [ -e /home/vagrant/ccp-kernel ]
then
  echo "ccp déjà installé"
else
  apt-get install -y build-essential "linux-headers-$(uname -r)" libelf-dev
  curl https://sh.rustup.rs -sSf | sh -s -- -y -v --default-toolchain nightly
  source $HOME/.cargo/env
  git clone https://github.com/ccp-project/ccp-kernel.git
  cd ccp-kernel
  git submodule update --init --recursive
  make
  ./ccp_kernel_load ipc=0
  rmmod ccp

  cd ..
  git clone https://github.com/venkatarun95/ccp_copa.git
  cd ccp_copa
  cargo build
fi
