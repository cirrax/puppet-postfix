
require 'spec_helper'

describe 'postfix::map' do
  let(:pre_condition) { 'service {"postfix": }' }
  let :default_params do
    { map_dir: '/etc/postfix/maps',
      map_name: 'the-title',
      type: 'hash',
      postmap_command: '/usr/sbin/postmap',
      owner: 'root',
      group: 'root',
      mode: '0644' }
  end

  shared_examples 'postfix::map define' do
    context 'it compiles with all dependencies' do
      it { is_expected.to compile.with_all_deps }
    end

    it {
      is_expected.to contain_concat(params[:map_dir] + '/' + params[:map_name])
        .with(owner: params[:owner],
              mode: params[:mode])
        .with_notify('Service[postfix]')
    }

    it {
      is_expected.to contain_exec('rebuild map ' + title)
        .with_command(params[:postmap_command] + ' ' + params[:type] + ':' + params[:map_dir] + '/' + params[:map_name])
        .with_require('Concat[' + params[:map_dir] + '/' + params[:map_name] + ']')
        .with_notify('Service[postfix]')
        .with_unless("test #{params[:map_dir]}/#{params[:map_name]}.db -nt #{params[:map_dir]}/#{params[:map_name]}")
    }
  end
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'whith defaults' do
        let(:title) { 'the-title' }
        let(:params) { default_params }

        it_behaves_like 'postfix::map define'
      end

      context 'whith content defined' do
        let(:title) { 'the-title' }
        let :params do
          default_params.merge(contents: ['blah1', 'blah2'])
        end

        it_behaves_like 'postfix::map define'
        it {
          is_expected.to contain_concat__fragment('postfix::map: content fragment ' + title)
            .with_target('/etc/postfix/maps/' + title)
            .with_content("blah1\nblah2")
        }
      end

      context 'with source defined' do
        let(:title) { 'the-title' }
        let :params do
          default_params.merge(source: 'a_source')
        end

        it_behaves_like 'postfix::map define'
        it {
          is_expected.to contain_concat__fragment('postfix::map: source fragment ' + title)
            .with_target('/etc/postfix/maps/' + title)
            .with_source('a_source')
        }
      end

      context 'whith btree map type' do
        let(:title) { 'the-title' }
        let :params do
          default_params.merge(type: 'btree')
        end

        it_behaves_like 'postfix::map define'
      end

      context 'whith custom map path and name' do
        let(:title) { 'the-title' }
        let :params do
          default_params.merge(
            map_dir: '/blah/fasel',
            map_name: 'myname',
          )
        end

        it_behaves_like 'postfix::map define'
      end

      context 'whith custom postmap' do
        let(:title) { 'test-map' }

        let :params do
          default_params.merge(
            postmap_command: 'my_postmap_command',
          )
        end

        it_behaves_like 'postfix::map define'
      end

      context 'whith unknown map type' do
        let(:title) { 'the-title' }

        let :params do
          default_params.merge(
            type: 'fifo',
          )
        end

        it {
          is_expected.not_to contain_exec('rebuild map ' + title)
        }
      end
    end
  end
end
