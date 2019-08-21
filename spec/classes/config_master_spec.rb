
require 'spec_helper'

describe 'postfix::config::master' do
  let(:pre_condition) { 'service {"postfix": }' }
  let :facts do
    { osfamily: 'Debian' }
  end
  let :default_params do
    { master_cf_file: '/etc/postfix/master.cf',
      owner: 'root',
      group: 'root',
      mode: '0644' }
  end

  shared_examples_for 'postfix::config::master class' do
    it { is_expected.to compile.with_all_deps }
  end

  describe 'with default params' do
    let(:params) { default_params }

    it_behaves_like 'postfix::config::master class'

    it 'configures postfix main_cf_file' do
      is_expected.to contain_concat('/etc/postfix/master.cf').with(
        owner: 'root',
        group: 'root',
        mode: '0644',
      )
    end

    context 'it includes concat_fragment' do
      it {
        is_expected.to contain_concat_fragment('postfix: master_cf_header')
          .with_target('/etc/postfix/master.cf')
          .with_order('00')
          .with_content(%r{^#})
      }
    end
  end

  describe 'with default non params' do
    let :params do
      default_params.merge(
        master_cf_file: '/tmp/postfix.cf',
        owner: 'one',
        group: 'two',
        mode: '4242',
      )
    end

    it_behaves_like 'postfix::config::master class'

    it 'configures postfix main_cf_file' do
      is_expected.to contain_concat('/tmp/postfix.cf').with(
        owner: 'one',
        group: 'two',
        mode: '4242',
      )
    end

    context 'it includes concat_fragment' do
      it {
        is_expected.to contain_concat_fragment('postfix: master_cf_header')
          .with_target('/tmp/postfix.cf')
      }
    end
  end

  describe 'on OpenBSD' do
    let :facts do
      { osfamily: 'OpenBSD' }
    end
    let :params do
      default_params.merge(
        group: 'wheel',
      )
    end

    it_behaves_like 'postfix::config::master class'

    it {
      is_expected.to contain_concat('/etc/postfix/master.cf')
        .with(
          owner: 'root',
          group: 'wheel',
          mode: '0644',
        )
        .with_notify('Service[postfix]')
    }
  end
end
