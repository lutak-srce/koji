# modules/koji/web.pp - manage koji
#
class koji::web {
  package {'koji-web':
    ensure  => present,
  }
  file {'/etc/httpd/conf.d/kojiweb.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('koji/httpd-kojiweb.conf.erb'),
    require => Package['koji-web'],
  }
  file {'/etc/kojiweb/web.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('koji/web.conf.erb'),
    require => Package['koji-web'],
  }
  file {'/etc/pki/koji/certs/kojiweb.crt':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0600',
    source  => 'puppet:///files/koji/certs/kojiweb.crt',
    require => File['/etc/pki/koji'],
  }
}
