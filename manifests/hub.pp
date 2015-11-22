# modules/koji/hub.pp - manage koji hub
#
class koji::hub {
  package {'koji-hub':
    ensure => present,
  }
  file {'/etc/httpd/conf.d/kojihub.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('koji/httpd-kojihub.conf.erb'),
    notify  => Service['httpd'],
    require => [ Package['koji-hub'], Package['httpd'] ],
  }
  file {'/etc/koji-hub/hub.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('koji/hub.conf.erb'),
    require => Package['koji-hub'],
  }
  file {'/etc/pki/koji/certs/kojihub.crt':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///files/koji/certs/kojihub.crt',
    require => File['/etc/pki/koji'],
  }
  file {'/etc/pki/koji/certs/kojihub.key':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0600',
    source  => 'puppet:///files/koji/certs/kojihub.key',
    require => File['/etc/pki/koji'],
  }

# SSLCertificateFile /etc/pki/koji/certs/kojihub.crt
# SSLCertificateKeyFile /etc/pki/koji/certs/kojihub.key
# SSLCertificateChainFile /etc/pki/koji/ca.crt
# SSLCACertificateFile /etc/pki/koji/ca.crt

}
