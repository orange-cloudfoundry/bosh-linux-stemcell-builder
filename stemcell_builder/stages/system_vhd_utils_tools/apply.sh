#!/usr/bin/env bash
#
set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash

opt=""
if [ ! -z "${http_proxy}" ]; then
    opt="${opt} -o Acquire::http::Proxy=http://${http_proxy}"
fi

if [ ! -z "${https_proxy}" ]; then
    opt="${opt} -o Acquire::https::Proxy=https://${https_proxy}"
fi
sudo apt-get install -y uuid-dev ${opt}

cd /tmp
rm -rf vhd-util-convert
#git clone https://github.com/rubiojr/vhd-util-convert
git clone https://github.com/rubiojr/vhd-util-convert
cd vhd-util-convert
make
#install vhd-util in the vagrant stemcell builder host
sudo cp vhd-util /usr/local/bin/
