require 'shellwords'

module Puppet::Parser::Functions
  # Transforms a hash into a string of docker swarm init flags
  newfunction(:dtr_join_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []
    flags << "--dtr-external-url '#{opts['dtr_external_url']}'" if opts['dtr_external_url'].to_s != 'undef'
    flags << @version	if opts['dtr_version'].to_s != 'undef'
    flags << "--ucp-node '#{opts['ucp_node']}'" if opts['ucp_node'].to_s != 'undef'
    flags << "--ucp-username '#{opts['ucp_username']}'" if opts['ucp_username'].to_s != 'undef'
    flags << "--ucp-password '#{opts['ucp_password']}'"	if opts['ucp_password'].to_s != 'undef'
    flags << '--ucp-insecure-tls' if opts['ucp_insecure_tls'].to_s != 'false'
    flags << "--ucp-url '#{opts['dtr_ucp_url']}'" if opts['dtr_ucp_url'].to_s != 'undef'
    flags << "--existing-replica-id '#{opts['dtr_existing_replica_id']}'" if opts['dtr_existing_replica_id'].to_s != 'undef'
    flags << "--replica-id '#{opts['replica_id']}'"	if opts['replica_id'].to_s != 'undef'
    flags << "--ucp-ca '#{opts['ucp_ca']}'" if opts['ucp_ca'].to_s != 'undef'
    flags.flatten.join(' ')
  end
end
