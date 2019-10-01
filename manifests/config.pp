# = Class: opendkim::config
#
# This class manages the opendkim configuration
#
# == Authors
#
# Andre Keller <andre.keller@vshn.ch>
#
# == License
#
# Copyright 2017 VSHN AG under the terms of the BSD 3-clause license
# https://opensource.org/licenses/BSD-3-Clause
#
class opendkim::config {

  $multi_instance_ports = $opendkim::multi_instance_ports
  $multiple_signatures = $opendkim::multiple_signatures
  $port = $opendkim::port
  $trusted_hosts = $opendkim::trusted_hosts

  $_nofports = count($multi_instance_ports)
  if $_nofports > 0 {
    $multi_instance = true
    # Create Multi-instance systemd resource
    include systemd
    systemd::resources::unit { 'opendkim':
      ensure                => 'present',
      type                  => 'forking',
      multi_instance        => true,
      after                 => 'network.target nss-lookup.target',
      description           => 'DomainKeys Indentified Mail (DKIM) Milter',
      documentation         => 'man:opendkim(8) man:opendkim.conf(5) man:opendkim-genkey(8) man:opendkim-genzone(8) man:opendkim-testadsp(8) man:opendkim-testkey http://www.opendkim.org/docs.html',
      environment_file      => "-${opendkim::defaults_file}-%I",
      permissions_startonly => true,
      user                  => 'opendkim',
      group                 => 'opendkim',
      execstart             => '/usr/sbin/opendkim -x /etc/opendkim.conf -u opendkim -p $SOCKET $DAEMON_OPTS',
      timeoutstartsec       => 10,
      execreload            => '/bin/kill -USR1 $MAINPID',
    }
    # Stop the "main" service, we have individual ones
    # TODO: Replace the main service with one that handles all the individual ones
    service { "${::opendkim::service_name}":
      ensure => 'stopped',
      enable => false,
    }
    $multi_instance_ports.each |Integer $index, Integer $instance_port| {
      # Sanity check
      if $instance_port == $port {
        fail("Instance port may not be equal to default port ($instance_port)")
      }
      # Create defaults file
      file { "${opendkim::defaults_file}-${instance_port}":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "# managed by puppet\nSOCKET=\"inet:${instance_port}@localhost\"\n",
      }
      # Add firewall rules for round-robin
      firewall { "100 reroute OpenDKIM instance $index traffic":
        table       => 'nat',
        chain       => 'OUTPUT',
        outiface    => 'lo',
        proto       => 'tcp',
        dport       => $port,
        ctstate     => 'NEW',
        stat_mode   => 'nth',
        stat_every  => "$_nofports",  # Needs to be a string. Don't ask me why...
        stat_packet => $index,
        jump        => 'DNAT',
        todest      => "127.0.0.1:${instance_port}",
      }
    }
  } else {
    $multi_instance = false
    # Not a multi-instance; just use normal port
    if $opendkim::defaults_file {
      file { "$opendkim::defaults_file":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "# managed by puppet\nSOCKET=\"inet:${port}@localhost\"\n",
      }
    }
  }

  file {$opendkim::config_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('opendkim/opendkim.conf.erb'),
  }

  file {$opendkim::config_dir:
    ensure => directory,
    owner  => $opendkim::user,
    group  => $opendkim::group,
    mode   => '0755',
  }

  file {"${opendkim::config_dir}/keys":
    ensure  => directory,
    owner   => $opendkim::user,
    group   => $opendkim::group,
    mode    => '0750',
    force   => $opendkim::purge_unmanaged_keys,
    purge   => $opendkim::purge_unmanaged_keys,
    recurse => $opendkim::purge_unmanaged_keys,
  }

  file {"${opendkim::config_dir}/TrustedHosts":
    ensure  => file,
    owner   => $opendkim::user,
    group   => $opendkim::group,
    mode    => '0750',
    content => template('opendkim/TrustedHosts.erb'),
  }

  concat {"${opendkim::config_dir}/KeyTable":
    owner   => $opendkim::user,
    group   => $opendkim::group,
    mode    => '0750',
    require => File[$opendkim::config_dir],
  }
  concat::fragment{'opendkim-keytable-header':
    content => "# managed by puppet\n",
    order   => '00_',
    target  => "${opendkim::config_dir}/KeyTable",
  }

  concat {"${opendkim::config_dir}/SigningTable":
    owner   => $opendkim::user,
    group   => $opendkim::group,
    mode    => '0750',
    require => File[$opendkim::config_dir],
  }
  concat::fragment{'opendkim-signingtable-header':
    content => "# managed by puppet\n",
    order   => '00_',
    target  => "${opendkim::config_dir}/SigningTable",
  }

}
