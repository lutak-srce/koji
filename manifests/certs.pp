# modules/koji/certs.pp - manage koji certificates
#
class koji::certs {
  file {'/etc/pki/koji':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  file {['/etc/pki/koji/certs', '/etc/pki/koji/private', '/etc/pki/koji/confs']:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  file {'/etc/pki/koji/cacert.pem':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0600',
    source => 'puppet:///files/koji/certs/ca.crt',
  }
}
