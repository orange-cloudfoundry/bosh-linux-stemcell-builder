#!/usr/bin/env bash

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/stages/bosh_audit/shared_functions.bash
source $base_dir/lib/prelude_bosh.bash

pkg_mgr install auditd

# Without this, auditd will read from /etc/audit/audit.rules instead
# of /etc/audit/rules.d/*.
if [[ "${OS_TYPE}" == "ubuntu" ]]; then
   cp $chroot/lib/systemd/system/auditd.service $chroot/etc/systemd/system/auditd.service
   sed -i '/#ExecStartPost=-\/sbin\/augenrules --load/s/^#//g' $chroot/etc/systemd/system/auditd.service
   sed -i '/ExecStartPost=-\/sbin\/auditctl -R \/etc\/audit\/audit.rules/s/^/#/g' $chroot/etc/systemd/system/auditd.service
   run_in_bosh_chroot $chroot "systemctl disable auditd.service"
   run_in_bosh_chroot $chroot "chown root:root /var/log/audit" # (stig: V-38663) (stig: V-38664) (stig: V-38665)
else
   sed -i 's/^USE_AUGENRULES="[Nn][Oo]"$/USE_AUGENRULES="yes"/' $chroot/etc/default/auditd
   run_in_bosh_chroot $chroot "update-rc.d auditd disable"
fi

write_shared_audit_rules

record_use_of_privileged_binaries

override_default_audit_variables
