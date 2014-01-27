name             'varnishd'
maintainer       'Eric Buth'
maintainer_email 'eric.buth@nytimes.com'
license          'Apache 2.0'
description      'Builds, installs, and configures Varnish and VMODs.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'

depends 'apt'
depends 'build-essential'
depends 'git'
