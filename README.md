# postfix puppet module

[![Build Status](https://travis-ci.org/cirrax/puppet-postfix.svg?branch=master)](https://travis-ci.org/cirrax/puppet-postfix)
[![Puppet Forge](https://img.shields.io/puppetforge/v/cirrax/postfix.svg?style=flat-square)](https://forge.puppetlabs.com/cirrax/postfix)
[![Puppet Forge](https://img.shields.io/puppetforge/dt/cirrax/postfix.svg?style=flat-square)](https://forge.puppet.com/cirrax/postfix)
[![Puppet Forge](https://img.shields.io/puppetforge/e/cirrax/postfix.svg?style=flat-square)](https://forge.puppet.com/cirrax/postfix)
[![Puppet Forge](https://img.shields.io/puppetforge/f/cirrax/postfix.svg?style=flat-square)](https://forge.puppet.com/cirrax/postfix)

#### Table of Contents

1. [Overview](#overview)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Contributing](#contributing)


## Overview

The purpose of this module is to configure postfix. It allows you to specify two postfix configurations in hiera. 

Version 2.x.x and above does not use two separated classes for server and satellige like it was done in 1.x.x versions. Instead hiera is used to overwrite configs.
Version 2.x.x and above does not merge parameters in code anymore, instead hiera merge is used.

## Usage

The all available options for classes and defines are documented in the header of the class/define files. See there for any details.

### postfix configuration
To use, include the postfix class.

#### To set parameters in main.cf file, use hiera:

    postfix::parameters: 
        bounce_size_limit:
          comments:
            - 'The maximal amount of original message text that is sent in a'
            - 'non-delivery notification'
          value: 50000
        header_size_limit:
          comments:
            - 'The maximal amount of memory in bytes for storing a message header.'
            - 'If a header is larger, the excess is discarded'
          value: 102400
      
if you do not like to have a comment you can also set:
  
    postfix::parameters:
      bounce_size_limit: 50000
      header_size_limit: 102400

Do deactivate a parameter that has been set by default, use:

    postfix::parameters:
      mydestination:
        deactivate: true

Pervices are hash merged in hiera.

#### To set services in master.cf file use:

To add a service in master.cf file use:

    postfix::services:
      smtp:
        type: 'inet'
        priv: 'n'
        chroot: 'y'
        command: 'smtpd'
      rewrite:
        chroot: 'y'
        command: 'trivial-rewrite'

Services are hash merged in hiera and can be deacitvated and removed from hiera.

#### create lookup maps:

Simple lookup maps can be created using:

    postfix::maps:
      regex_sender_canonical:
        type: 'regex'
        contents:
          - "/^(.*)@%{::fqdn}/      ${1}+%{::hostname}@internaldomain.cirrax.com"
      hash_rewrite_local_sender:
        type: 'hash'
        contents:
          - 'user1          user1@cirrax.com'
          - 'user2          user2@cirrax.com'

Maps are hash merged in hiera.

To use them use set the parameters in master.cf accordingly.

### support for postfix profiles
Instead of creating the postfix configuration with the parameters postfix::parameters, postfix::services and postfix::maps
you can define several profiles and use postfix::use\_profile to choose an appropriate profile for the configuration.
The chosen profile is then merged with original parameters to generate the configuration.

Purpose of profiles is to have distinct postfix functions such as a full mailserver or just a satellite system that does not receive mail but 
relay everything to a main server. Or you need to distinct postfix configuration by datacenter or ....

## Contributing

Please report bugs and feature request using GitHub issue tracker.

For pull requests, it is very much appreciated to check your Puppet manifest with puppet-lint
and the available spec tests  in order to follow the recommended Puppet style guidelines
from the Puppet Labs style guide.

### Authors

This module is mainly written by [Cirrax GmbH](https://cirrax.com).

See the [list of contributors](https://github.com/cirrax/puppet-postfix/graphs/contributors)
for a list of all contributors.
