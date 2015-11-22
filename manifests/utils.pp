# modules/koji/utils.pp - manage koji
#
class koji::utils {
  package {'koji-utils':
    ensure  => present,
  }
  file {'/etc/kojira/kojira.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('koji/kojira.conf.erb'),
    require => Package['koji-utils'],
  }
  file {'/etc/pki/koji/certs/kojira.pem':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0600',
    source  => 'puppet:///files/koji/certs/kojira.pem',
    require => File['/etc/pki/koji'],
  }
  service { 'kojira':
    ensure     => running,
    enable     => true,
    require    => [ File['/etc/pki/koji/certs/kojira.pem'], File['/etc/kojira/kojira.conf'] ],
  }

}
