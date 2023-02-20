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
 * Ubuntu 18.04 (Bionic Beaver)
 * Ubuntu 20.04 (Focal Fossa)
 * Ubuntu 22.04 (Jammy Jellyfish)

## Parameters

See inline documentation in opendkim class.

## Example

The following will configure OpenDKIM to listen on localhost:8891, and to sign
mails received from 203.0.113.0/24.

Mails from the sender domains example.net / example.org will be signed using
the example key, mails from other sender domains will be signed using the
default key.

```yaml
classes:
 - opendkim

opendkim::trusted_hosts:
 - '203.0.113.0/24'

opendkim::keys:
 'example':
   domains: 
     - 'example.net'
     - 'example.org'
   priority: 20
   selector: 'special'
 'default':
   priority: 50
   selector: 'default'
```

The generated key to be put into DNS can be found in
`/etc/opendkim/keys/keyname/selector.txt`.

You can create multiple-instances of the Daemon that will run on separate
ports by using an array of integers for `opendkim::multi_instance_ports`.
This will automatically create iptables-rules for round-robin accessing
them on the default port.

Note that switching back to a single instance (or, indeed, to different
ports) will not remove these services. To do so manually disable the services
(called opendkim@_port_) and remove the files at `/etc/default/opendkim-$port`.

In order to enable the milter in postfix set the following parameters in
postfix' main.cf:

```ini
smtpd_milters = inet:127.0.0.1:8891
non_smtpd_milters = inet:127.0.0.1:8891
milter_default_action = accept
milter_protocol = 2
```
