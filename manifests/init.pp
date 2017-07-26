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
# [*wildcard_keys*]
# Hash. Wildcard keys to be generated. See opendkim::wildcard_type for
# reference.
# Default: {}
#
# == Requirements
#
# * puppetlabs/concat
# * puppetlabs/stdlib
#
class opendkim (
  $port = 8891,
  $trusted_hosts = [
    '127.0.0.0/8',
    '::1',
  ],
  $wildcard_keys = {},
){

  validate_integer($port, 65535, 1024)
  validate_array($trusted_hosts)
  validate_hash($wildcard_keys)

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

  if !empty($wildcard_keys) {
    create_resources(::opendkim::wildcard_key, $wildcard_keys)
  }

}
