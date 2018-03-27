[![Puppet
Forge](http://img.shields.io/puppetforge/v/puppetlabs/docker_ucp.svg)](https://forge.puppetlabs.com/puppetlabs/docker_ucp)
[![Build
Status](https://travis-ci.org/puppetlabs/puppetlabs-docker_ucp.svg?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-docker_ucp)

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with docker_ddc](#setup)
3. [Usage - Configuration options and additional functionality](#setup)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

The [Docker Data Center](https://docs.docker.com/datacenter/install/linux/) (DDC)
module helps with setting up a Univeral Control plane (UCP) and Docker Trusted Registry (DTR)
clusters.

## Module Description

This module provides 2 classes, `docker_ddc` and `docker_ddc::dtr`, which uses the
official `docker/ucp` or `docker/dtr` containers to bootstrap a UCP/DTR controller, or join
a node to at existing UCP/DTR.

## Setup

The module assumes Docker is already
installed on the host. If you would like to do that with Puppet look at
the [Docker module](https://forge.puppetlabs.com/garethr/docker).

You can install the module using the Puppet module tool like so:

```
puppet module install puppetlabs/docker_ddc
```

## Usage

The included class has two modes of operation:

### Installing a Controller

```puppet
class { 'docker_ddc':
  controller => true,
}
```

This will install a UCP controller using Docker, with the default
`admin/orca` username and password. Remember to login and change the
password once UCP is up and running.

The class takes a number of parameters, depending on your specific
setup. Consult the UCP documentation for details of this options.

```puppet
class { 'docker_ddc':
  controller                => true,
  host_address              => ::ipaddress_eth1,
  version                   => '2.2.7',
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
```

### Joining a Node to UCP

The default username and password are used, so it's likely that you'll
need to provide those in parameters. The class also takes a number of
other parameters useful for joininng. Again these should map to the
options in the official UCP documetation.

To join to a v2 manager please use the following:

```puppet
class { 'docker_ddc':
  version => '2.2.7',
  token => 'Your join token here',
  listen_address => '192.168.1.2',
  advertise_address => '192.168.1.2',
  ucp_manager => '192.168.1.1',
  ucp_url => 'https://ucp_url'
}
```

# Uninstalling UCP

To uninstall UCP you need to specify the node ucp is running on, please see the following example.

```puppet
class { 'docker_ddc':
  ensure => absent,
  ucp_id => 'ucp_node'
}
```

# Installing a Docker Trusted Registry
To install a [Docker trusted registry](https://docs.docker.com/datacenter/dtr/2.2/guides/) (DTR) on to your UCP cluster, please see the following example.

```puppet 
docker_ddc::dtr {'Dtr install':
  install => true,
  dtr_version => 'latest',
  dtr_external_url => 'https://172.17.10.104',
  ucp_node => 'ucp-04',
  ucp_username => 'admin',
  ucp_password => 'orca4307',
  ucp_insecure_tls => true,
  dtr_ucp_url => 'https://172.17.10.101',
  }
```
In this example we are setting the `install => true` this tells Puppet we want to configure a new registry. We set the `dtr_version`, this can be any version of the registry that is compatible with your UCP cluster. The `dtr_external_url` is the URL you will use to hit the registry, `ucp_node` is the node in the cluster that the registry will run on, user name and password are self explanatory. `ucp_insecure_tls => true` allows the use of self signed SSL certs, this should be set to false in a production environment. `dtr_ucp_url` is the URL that the registry will use to contact the UCP cluster.

## Joining a replica to your Docker Trusted Registry Cluster
To join a replica to your DTR cluster please see the following example.
```puppet
docker_ddc::dtr {'Dtr install':
  join => true,
  dtr_version => 'latest',
  ucp_node => 'ucp-03',
  ucp_username => 'admin',
  ucp_password => 'orca4307',
  ucp_insecure_tls => true,
  dtr_ucp_url => 'https://172.17.10.101',
  }
```

In this example we set mostly the same flags as installing the initial install. The main difference is that we have used the `join` flag not the `install` flag. Please note you can not use `install` and `join` in the same block of Puppet code.

## To remove your Docker Trusted Registry.

To remove the DTR from your UCP cluster see the example below. ensure => absent requires that the  destroy or remove parameter also be set in the manifest. Please note only one of these parameters should be set. 

```puppet
docker_ddc::dtr {'Dtr uninstall':
    ensure => 'absent',
    replica_id => 'the_dtr_replica_id', 
    dtr_version => 'latest',
    dtr_external_url => 'https://172.17.10.104',
    ucp_username => 'admin',
    ucp_password => 'orca4307',
    ucp_insecure_tls => true,
    dtr_ucp_url => 'https://172.17.10.101',
    destroy => true, 
    }
```   
Passing the remove parameter gracefully scales down your DTR cluster by removing exactly one replica. All other replicas must be healthy and will remain healthy after this operation. This command can only be used when two or more replicas are present and all are healthy.

```puppet
remove => true
```

Passing the destroy parameter forcefully removes all containers and volumes associated with a DTR replica without notifying the rest of the cluster.

```puppet
destroy => true
```

## Limitations

This module only supports UCP version 2.0 and above.
UCP only supports RHEL 7.0, 7.1, 7.2, 7.4, Ubuntu 14.04, 16.04 and CentOS 7.1, 7.4


## Maintainers

This module is maintained by: 

The cloud and containers team.
