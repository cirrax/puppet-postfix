
require 'spec_helper'

describe 'postfix::config::service' do

  shared_examples 'postfix::config::service define' do

    context 'it compiles with all dependencies' do
      it { is_expected.to compile.with_all_deps }
    end

    context 'it includes concat_fragment' do
      it { is_expected.to contain_concat_fragment('master.cf service: ' + title)
	.with_target('/etc/postfix/master.cf')
      }
    end

  end

  context 'whith defaults' do
    let (:title) { 'debian' }

    it_behaves_like 'postfix::config::service define'

  end

  context 'whith non defaults' do
    let (:title) { 'my-repo' }

    let :params do
      { :type          => 'fifo',
        :command       => 'fork',
        :service_names => [ 'bah' ],
	:order         => '100',
      }
    end
    it_behaves_like 'postfix::config::service define'

  end
end

