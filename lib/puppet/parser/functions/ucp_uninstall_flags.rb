module Puppet::Parser::Functions
  newfunction(:ucp_uninstall_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []
    flags << '--preserve-certs' if opts['preserve_certs_on_delete']
    flags << '--preserve-images' if opts['preserve_images_on_delete']
    flags << "--id '#{opts['ucp_id']}'" if opts['ucp_id'] && opts['ucp_id'].to_s != 'undef'
    opts['extra_parameters'].each do |param|
      flags << param
    end
    flags.flatten.join('')
  end
end
