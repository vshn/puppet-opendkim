# = Class: opendkim
#
# This module will install and configure the OpenDKIM milter.
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
# == Parameters
#
# [*keys*]
# Hash. Keys to be generated. See opendkim::key type for reference.
# Default: {}
#
# [*multi_instance_ports*]
# Array of Integers. Define to generate several instances of OpenDKIM
# that will be used in a round-robin fashion via iptables.
# Default: []
#
# [*multiple_signatures*]
# Boolean. If set to true, message will be signed with every matched key.
# The default behaviour will sign the message with the key that matches first.
# Default: false
#
# [*port*]
# Integer. Port the milter listens on. The socket is unconditionally opened
# on 127.0.0.1 (ipv4 only).
# Default: 8891
#
# [*purge_unmanaged_keys*]
# Boolean. If set to true, key files not managed by puppet will be removed.
# Default: true
#
# [*trusted_hosts*]
# Array. List of client IP ranges, opendkim will sign mails from. If the
# originating client is not listed here, opendkim will not sign mails.
# Default: ['127.0.0.0/8', '::1']
#
# == Requirements
#
# * puppetlabs/concat
# * puppetlabs/stdlib
#
class opendkim (
  Hash $keys = {},
  Array[Integer] $multi_instance_ports = [],
  Boolean $multiple_signatures = false,
  Integer[1024, 65535] $port = 8891,
  Boolean $purge_unmanaged_keys = true,
  Array $trusted_hosts = [
    '127.0.0.0/8',
    '::1',
  ],
){

  case downcase($::osfamily) {
    'debian': {
      $config_dir = '/etc/opendkim'
      $config_file = '/etc/opendkim.conf'
      $group = 'opendkim'
      $packages = [
        'opendkim',
        'opendkim-tools',
      ]
      $service_enable = true
      $service_ensure = 'running'
      $service_name = 'opendkim'
      $user = 'opendkim'
      $_supported_releases = ['bionic', 'focal', 'jammy', 'noble']
      unless downcase($::lsbdistcodename) in $_supported_releases {
          fail("unsupported distribution ${::lsbdistcodename}")
        }
      }
    default: {
      fail("unsupported platfrom ${::osfamily}")
    }
  }

  class {'opendkim::install':
  }
  -> class {'opendkim::config':
  }
  ~> class {'opendkim::service':
  }

  if !empty($keys) {
    create_resources(::opendkim::key, $keys)
  }

}
