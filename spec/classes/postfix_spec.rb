
require 'spec_helper'

describe 'postfix' do

  shared_examples_for 'postfix class' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('postfix::service') }

    it { is_expected.to contain_package('postfix')
      .with( :ensure => 'present',
             :tag    => 'postfix',
      )
    }

    it { is_expected.to contain_file('/etc/postfix/ssl')
      .with( :ensure => 'directory',
             :owner  => 'root',
	     :group  => 'root',
	     :mode   => '0755',
      )
    }
    it { is_expected.to contain_file('/etc/postfix/maps')
      .with( :ensure => 'directory',
             :owner  => 'root',
	     :group  => 'root',
	     :mode   => '0755',
      )
    }
  end

  describe 'configured as satellite' do
    it_behaves_like 'postfix class'

    it { is_expected.to contain_class('postfix::satellite') }
    it { is_expected.not_to contain_class('postfix::server') }
  end

  describe 'configured as server' do
    let :params do
      { :is_satellite => false
      }
    end
    it_behaves_like 'postfix class'

    it { is_expected.not_to contain_class('postfix::satellite') }
    it { is_expected.to contain_class('postfix::server') }
  end

end
