#!/usr/bin/env bash

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash


# uncompress xen-tools into chroot's tmp
mkdir -p $chroot/tmp/xen-tools/
tar xvzf $(dirname $0)/assets/xgu-7.3.0-1.tar.gz -C $chroot/tmp/xen-tools/

# run xen-tools install script
run_in_chroot $chroot "sudo bash /tmp/xen-tools/install.sh"
