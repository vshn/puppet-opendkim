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

  service {$::opendkim::service_name:
    ensure => $::opendkim::service_ensure,
    enable => $::opendkim::service_enable,
  }

}
