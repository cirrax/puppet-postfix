

require 'spec_helper'

describe 'postfix' do
  let :facts do  { :osfamily => 'Debian' } end

  shared_examples_for 'postfix server' do

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('postfix::config::main') }
    it { is_expected.to contain_class('postfix::config::master') }
    it { is_expected.to contain_class('postfix::service') }
    it { is_expected.to contain_package('postfix')
      .with( :ensure => 'present',
             :tag    => 'postfix-packages',
      )
    }
  end

  describe 'without parameters' do
    it_behaves_like 'postfix server'

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
  
  describe 'with server package' do
    let :params do
      { :packages => ['mypackage', 'postfix'],
      }
    end
    it_behaves_like 'postfix server'

    it { is_expected.to contain_package('mypackage')
      .with( :ensure => 'present',
             :tag    => 'postfix-packages',
      )
    }
  end

  describe 'with maps' do
    let :params do
      { :maps => { 'test-map' => {} },
      }
    end
    it_behaves_like 'postfix server'

    it { is_expected.to contain_postfix__map('test-map') }
  end

  describe 'with additional resources' do
    # use user resource to test (resource needs to be available)
    let :params do
      { :create_resources => { 'user' => {'usertitle' => {} } },
      }
    end
    it_behaves_like 'postfix server'

    it { is_expected.to contain_user('usertitle') }
  end

  describe 'on OpenBSD' do
    let :facts do  { :osfamily => 'OpenBSD' } end

    it_behaves_like 'postfix server'

    it { is_expected.to contain_file('/etc/postfix/ssl')
      .with( :ensure => 'directory',
             :owner  => 'root',
             :group  => 'wheel',
             :mode   => '0755',
      )
    }
    it { is_expected.to contain_file('/etc/postfix/maps')
      .with( :ensure => 'directory',
             :owner  => 'root',
             :group  => 'wheel',
             :mode   => '0755',
      )
    }
  end


end
