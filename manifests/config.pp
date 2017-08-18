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

  $multiple_signatures = $opendkim::multiple_signatures
  $port = $opendkim::port
  $trusted_hosts = $opendkim::trusted_hosts

  file {$opendkim::config_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('opendkim/opendkim.conf.erb'),
  }

  file {$opendkim::defaults_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "# managed by puppet\nSOCKET=\"inet:${port}@localhost\"\n",
  }

  file {$opendkim::config_dir:
    ensure => directory,
    owner  => $opendkim::user,
    group  => $opendkim::group,
    mode   => '0755',
  }

  file {"${opendkim::config_dir}/keys":
    ensure => directory,
    owner  => $opendkim::user,
    group  => $opendkim::group,
    mode   => '0750',
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
