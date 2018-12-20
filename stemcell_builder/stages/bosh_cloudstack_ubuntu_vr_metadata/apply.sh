#!/usr/bin/env bash

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash



mkdir -p $chroot/tmp/mdproxy4cs/
cp $(dirname $0)/assets/install.sh

run_in_chroot $chroot "sudo bash /tmp/mdproxy4cs/install.sh"
