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
The possibilities of the two configurations are equal. For readability one is called server (the main mailserver) the other satellite (systems, that send all mail to the
mailserver). Configuration option can be inherited from the main class to shorten the hiera configuration.

## Usage

The all available options for classes and defines are documented in the header of the class/define files. See there for any details.

### postfix configuration
To use, include the postfix class. By default this will install the satellite configuration. If you want to use the server configuration
set $postfix::is\_satellite to false.

To set the values for the satellite, use postfix::satellite::XXXX for the server use postfix::server:XXXX. All values are also 
available in the postfix class as postfix::common_XXXX. These will be inherited to postfix::satellite and postfx::server class.

#### To set parameters in main.cf file, use:

    postfix::common_parameters: # or use postfix::satellite::parameters:/postfix::server::parameters
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
  
    postfix::common_parameters:
      bounce_size_limit: 50000
      header_size_limit: 102400
  
#### To set services in master.cf file use:

To add a service in master.cf file use:

    postfix::common_services: # or use postfix::satellite::services or postfix::server::services:
      smtp:
        type: 'inet',
        priv: 'n',
        chroot: 'y',
        command: 'smtpd',
      rewrite:
        chroot: 'y'
        command: 'trivial-rewrite'

#### create lookup maps:

simple lookup maps can be created using:

    postfix::common_maps: # or use postfix::satellite:maps or postfix::server::maps:
      regex_sender_canonical:
        type: 'regex'
        contents:
          - "/^(.*)@%{::fqdn}/      ${1}+%{::hostname}@internaldomain.cirrax.com"
      hash_rewrite_local_sender:
        type: 'hash'
        contents:
          - 'user1          user1@cirrax.com'
          - 'user2          user2@cirrax.com'

To use them use set the parameters in master.cf accordingly.

## Contributing

Please report bugs and feature request using GitHub issue tracker.

For pull requests, it is very much appreciated to check your Puppet manifest with puppet-lint
and the available spec tests  in order to follow the recommended Puppet style guidelines
from the Puppet Labs style guide.


### Authors

This module is mainly written by [Cirrax GmbH](https://cirrax.com).

See the [list of contributors](https://github.com/cirrax/puppet-postfix/graphs/contributors)
for a list of all contributors.
