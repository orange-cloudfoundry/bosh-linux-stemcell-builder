require 'shellout_types/file'
require 'shellout_types/package'
require 'shellout_types/user'
require 'shellout_types/command'
require 'shellout_types/service'
require 'shellout_types/group'
require 'shellout_types/chroot'

module ShelloutTypes
  module Assertions
    def file(file_path, chroot=ShelloutTypes::Chroot.new)
      ShelloutTypes::File.new(file_path, chroot)
    end

    def package(package_name)
      ShelloutTypes::Package.new(package_name, ShelloutTypes::Chroot.new)
    end

    def user(user_name)
      ShelloutTypes::User.new(user_name, ShelloutTypes::Chroot.new)
    end

    def command(cmd)
      ShelloutTypes::Command.new(cmd, ShelloutTypes::Chroot.new)
    end

    def service(service_name)
      ShelloutTypes::Service.new(service_name, ShelloutTypes::Chroot.new)
    end

    def group(group_name)
      ShelloutTypes::Group.new(group_name, ShelloutTypes::Chroot.new)
    end

    def no_chroot
      ShelloutTypes::Chroot.new('/')
    end
  end
end

module Bosh::Stemcell
  module SpecAssets
    def spec_asset(name)
      File.expand_path(File.join('..', 'assets', name), File.dirname(__FILE__))
    end
  end
end

RSpec.configure do |config|
  config.include(Bosh::Stemcell::SpecAssets)
  config.extend(ShelloutTypes::Assertions)
  config.include(ShelloutTypes::Assertions)
end
