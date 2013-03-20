name             'encryptfs'
maintainer       'Dyn, Inc'
maintainer_email 'nschelly@dyn.com'
license          'Apache v2.0'
description      'LWRP to manage encrypted one-boot-use filesystems for sensitive information on untrusted hardware or cloud appliances.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'
supports         'ubuntu', '>= 8.04'
supports         'debian', '>= 6.0'
