#!/bin/bash
#tag::installksonnet[]
#Configuration
## You may customize the version here
export KS_VER=0.11.0
## You may customize the operating system for the binary
export OS=linux_amd64
export KS_BIN=ks_${KS_VER}_${OS}
wget -O /tmp/${KS_BIN}.tar.gz https://github.com/ksonnet/ksonnet/releases/download/v${KS_VER}/${KS_BIN}.tar.gz
mkdir -p ${HOME}/bin
tar -xvf /tmp/${KS_BIN}.tar.gz -C ${HOME}/bin
export PATH=$PATH:${HOME}/bin/${KS_BIN}
#end::installksonnet[]
