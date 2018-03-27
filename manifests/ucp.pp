# == Class: docker_ddc:ucp
#
# === Parameters
#
# [*ensure*]
#   Whether to install or uninstall Docker UCP. Defaults to present.
#   Valid values are present or absent.
#
# [*controller*]
#   Whether to install the controller or a normal UCP node.
#   Defaults to false.
#
# [*subject_alternative_names*]
#   An array of additional Subject Alternative Names for certificates.
#
# [*host_address*]
#   Specify the visible IP/hostname for this node (override automatic detection).
#
# [*swarm_port*]
#   Select what port to run the local Swarm manager on.
#
# [*controller_port*]
#   Select what port to run the local Controller on.
#
# [*dns_servers*]
#   Set custom DNS servers for the UCP infrastructure containers.
#
# [*dns_options*]
#   Set DNS options for the UCP infrastructure containers.
#
# [*dns_search_domains*]
#   Set custom DNS search domains for the UCP infrastructure containers.
#
# [*tracking*]
#		Whether or not to allow UCP to collect anonymous tracking and analytics information.
# 	Defaults to true
#
# [*usage*]
#		Whether or not to allow UCP to collect anonymous usage information.
#		Defaults to true
#
# [*version*]
#		Specify a specific UCP version.
#
# [*external_ca*]
#		Set up UCP with an external CA.
#
# [*preserve_certs*]
#   Whether or not to (re)generate certs on the host if existing ones are found.
#   Defaults to false.
#
# [*swarm_scheduler*]
#   Specify a specific Swarm scheduler. Valid values are spead, binpack or random.
#
# [*ucp_url*]
#   The HTTPS URL for the UCP controller, used by nodes to join the cluster.
#   Required for nodes.
#
# [*ucp_manager*]
#   The ip address of the UCP manager.
#   Only required if you are using UCP 2.0 and above
#
# [*ucp_id*]
#   The ID for the UCP. Used when deleting UCP with ensure => absent.
#
# [*token*]
#  This is the authtentication token used for UCP 2.0 and above
#  Required only if you are using UCP version 2.0 or higher
#
# [*replica*]
#   Whether or not this is a replica of the controller. Defaults to false.
#   Only applicable for nodes.
#
# [*username*]
#   A username to authenticate a node with the UCP controller.
#   Required for nodes.
#
# [*password*]
#   The password used to authenticate a node with the UCP controller.
#   Required for nodes.
#
# [*license_file*]
#   A path to a valid Docker UCP license file. You can set this as part of installation
#   or upload via the web interface at a later date.
#
# [*local_client*]
#   Whether or not the Docker client is local or using Swarm. Defaults to false.
#   This is y useful in some testing and bootstrapping scenarios.
#
class docker_ddc::ucp (
  Optional[Pattern[/^present$|^absent$/]] $ensure                   = $docker_ddc::ensure,
  Boolean $controller                                               = $docker_ddc::controller,
  Optional[String] $host_address                                    = $docker_ddc::host_address,
  Optional[Integer] $swarm_port                                     = $docker_ddc::swarm_port,
  Optional[Integer] $controller_port                                = $docker_ddc::controller_port,
  Variant[String,Array,Undef] $dns_servers                          = $docker_ddc::dns_servers,
  Variant[String,Array,Undef] $dns_options                          = $docker_ddc::dns_options,
  Variant[String,Array,Undef] $dns_search_domains                   = $docker_ddc::dns_search_domains,
  Boolean $tracking                                                 = $docker_ddc::tracking,
  Boolean $usage                                                    = $docker_ddc::usage,
  String $version                                                   = $docker_ddc::version,
  Optional[Pattern[/^\/([^\/\0]+\/*)*$/]] $docker_socket_path       = $docker_ddc::docker_socket_path,
  Optional[String] $extra_parameters                                = $docker_ddc::extra_parameters,
  Variant[String,Array,Undef] $subject_alternative_names            = $docker_ddc::subject_alternative_names,
  Boolean $external_ca                                              = $docker_ddc::external_ca,
  Boolean $preserve_certs                                           = $docker_ddc::preserve_certs,
  Optional[Pattern[/^spread$|^binpack$|^random$/]] $swarm_scheduler = $docker_ddc::swarm_scheduler,
  Boolean $preserve_certs_on_delete                                 = $docker_ddc::preserve_certs,
  Boolean $preserve_images_on_delete                                = $docker_ddc::preserve_images_on_delete,
  Optional[String] $ucp_url                                         = $docker_ddc::ucp_url,
  Optional[String] $ucp_manager                                     = $docker_ddc::ucp_manager,
  Optional[String] $ucp_id                                          = $docker_ddc::ucp_id,
  Optional[String] $token                                           = $docker_ddc::token,
  Optional[String] $listen_address                                  = $docker_ddc::listen_address,
  Optional[String] $advertise_address                               = $docker_ddc::advertise_address,
  Boolean $replica                                                  = $docker_ddc::replica,
  String $username                                                  = $docker_ddc::username,
  String $password                                                  = $docker_ddc::password,
  Optional[Pattern[/^\/([^\/\0]+\/*)*$/]] $license_file             = $docker_ddc::license_file,
  Boolean $local_client                                             = $docker_ddc::local_client,
  Optional[String] $ucp_node                                        = $docker_ddc::ucp_node,
  Optional[String] $ucp_username                                    = $docker_ddc::ucp_username,
  Optional[String] $ucp_password                                    = $docker_ddc::ucp_password,
  Boolean $ucp_insecure_tls                                         = $docker_ddc::ucp_insecure_tls,

){

  if $::osfamily {
    assert_type(Pattern[/^(Debian|RedHat)$/], $::osfamily) |$a, $b| {
      fail translate(('This module only works on Debian or Red Hat based systems.'))
    }
  }

  if ($ensure == 'absent') {
    if !$ucp_id {
      fail translate(('When passing ensure => absent you must also provide the UCP id.'))
    }
  } else {
    if !$controller {
      if !$ucp_url {
        fail translate(('When joining UCP you must provide a URL.'))
      }
    }
  }

  Exec {
    path      => ['/usr/bin', '/bin'],
    logoutput => true,
    tries     => 3,
    try_sleep => 5,
    timeout => 600,
  }


  $install_unless = 'docker inspect ucp-controller'
  $join_unless = 'docker inspect ucp-proxy'

  if $ensure == 'absent' {
    $uninstall_flags = ucp_uninstall_flags({
      ucp_id                    => $ucp_id,
      preserve_certs_on_delete  => $preserve_certs_on_delete,
      preserve_images_on_delete => $preserve_images_on_delete,
      extra_parameters          => any2array($extra_parameters),
    })
    exec { 'Uninstall Docker Universal Control Plane':
      command => "docker run --rm -v ${docker_socket_path}:/var/run/docker.sock --name ucp docker/ucp uninstall-ucp ${uninstall_flags}", # lint:ignore:140chars
      onlyif  => $join_unless,
    }
  } else {
    if $controller {
      $install_flags = ucp_install_flags({
        admin_username     => $username,
        admin_password     => $password,
        host_address       => $host_address,
        tracking           => $tracking,
        usage              => $usage,
        swarm_port         => $swarm_port,
        controller_port    => $controller_port,
        preserve_certs     => $preserve_certs,
        external_ca        => $external_ca,
        swarm_scheduler    => $swarm_scheduler,
        dns_servers        => any2array($dns_servers),
        dns_options        => any2array($dns_options),
        dns_search_domains => any2array($dns_search_domains),
        san                => any2array($subject_alternative_names),
        extra_parameters   => any2array($extra_parameters),
      })
      if $license_file {
        exec { 'Install Docker Universal Control Plane':
          command => "docker run --rm -v ${docker_socket_path}:/var/run/docker.sock -v ${license_file}:/docker_subscription.lic --name ucp docker/ucp:${version} install ${install_flags}", # lint:ignore:140chars
          unless  => $install_unless,
        }
      } else {
        exec { 'Install Docker Universal Control Plane':
          command => "docker run --rm -v ${docker_socket_path}:/var/run/docker.sock --name ucp docker/ucp:${version} install ${install_flags}", # lint:ignore:140chars
          unless  => $install_unless,
        }
      }
    } else {
      $join_flags = ucp_join_flags({
        host_address       => $host_address,
        tracking           => $tracking,
        usage              => $usage,
        ucp_url            => $ucp_url,
        replica            => $replica,
        dns_servers        => any2array($dns_servers),
        dns_options        => any2array($dns_options),
        dns_search_domains => any2array($dns_search_domains),
        san                => any2array($subject_alternative_names),
        extra_parameters   => any2array($extra_parameters),
      })

      if $version =~ /^2.*/ {
        exec { 'Join Docker Universal Control Plane v2':
          command => "docker swarm join --listen-addr ${listen_address} --advertise-addr ${advertise_address}:2377  --token ${token} ${ucp_manager}:2377", # lint:ignore:140chars
          unless  => $join_unless,
          }
      }

      else {
          translate('UCP versions below 2.0 are no longer supported')
        }
      }
    }
  }
