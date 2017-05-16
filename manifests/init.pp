# == Class: docker_ddc
#
# Installs or removes the Docker Universal Control Plane and Docker Trusted Registry using
# the official UCP/DTR installer.
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
# [*fingerprint*]
#   The certificate fingerprint for the UCP controller.
#   Required for nodes.
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
class docker_ddc (
  $ensure = $docker_ddc::params::ensure,
  $controller = $docker_ddc::params::controller,
  $host_address = $docker_ddc::params::host_address,
  $swarm_port = $docker_ddc::params::swarm_port,
  $controller_port = $docker_ddc::params::controller_port,
  $dns_servers = $docker_ddc::params::dns_servers,
  $dns_options = $docker_ddc::params::dns_options,
  $dns_search_domains = $docker_ddc::params::dns_search_domains,
  $tracking = $docker_ddc::params::tracking,
  $usage = $docker_ddc::params::usage,
  $version = $docker_ddc::params::version,
  $docker_socket_path = $docker_ddc::params::docker_socket_path,
  $extra_parameters = $docker_ddc::params::extra_parameters,
  $subject_alternative_names = $docker_ddc::params::subject_alternative_names,
  $external_ca = $docker_ddc::params::external_ca,
  $preserve_certs = $docker_ddc::params::preserve_certs,
  $swarm_scheduler = $docker_ddc::params::swarm_scheduler,
  $preserve_certs_on_delete = $docker_ddc::params::preserve_certs,
  $preserve_images_on_delete = $docker_ddc::params::preserve_images_on_delete,
  $ucp_url = $docker_ddc::params::ucp_url,
  $ucp_manager = $docker_ddc::params::ucp_manager,
  $ucp_id = $docker_ddc::params::ucp_id,
  $fingerprint = $docker_ddc::params::fingerprint,
  $token = $docker_ddc::params::token,
  $listen_address = $docker_ddc::params::listen_address,
  $advertise_address = $docker_ddc::params::advertise_address,
  $replica = $docker_ddc::params::replica,
  $username = $docker_ddc::params::username,
  $password = $docker_ddc::params::password,
  $license_file = $docker_ddc::params::license_file,
  $local_client = $docker_ddc::params::local_client,
  $dtr_external_url = $docker_ddc::params::dtr_external_url,
  $ucp_node = $docker_ddc::params::ucp_node,
  $ucp_username = $docker_ddc::params::ucp_username,
  $ucp_password = $docker_ddc::params::ucp_password,
  $ucp_insecure_tls = $docker_ddc::params::ucp_insecure_tls,

) inherits docker_ddc::params {

  validate_re($::osfamily, '^(Debian|RedHat)$', "${::operatingsystem} not supported. This module only works on Debian and Red Hat based systems.") # lint:ignore:140chars

  validate_re($ensure, '^(present|absent)$')
  validate_bool($tracking, $usage, $preserve_certs, $preserve_certs_on_delete, $preserve_images_on_delete, $controller, $external_ca, $replica) # lint:ignore:140chars
  validate_absolute_path($docker_socket_path)
  validate_string($host_address, $version, $ucp_url, $ucp_id, $fingerprint, $username, $password) # lint:ignore:140chars

  include ::docker_ddc::ucp
  include ::docker_ddc::dtr
  contain ::docker_ddc::ucp
  contain ::docker_ddc::dtr
}
