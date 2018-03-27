require 'spec_helper'

describe 'docker_ddc' do
  context 'supported operating systems' do
    let(:default_socket_path)  { '/var/run/docker.sock' }
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'setting up a controller' do
          context 'with the minimum properties' do
      let(:params) { {'controller' => true } }
            it { is_expected.to compile.with_all_deps }
            it do
              should contain_class('Docker_ddc')
    .with_ensure('present')
                .with_controller(true)
                .with_tracking(true)
                .with_usage(true)
                .with_external_ca(false)
                .with_preserve_certs(false)
                .with_replica(false)
                .with_preserve_certs_on_delete(false)
                .with_preserve_images_on_delete(false)
                .with_replica(false)
                .with_username('admin')
                .with_password('orca')
                .with_docker_socket_path(default_socket_path)
              should contain_exec('Install Docker Universal Control Plane')
                .with_logoutput(true)
                .with_tries(3)
                .with_try_sleep(5)
                .with_command(/install/)
                .with_unless('docker inspect ucp-controller')
              should_not contain_exec('Install Docker Universal Control Plane')
                .with_command(/\-\-disable\-usage/)
              should_not contain_exec('Install Docker Universal Control Plane')
                .with_command(/\-\-disable\-tracking/)
              should_not contain_exec('Install Docker Universal Control Plane')
                .with_command(/\-\-preserve\-certs/)
              should_not contain_exec('Install Docker Universal Control Plane')
                .with_command(/\-\-external\-ucp\-ca/)
              should_not contain_exec('Install Docker Universal Control Plane')
                .with_command(/docker_subscription\.lic/)
            end
          end

          context 'with DNS options' do
            let(:params) do
              {
                'controller' => true,
                'dns_servers' => ['1.dns.example.com', '2.dns.example.com'],
                'dns_search_domains' => ['example.com'],
                'dns_options' => ['foo', 'bar'],
              }
            end
            it do
              should contain_exec('Install Docker Universal Control Plane')
                .with_command(/\-\-dns '1\.dns\.example\.com'/)
                .with_command(/\-\-dns '2\.dns\.example\.com'/)
                .with_command(/\-\-dns-search 'example\.com'/)
                .with_command(/\-\-dns-opt 'foo'/)
                .with_command(/\-\-dns-opt 'bar'/)
            end
          end

          context 'with multiple SAN values' do
            let(:params) do
              {
                'controller' => true,
                'subject_alternative_names' => ['one', 'two'],
              }
            end
            it do
              should contain_exec('Install Docker Universal Control Plane')
                .with_command(/\-\-san 'one'/)
                .with_command(/\-\-san 'two'/)
            end
          end

          context 'with a single SAN values' do
            let(:params) do
              {
                'controller' => true,
                'subject_alternative_names' => 'one',
              }
            end
            it { should contain_exec('Install Docker Universal Control Plane').with_command(/\-\-san 'one'/) }
          end

          context 'with a host address' do
            let(:params) do
              {
                'controller' => true,
                'host_address' => 'one.example.com',
              }
            end
            it { should contain_exec('Install Docker Universal Control Plane').with_command(/\-\-host-address 'one\.example\.com'/) }
          end

          context 'with a swarm port' do
      let(:params) do
              {
                'controller' => true,
                'swarm_port' => 1000,
              }
            end
            it { should contain_exec('Install Docker Universal Control Plane').with_command(/\-\-swarm\-port '1000'/) }
          end

          context 'with a controller port' do
      let(:params) do
              {
                'controller' => true,
                'controller_port' => 1001,
              }
            end
            it { should contain_exec('Install Docker Universal Control Plane').with_command(/\-\-controller\-port '1001'/) }
          end

          context 'with a license file' do
            let(:facts) {{:osfamily => 'RedHat', :operatingsystem => 'RedHat'}}
      let(:license_file) { '/path/to/file.lic' }
            let(:params) do
              {
                'controller' => true,
                'license_file' => license_file,
              }
            end
            it { should contain_exec('Install Docker Universal Control Plane').with_command(/\-v #{license_file}/) }
          end

          context 'disabling tracking and usage' do
            let(:params) do
              {
                'controller' => true,
                'tracking' => false,
                'usage' => false,
              }
            end
            it { should contain_exec('Install Docker Universal Control Plane').with_command(/\-\-disable\-usage/).with_command(/\-\-disable\-tracking/) }
          end

          [
            'tracking',
            'usage',
            'preserve_certs',
            'controller',
            'external_ca',
            'preserve_certs_on_delete',
            'preserve_images_on_delete',
            'replica',
          ].each do |param|
            context "passing an invalid value for #{param}" do
        let(:params) { { param => 'invalid' } }
              it do
                expect { # rubocop:disable Style/BlockDelimiters
                  should contain_exec('Install Docker Universal Control Plane')
                }.to raise_error(Puppet::Error, /expects a Boolean value/)
              end
            end
          end

          [
            'docker_socket_path',
            'license_file',
          ].each do |param|
            context "passing an invalid value for #{param}" do
              let(:params) { { param => 'invalid' } }
              it do
                expect { # rubocop:disable Style/BlockDelimiters
                  should contain_exec('Install Docker Universal Control Plane')
                }.to raise_error(Puppet::Error, /got 'invalid'/)
              end
            end
          end

          [
            'swarm_scheduler',
            'ensure',
          ].each do |param|
            context "passing an invalid value for #{param}" do
              let(:params) { { 'ensure' => 'invalid' } }
              it do
                expect { # rubocop:disable Style/BlockDelimiters
                  should contain_exec('Install Docker Universal Control Plane')
                }.to raise_error(Puppet::Error, /got 'invalid'/)
              end
            end
          end

          [
            'host_address',
            'version',
            'ucp_url',
            'ucp_id',
            'username',
            'password',
          ].each do |param|
            context "passing an invalid value for #{param}" do
              let(:params) { { param => 1234 } }
              it do
                expect { # rubocop:disable Style/BlockDelimiters
                  should contain_exec('Install Docker Universal Control Plane')
                }.to raise_error(Puppet::Error)
              end
            end
          end
          [
            'swarm_port',
            'controller_port',
          ].each do |param|
            context "passing an invalid value for #{param}" do
              let(:params) { { param => 'invalid' } }
              it do
                expect { # rubocop:disable Style/BlockDelimiters
                  should contain_exec('Install Docker Universal Control Plane')
                }.to raise_error(Puppet::Error, /Integer, got String/)
              end
            end
          end
        end

     context 'joining UCP v2' do
       context 'with the minimum properties v2' do
         let(:token) { 'abc' }
               let(:listen_address) { '192.168.1.1' }
               let(:advertise_address) { '192.168.1.1' }
               let(:ucp_manager) { '192.168.1.100' }
               let(:params) do
           {
       'version' => '2',
       'token' => token,
       'listen_address' => listen_address,
       'advertise_address' => advertise_address,
       'ucp_manager' => ucp_manager,
           }
         it do
     should contain_class('Docker_ucp')
     should contain_exec('Join Docker Universal Control Plane v2')
             .with_logoutput(true)
       .with_tries(3)
       .with_try_sleep(5)
       .with_command(/join/)
       .with_command(/\-\-token '#{token}'/)
       .with_command(/\-\-listen_addr '#{listen_address}'/)
       .with_command(/\-\-advertise_addr '#{advertise_address}'/)
       .with_unless('docker inspect ucp-proxy')
     should_not contain_exec('Install Docker Universal Control Plane')
       .with_command(/\-\-disable\-usage/)
     should_not contain_exec('Install Docker Universal Control Plane')
     should_not contain_exec('Join Docker Universal Control Plane v1')
                 end
               end
       end
           end

          context 'without passing a fingerprint' do
            let(:params) do
              {
                'ucp_url' => 'https://ucp',
    'version' => '2'
              }
            end
            it do
              contain_exec('Join Docker Universal Control Plane v2')
            end
          end

        context 'uninstalling UCP' do
          let(:ucp_id) { "1" }
          context 'with the minimum properties' do
            let(:facts) {{:osfamily => 'RedHat', :operatingsystem => 'RedHat' }}
      let(:params) do
              {
                'ensure' => 'absent',
                'ucp_id' => '1',
    'version' => '1',
    'local_client' => true,
              }
            end
            it do
              should contain_exec('Uninstall Docker Universal Control Plane')
                .with_logoutput(true)
                .with_tries(3)
                .with_try_sleep(5)
                .with_command(/uninstall/)
                .with_command(/\-v #{default_socket_path}/)
                .with_command(/\-\-id '#{ucp_id}'/)
                .with_onlyif('docker inspect ucp-proxy')
              should_not contain_exec('Uninstall Docker Universal Control Plane')
                .with_command(/\-\-preserve\-images/)
              should_not contain_exec('Uninstall Docker Universal Control Plane')
                .with_command(/\-\-preserve\-certs/)
            end
          end
  end
      end
    end
  end
end
