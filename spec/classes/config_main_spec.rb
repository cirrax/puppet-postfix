
require 'spec_helper'
describe 'postfix::config::main' do
  let(:pre_condition) { 'service {"postfix": }' }
  let :default_params do
    { main_cf_file: '/etc/postfix/main.cf',
      owner: 'root',
      group: 'root',
      mode: '0644' }
  end

  shared_examples_for 'postfix::config::main class' do
    it { is_expected.to compile.with_all_deps }
    it 'configures postfix main_cf_file' do
      is_expected.to contain_file('/etc/postfix/main.cf')
        .with(
          owner: 'root',
          mode: '0644',
        )
        .with_notify('Service[postfix]')
        .with_content(%r{^#})
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'with default params' do
        let(:params) { default_params }

        it_behaves_like 'postfix::config::main class'
      end

      describe 'with default non params' do
        let :params do
          default_params.merge(
            main_cf_file: '/tmp/postfix.cf',
            owner: 'one',
            group: 'two',
            mode: '4242',
          )
        end

        it 'configures postfix main_cf_file' do
          is_expected.to contain_file('/tmp/postfix.cf')
            .with(
              owner: 'one',
              group: 'two',
              mode: '4242',
            )
            .with_notify('Service[postfix]')
            .with_content(%r{^#})
        end
      end
    end
  end
end
