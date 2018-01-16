
require 'spec_helper'

describe 'postfix::service' do
  let(:pre_condition) { 'package {"postfix": }' }

  it { is_expected.to compile.with_all_deps }

  it 'configures postfix service' do
    is_expected.to contain_service('postfix')
      .with(
        :name   => 'postfix',
        :ensure => 'running',
        :enable => true,
	:require => 'Package[postfix]'
      )
  end
end
