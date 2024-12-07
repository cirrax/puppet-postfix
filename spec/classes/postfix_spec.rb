

require 'spec_helper'

describe 'postfix' do
  let :default_params do
    { services: {} }
  end

  shared_examples_for 'postfix server' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('postfix::config::main') }
    it { is_expected.to contain_class('postfix::config::master') }
    it { is_expected.to contain_class('postfix::service') }
    it {
      is_expected.to contain_package('postfix')
        .with(ensure: 'installed',
              tag: 'postfix-packages')
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'with defaults' do
        let(:params) { default_params }

        it_behaves_like 'postfix server'
        it {
          is_expected.to contain_file('/etc/postfix/ssl')
            .with(ensure: 'directory',
                  owner: 'root',
                  mode: '0755')
        }
        it {
          is_expected.to contain_file('/etc/postfix/maps')
            .with(ensure: 'directory',
                  owner: 'root',
                  mode: '0755')
        }
      end

      describe 'with server package' do
        let :params do
          default_params.merge(
                    { packages: ['mypackage', 'postfix'] },
                  )
        end

        it_behaves_like 'postfix server'

        it {
          is_expected.to contain_package('mypackage')
            .with(ensure: 'installed',
                  tag: 'postfix-packages')
        }
      end

      describe 'with maps' do
        let :params do
          default_params.merge(
                    { maps: { 'test-map' => {} } },
                  )
        end

        it_behaves_like 'postfix server'

        it { is_expected.to contain_postfix__map('test-map') }
      end

      describe 'with additional resources' do
        # use user resource to test (resource needs to be available)
        let :params do
          default_params.merge(
                    { create_resources: { 'user' => { 'usertitle' => {} } } },
                  )
        end

        it_behaves_like 'postfix server'

        it { is_expected.to contain_user('usertitle') }
      end
    end
  end
end
