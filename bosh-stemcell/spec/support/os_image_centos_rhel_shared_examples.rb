shared_examples_for 'a CentOS or RHEL based OS image' do

  describe command('ls -1 /lib/modules | wc -l') do
    its(:stdout) { should eq "1\n" }
  end

  describe package('apt') do
    it { should_not be_installed }
  end

  describe package('rpm') do
    it { should be_installed }
  end

  describe user('vcap') do
    it { should be_in_group 'admin' }
    it { should be_in_group 'adm' }
    it { should be_in_group 'audio' }
    it { should be_in_group 'cdrom' }
    it { should be_in_group 'dialout' }
    it { should be_in_group 'floppy' }
    it { should be_in_group 'video' }
  end

  context 'installed by base_centos or base_rhel' do
    describe file('/etc/redhat-release') do
      it { should be_file }
    end

    describe file('/etc/sysconfig/network') do
      it { should be_file }
    end

    describe file('/etc/localtime') do
      its(:content) { should match 'UTC' }
    end

    describe file('/usr/lib/systemd/system/runit.service') do
      it { should be_file }
      its(:content) { should match 'Restart=always' }
      its(:content) { should match 'KillMode=process' }
    end

    describe service('NetworkManager') do
      it { should be_enabled }
    end
  end

  context 'installed by base_runsvdir' do
    describe file('/var/run') do
      it { should be_linked_to('/run') }
    end
  end

  context 'installed or excluded by base_centos_packages' do
    %w(
      firewalld
      mlocate
    ).each do |pkg|
      describe package(pkg) do
        it { should_not be_installed }
      end
    end
  end

  context 'installed by base_ssh' do
    subject(:sshd_config) { file('/etc/ssh/sshd_config') }

    it 'only allow 3DES and AES series ciphers (stig: V-38617)' do
      ciphers = %w(
        aes256-ctr
        aes192-ctr
        aes128-ctr
      ).join(',')
      expect(sshd_config.content).to match(/^Ciphers #{ciphers}$/)
    end

    it 'allows only secure HMACs and the weaker SHA1 HMAC required by golang ssh lib' do
      macs = %w(
        hmac-sha2-512
        hmac-sha2-256
      ).join(',')
      expect(sshd_config.content).to match(/^MACs #{macs}$/)
    end
  end

  context 'installed by system_kernel' do
    %w(
      kernel
      kernel-headers
    ).each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end
  end

  context 'readahead-collector should be disabled' do
    describe file('/etc/sysconfig/readahead') do
      it { should be_file }
      its(:content) { should match 'READAHEAD_COLLECT="no"' }
      its(:content) { should match 'READAHEAD_COLLECT_ON_RPM="no"' }
    end
  end

  context 'configured by cron_config' do
    describe file '/etc/cron.daily/man-db.cron' do
      it { should_not be_file }
    end
  end

  context 'package signature verification (stig: V-38462)' do
    describe command('grep nosignature /etc/rpmrc /usr/lib/rpm/rpmrc /usr/lib/rpm/redhat/rpmrc ~root/.rpmrc') do
      its (:stdout) { should_not include('nosignature') }
    end
  end

  context 'X Windows must not be enabled unless required (stig: V-38674)' do
    describe package('xorg-x11-server-Xorg') do
      it { should_not be_installed }
    end
  end

  context 'login and password restrictions' do
    describe file('/etc/pam.d/system-auth') do
      it 'must prohibit the reuse of passwords within twenty-four iterations (stig: V-38658)' do
        expect(subject.content).to match /password.*pam_unix\.so.*remember=24/
      end

      it 'must prohibit new passwords shorter than 14 characters (stig: V-38475)' do
        expect(subject.content).to match /password.*pam_unix\.so.*minlen=14/
      end

      it 'must restrict a user account after 5 failed login attempts (stig: V-38573 V-38501)' do
        expect(subject.content).to match /auth.*pam_unix.so.*\nauth.*default=die.*pam_faillock\.so.*authfail.*deny=5.*fail_interval=900\nauth\s*sufficient\s*pam_faillock\.so.*authsucc.*deny=5.*fail_interval=900/
      end
    end

    describe file('/etc/pam.d/password-auth') do
      it 'must restrict a user account after 5 failed login attempts (stig: V-38573 V-38501)' do
        expect(subject.content).to match /auth.*pam_unix.so.*\nauth.*default=die.*pam_faillock\.so.*authfail.*deny=5.*fail_interval=900\nauth\s*sufficient\s*pam_faillock\.so.*authsucc.*deny=5.*fail_interval=900/
      end
    end
  end
end
