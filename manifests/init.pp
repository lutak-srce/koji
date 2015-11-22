# files/koji/init.pp - manage koji
#
class koji {
  package {'koji':
    ensure  => present,
  }
  file {'/etc/koji.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('koji/koji.conf.erb'),
    require => Package['koji'],
  }

  # working directories
  file {'/data':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
  }
  file {'/data/koji':
    ensure  => directory,
    owner   => apache,
    group   => apache,
    mode    => '0755',
    require => File['/data'],
  }
  file {[ '/data/koji/packages', '/data/koji/repos', '/data/koji/work', '/data/koji/scratch' ]:
    ensure  => directory,
    owner   => apache,
    group   => apache,
    mode    => '0755',
    require => File['/data/koji'],
  }

  user {'koji':
    ensure     => present,
    password   => '',
    comment    => 'Koji DB access user',
    managehome => true,
  }
  # kojiadmin user
  # group {'kojiadmin':
  #   ensure => present,
  #   system => false,
  # }
  user {'kojiadmin':
    ensure  => present,
  }
  file {['/home/kojiadmin', '/home/kojiadmin/.koji']:
    ensure  => directory,
    owner   => kojiadmin,
    group   => kojiadmin,
    mode    => '0755',
    require => User['kojiadmin'],
  }
  # decrypt p12 with commands:
  # cd /etc/puppet/files/koji/files/certs
  # openssl pkcs12 -in kojiadmin-koji.srce.hr.p12 -out kojiadmin.pem -nodes -clcerts
  file {'/home/kojiadmin/.koji/client.crt':
    ensure  => present,
    owner   => kojiadmin,
    group   => kojiadmin,
    mode    => '0640',
    source  => 'puppet:///files/koji/certs/kojiadmin.pem',
    require => File['/home/kojiadmin/.koji'],
  }
  file {'/home/kojiadmin/.koji/serverca.crt':
    ensure  => present,
    owner   => kojiadmin,
    group   => kojiadmin,
    mode    => '0640',
    source  => 'puppet:///files/koji/certs/ca.crt',
    require => File['/home/kojiadmin/.koji'],
  }
  file {'/home/kojiadmin/.koji/clientca.crt':
    ensure  => present,
    owner   => kojiadmin,
    group   => kojiadmin,
    mode    => '0640',
    source  => 'puppet:///files/koji/certs/ca.crt',
    require => File['/home/kojiadmin/.koji'],
  }
}
