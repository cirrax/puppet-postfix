

require 'spec_helper'

describe 'postfix::params' do
  let :facts do  { :osfamily => 'Debian' } end

  shared_examples_for 'postfix::params class' do
    it { is_expected.to compile.with_all_deps }
  end
  
  describe 'on Debian' do
     let :facts do  { :osfamily => 'Debian' } end
     it_behaves_like 'postfix::params class'
  end

  describe 'on OpenBSD' do
     let :facts do  { :osfamily => 'OpenBSD' } end
     it_behaves_like 'postfix::params class'
  end

end
