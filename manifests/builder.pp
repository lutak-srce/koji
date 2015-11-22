# modules/koji/builder.pp - manage koji builder
#
class koji::builder {
  package {'koji-builder':
    ensure  => present,
  }
  file {'/etc/kojid/kojid.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('koji/kojid.conf.erb'),
    require => Package['koji-builder'],
  }
  package {'mock':
    ensure  => present,
  }
  package {'rpm-build':
    ensure  => present,
  }
}
