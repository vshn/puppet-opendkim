# OpenDKIM

This puppet module provides support to install and configure the
OpenDKIM milter.

DomainKeys Identified Mail (DKIM) lets an organization take responsibility
for a message that is in transit. The organization is a handler of the
message, either as its originator or as an intermediary. Their reputation
is the basis for evaluating whether to trust the message for further
handling, such as delivery. Technically DKIM provides a method for
validating a domain name identity that is associated with a message through
cryptographic authentication.

## Dependencies

 * puppetlabs/concat
 * puppetlabs/stdlib

## OS Support

 * Ubuntu 16.04 (Xenial Xerus)

## Parameters

See inline documentation in opendkim class.

## Example

The following will configure OpenDKIM to listen on localhost:8891, sign mails received from 203.0.113.0/24
with a automatically generated wildcard key.

```yaml
classes:
 - opendkim

opendkim::trusted_hosts:
 - '203.0.113.0/24'

opendkim::wildcard_keys:
 '%{::fqdn}':
   selector: 'default'
```

The generated key to be put into DNS can be found in `/etc/opendkim/keys/$(hostname -f)/default.txt`.

In order to enable the milter in postfix set the following parameters in main.cf:

```ini
smtpd_milters = inet:127.0.0.1:8891
non_smtpd_milters = inet:127.0.0.1:8891
milter_default_action = accept
milter_protocol = 2
```

## Known Limitations

The module currently supports only wildcard keys, i.e. a single key to sign
all mails passed to the milter.
