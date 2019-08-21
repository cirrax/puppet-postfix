
require 'spec_helper'

describe 'postfix::config::service' do
  let :facts do
    { osfamily: 'Debian' }
  end
  let :default_params do
    { master_cf_file: '/etc/postfix/master.cf' }
  end

  shared_examples 'postfix::config::service define' do
    context 'it compiles with all dependencies' do
      it { is_expected.to compile.with_all_deps }
    end

    context 'it includes concat_fragment' do
      it {
        is_expected.to contain_concat_fragment('master.cf service: ' + title)
          .with_target('/etc/postfix/master.cf')
      }
    end
  end

  context 'whith defaults' do
    let(:title) { 'debian' }
    let(:params) { default_params }

    it_behaves_like 'postfix::config::service define'
  end

  context 'on OpenBSD' do
    let(:title) { 'openbsd' }
    let :facts do
      { osfamily: 'OpenBSD' }
    end
    let(:params) { default_params }

    it_behaves_like 'postfix::config::service define'
  end

  context 'whith non defaults' do
    let(:title) { 'my-repo' }

    let :params do
      default_params.merge(
        type: 'fifo',
        command: 'fork',
        service_names: ['bah'],
        order: '100',
      )
    end

    it_behaves_like 'postfix::config::service define'
  end
end
