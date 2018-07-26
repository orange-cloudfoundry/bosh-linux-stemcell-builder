#!/usr/bin/env bash
#


set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash

##download xenserver tools iso distrib to extract tools
#
#rm -rf ${work}/xenserver
#mkdir ${work}/xenserver
#wget http://boot.rackspace.com/files/xentools/xs-tools-6.5.0-20200.iso -O ${work}/xenserver/xs-tools-6.5.0-20200.iso  
#
#
#
##mount iso
#iso_mount_path=`mktemp -d`
#echo "Mounting xenserver iso from at $iso_mount_path"
#mount -o loop -t iso9660 ${work}/xenserver/xs-tools-6.5.0-20200.iso $iso_mount_path
#add_on_exit "umount $iso_mount_path"
#
##extract and copy tools
#cp -R $iso_mount_path/Linux/ $chroot/tmp
#
#
##install tools in chroot
##run_in_chroot $chroot "sudo dpkg -i /tmp/xe-guest-utilities_6.5.0-1427_amd64.deb"
#run_in_chroot $chroot "sudo /tmp/Linux/install.sh"
#cp -f $(dirname $0)/assets/xe-linux-distribution $chroot/etc/init.d
#run_in_chroot $chroot "sudo chmod ugo+x /etc/init.d/xe-linux-distribution"
#
#
#run_in_chroot $chroot "wget http://archive.ubuntu.com/ubuntu/pool/universe/x/xe-guest-utilities/xe-guest-utilities_7.4.0-0ubuntu1_amd64.deb -P $chroot/tmp/"
#run_in_chroot $chroot "sudo dpkg -i $chroot/tmp/xe-guest-utilities_7.4.0-0ubuntu1_amd64.deb"

cp  $(dirname $0)/assets/xe-guest-utilities_7.4.0-0ubuntu1_amd64.deb  $chroot/tmp/
run_in_chroot $chroot "sudo dpkg -i  /tmp/xe-guest-utilities_7.4.0-0ubuntu1_amd64.deb"
