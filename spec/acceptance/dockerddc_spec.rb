require 'spec_helper_acceptance'
hosts.each do |host|
  vmhostname = on(host, 'hostname', acceptable_exit_codes: [0]).stdout.strip
  vmipaddr = on(host, "ip route get 8.8.8.8 | awk '{print $NF; exit}'", acceptable_exit_codes: [0]).stdout.strip

  describe 'the Puppet Docker module' do
    context 'clean up before each test' do
      before(:each) do
        # Stop all container using systemd
        shell('ls -D -1 /etc/systemd/system/docker-container* | sed \'s/\/etc\/systemd\/system\///g\' | sed \'s/\.service//g\' | while read container; do service $container stop; done')
        # Delete all running containers
        shell('docker rm -f $(docker ps -a -q) || true')
        # Delete all existing images
        shell('docker rmi $(docker images -q) || true')
        # Check to make sure no images are present
        shell('docker images | wc -l') do |r|
          expect(r.stdout).to match(/^0|1$/)
        end
        # Check to make sure no running containers are present
        shell('docker ps | wc -l') do |r|
          expect(r.stdout).to match(/^0|1$/)
        end
      end
    end

    describe 'docker class' do
      context 'without docker_ee parameters' do
        docker_ee_source_location  = ENV['docker_ee_source_location']
        docker_ee_key_source  = ENV['docker_ee_key_source']
        docker_ee_key_id  = ENV['docker_ee_key_id']
        ucp_hostname = shell ('hostname')
        puts "#{ucp_hostname}"
        case fact('osfamily')
          when 'Debian'
            pp=<<-EOS
              class { 'docker':
                docker_ee => true,
                docker_ee_source_location => '#{docker_ee_source_location}',
                docker_ee_key_source => '#{docker_ee_key_source}',
                docker_ee_key_id => '#{docker_ee_key_id}',
                }
            EOS
          else
            pp=<<-EOS
            class { 'docker':
              docker_ee => true,
              docker_ee_source_location => '#{docker_ee_source_location}',
              docker_ee_key_source => '#{docker_ee_key_source}',
              }
            EOS
        end
        it 'should run successfully' do
          apply_manifest(pp, :catch_failures => true)
        end
        it 'should run idempotently' do
          apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'
        end
        it 'should be start a docker process' do
          shell('ps -aux | grep docker') do |r|
            expect(r.stdout).to match(/dockerd -H unix:\/\/\/var\/run\/docker.sock/)
          end
        end
        it 'should install a working docker client' do
          shell('docker ps', :acceptable_exit_codes => [0])
        end
        it 'should run hello-world' do
          shell('docker run hello-world', :acceptable_exit_codes => [0])
        end
      end
    end

    describe 'docker_ddc class controller parameters' do
      context 'with controller parameters' do
        it 'should install a UCP controller using Docker, with the default admin/orca username and password' do
          pp=<<-EOS
            class { 'docker_ddc':
              controller => true,
              username => tester,
              password => test1234,
            }
          EOS
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'
        end
        it 'should be able to access UCP Control Place' do
          shell("curl -k https://#{vmipaddr}/login/") do |r|
            expect(r.stdout).to match(/Universal Control Plane/)
          end
        end
      end
    end

    describe 'docker_ddc class with parameters' do
      context 'without parameters' do
        it 'should install a UCP controller using Docker, with parameters' do
          pp=<<-EOS
          class { 'docker_ddc':
            controller                => true,
            host_address              => ::ipaddress_eth1,
            version                   => '1.0.0',
            usage                     => false,
            tracking                  => false,
            subject_alternative_names => ::ipaddress_eth1,
            external_ca               => false,
            swarm_scheduler           => 'binpack',
            swarm_port                => 19001,
            controller_port           => 19002,
            preserve_certs            => true,
            docker_socket_path        => '/var/run/docker.sock',
            license_file              => '/etc/docker/subscription.lic',
          }
          EOS
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'
        end
        it 'should be able to access UCP Control Place' do
          shell("curl -k https://#{vmipaddr}/login/") do |r|
            expect(r.stdout).to match(/Universal Control Plane/)
          end
        end
      end
    end

  end

end
