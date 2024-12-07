
require 'spec_helper'

describe 'postfix::config::service' do
  let :default_params do
    { master_cf_file: '/etc/postfix/master.cf',
      order: '55', }
  end

  shared_examples 'postfix::config::service define' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_concat_fragment('master.cf service: ' + title)
        .with_target(params[:master_cf_file])
        .with_order(params[:order])
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'whith defaults' do
        let(:title) { 'smtp' }
        let(:params) { default_params }

        it_behaves_like 'postfix::config::service define'
      end

      context 'whith non defaults' do
        let(:title) { 'smtp' }

        let :params do
          default_params.merge(
            type: 'fifo',
            command: 'fork',
            service_names: ['smtp'],
            order: '100',
            master_cf_file: '/local/etc/postfix/master.cf',
          )
        end

        it_behaves_like 'postfix::config::service define'
      end
    end
  end
end
