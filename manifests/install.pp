# = Class: opendkim::install
#
# This class manages the opendkim packages
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
class opendkim::install {

  package {$::opendkim::packages:
    ensure => 'installed',
  }

}
