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
  $keys = {},
  $multiple_signatures = false,
  $port = 8891,
  $trusted_hosts = [
    '127.0.0.0/8',
    '::1',
  ],
){

  validate_hash($keys)
  validate_bool($multiple_signatures)
  validate_integer($port, 65535, 1024)
  validate_array($trusted_hosts)

  case downcase($::osfamily) {
    'debian': {
      case downcase($::lsbdistcodename) {
        'xenial': {
          $config_dir = '/etc/opendkim'
          $config_file = '/etc/opendkim.conf'
          $defaults_file = '/etc/default/opendkim'
          $group = 'opendkim'
          $packages = [
            'opendkim',
            'opendkim-tools',
          ]
          $service_enable = true
          $service_ensure = 'running'
          $service_name = 'opendkim'
          $user = 'opendkim'
        }
        default: {
          fail("unsupported distribution ${::lsbdistcodename}")
        }
      }
    }
    default: {
      fail("unsupported platfrom ${::osfamily}")
    }
  }

  class {'opendkim::install':
  } ->
  class {'opendkim::config':
  } ~>
  class {'opendkim::service':
  }

  if !empty($keys) {
    create_resources(::opendkim::key, $keys)
  }

}
