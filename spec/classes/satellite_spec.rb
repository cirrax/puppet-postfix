

require 'spec_helper'

describe 'postfix::satellite' do
  let(:pre_condition) { 'service {"postfix": }' }

  shared_examples_for 'postfix satellite' do

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('postfix::config::main') }
    it { is_expected.to contain_class('postfix::config::master') }
  end

  describe 'without parameters' do
    it_behaves_like 'postfix satellite'
  end
  
  describe 'with satellite package' do
    let :params do
      { :packages => ['mypackage'],
      }
    end
    it_behaves_like 'postfix satellite'

    it { is_expected.to contain_package('mypackage')
      .with( :ensure => 'present',
             :tag    => 'postfix',
      )
    }
  end

  describe 'with maps' do
    let :params do
      { :maps => { 'test-map' => {} },
      }
    end
    it_behaves_like 'postfix satellite'

    it { is_expected.to contain_postfix__map('test-map') }
  end

  describe 'with additional resources' do
    # use user resource to test (resource needs to be available)
    let :params do
      { :create_resources => { 'user' => {'usertitle' => {} } },
      }
    end
    it_behaves_like 'postfix satellite'

    it { is_expected.to contain_user('usertitle') }
  end

end
