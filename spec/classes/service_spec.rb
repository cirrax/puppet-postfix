
require 'spec_helper'

describe 'postfix::service' do
  let(:pre_condition) { 'package {"postfix": }' }
  let :facts do  { :osfamily => 'Debian' } end

  shared_examples_for 'postfix::service class' do

    it { is_expected.to compile.with_all_deps }

    it 'configures postfix service' do
      is_expected.to contain_service('postfix')
        .with(
          :name   => 'postfix',
          :ensure => 'running',
          :enable => true,
        )
    end
  end

   describe 'with defaults' do
     it_behaves_like 'postfix::service class'
     it { is_expected.to_not contain_exec('postfix-enable')}
     it { is_expected.to_not contain_service('smtpd')}
     it { is_expected.to_not contain_file( '/var/spool/postfix/etc/resolv.conf' )}
     it { is_expected.to_not contain_file( '/var/spool/postfix/etc/hosts')}
     it { is_expected.to_not contain_file( '/var/spool/postfix/etc/services')}
   end

   describe 'on OpenBSD' do
     let :facts do  { :osfamily => 'OpenBSD' } end
     let :params do
       { :disabled_services   => ['smtpd'],
         :exec_postfix_enable => true,
         :sync_chroot         => '/var/spool/postfix',
       }
     end

     it_behaves_like 'postfix::service class'

     it { is_expected.to contain_service('smtpd')
       .with(
        :ensure => 'stopped',
        :enable => false,
       )
       .with_before('Service[postfix]')
     }

     it { is_expected.to contain_exec('postfix-enable')
       .with_command('postfix-enable')
       .with_before('Service[postfix]')
     }

     it { is_expected.to contain_file( '/var/spool/postfix/etc/resolv.conf' )
       .with_source( '/etc/resolv.conf')
       .with_notify('Service[postfix]')
       .with_require('Package[postfix]')
     }
     it { is_expected.to contain_file( '/var/spool/postfix/etc/hosts')
       .with_source( '/etc/hosts')
       .with_notify('Service[postfix]')
       .with_require('Package[postfix]')
     }
     it { is_expected.to contain_file( '/var/spool/postfix/etc/services')
       .with_source( '/etc/services')
       .with_notify('Service[postfix]')
       .with_require('Package[postfix]')
     }

   end
end
