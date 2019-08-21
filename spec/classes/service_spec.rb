
require 'spec_helper'

describe 'postfix::service' do
  let(:pre_condition) { 'package {"postfix": }' }
  let :default_params do
    { exec_postfix_enable: false }
  end

  shared_examples_for 'postfix::service class' do
    it { is_expected.to compile.with_all_deps }

    it 'configures postfix service' do
      is_expected.to contain_service('postfix')
        .with(
          name: 'postfix',
          ensure: 'running',
          enable: true,
        )
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'with defaults' do
        let(:params) { default_params }

        it_behaves_like 'postfix::service class'
        it { is_expected.not_to contain_exec('postfix-enable') }
      end

      describe 'with sync chroot' do
        let :params do
          default_params.merge(
            sync_chroot: '/var/spool/postfix',
            exec_postfix_enable: true,
            disabled_services: [],
          )
        end

        it_behaves_like 'postfix::service class'
        it { is_expected.not_to contain_service('smtpd') }

        it {
          is_expected.to contain_file('/var/spool/postfix/etc/resolv.conf')
            .with_source('/etc/resolv.conf')
            .with_notify('Service[postfix]')
            .with_require('Package[postfix]')
        }
        it {
          is_expected.to contain_file('/var/spool/postfix/etc/hosts')
            .with_source('/etc/hosts')
            .with_notify('Service[postfix]')
            .with_require('Package[postfix]')
        }
        it {
          is_expected.to contain_file('/var/spool/postfix/etc/services')
            .with_source('/etc/services')
            .with_notify('Service[postfix]')
            .with_require('Package[postfix]')
        }
      end

      describe 'with disabled services' do
        let :params do
          default_params.merge(
            disabled_services: ['smtpd'],
            exec_postfix_enable: true,
            sync_chroot: '/var/spool/postfix',
          )
        end

        it_behaves_like 'postfix::service class'

        it {
          is_expected.to contain_service('smtpd')
            .with(
              ensure: 'stopped',
              enable: false,
            )
            .with_before('Service[postfix]')
        }

        it {
          is_expected.to contain_exec('postfix-enable')
            .with_command('postfix-enable')
            .with_before('Service[postfix]')
        }
      end
    end
  end
end
