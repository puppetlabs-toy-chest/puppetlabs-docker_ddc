module Puppet::Parser::Functions
  newfunction(:ucp_join_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []
    flags << "--host-address '#{opts['host_address']}'" if opts['host_address'] && opts['host_address'].to_s != 'undef'
    flags << '--disable-tracking' unless opts['tracking']
    flags << '--disable-usage' unless opts['usage']
    flags << '--replica' if opts['replica'] == true
    flags << "--image-version '#{opts['version']}'" if opts['version'] && opts['version'].to_s != 'undef'
    flags << "--fingerprint '#{opts['fingerprint']}'" if opts['fingerprint'] && opts['fingerprint'].to_s != 'undef'
    flags << "--url '#{opts['ucp_url']}'" if opts['ucp_url'] && opts['ucp_url'].to_s != 'undef'

    multi_flags = lambda do |values, format|
      filtered = [values].flatten.compact
      filtered.map { |val| sprintf(format, val) }
    end

    [
      ["--dns '%s'",        'dns_servers'],
      ["--dns-search '%s'", 'dns_search_domains'],
      ["--dns-option '%s'", 'dns_options'],
      ["--san '%s'",        'san'],
    ].each do |(format, key)|
      values    = opts[key]
      new_flags = multi_flags.call(values, format)
      flags.concat(new_flags)
    end

    opts['extra_parameters'].each do |param|
      flags << param
    end

    flags.flatten.join(' ')
  end
end
