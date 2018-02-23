# = Class: opendkim::service
#
# This class manages the opendkim service
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
class opendkim::service {

  $multi_instance_ports = $opendkim::multi_instance_ports

  if count($multi_instance_ports) > 0 {
    $multi_instance_ports.each |Integer $index, Integer $instance_port| {
      service { "${::opendkim::service_name}@$instance_port":
        ensure => $::opendkim::service_ensure,
        enable => $::opendkim::service_enable,
      }
    }
  } else {
    service {$::opendkim::service_name:
      ensure => $::opendkim::service_ensure,
      enable => $::opendkim::service_enable,
    }
  }

}
