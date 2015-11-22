# modules/koji/pgsql.pp - manage koji
#
class koji::pgsql {
  package {'postgresql-server':
    ensure  => latest,
  }
  exec {'pginitdb':
    command => 'service postgresql initdb',
    unless  => 'test -f /var/lib/pgsql/data/PG_VERSION || service postgresql status | grep stopped > /dev/null',
    require => Package['postgresql-server'],
  }
  file {'/etc/postgresql':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    require => Exec['pginitdb'],
  }
  file {'/etc/postgresql/pg_hba.conf':
    ensure  => present,
    owner   => postgres,
    group   => postgres,
    mode    => '0600',
    content => template('koji/pg_hba.conf.erb'),
    notify  => Service['postgresql'],
    require => File['/etc/postgresql'],
  }
  file {'/etc/postgresql/postgresql.conf':
    ensure  => present,
    owner   => postgres,
    group   => postgres,
    mode    => '0600',
    content => template('koji/postgresql.conf.erb'),
    notify  => Service['postgresql'],
    require => File['/etc/postgresql'],
  }
  file {'/etc/postgresql/pg_ident.conf':
    ensure  => present,
    owner   => postgres,
    group   => postgres,
    mode    => '0600',
    content => template('koji/pg_ident.conf.erb'),
    notify  => Service['postgresql'],
    require => File['/etc/postgresql'],
  }
  file {'/var/lib/pgsql/data/pg_hba.conf':
    ensure  => link,
    target  => '/etc/postgresql/pg_hba.conf',
    require => File['/etc/postgresql/pg_hba.conf'],
  }
  file {'/var/lib/pgsql/data/postgresql.conf':
    ensure  => link,
    target  => '/etc/postgresql/postgresql.conf',
    require => File['/etc/postgresql/postgresql.conf'],
  }
  file {'/var/lib/pgsql/data/pg_ident.conf':
    ensure  => link,
    target  => '/etc/postgresql/pg_ident.conf',
    require => File['/etc/postgresql/pg_ident.conf'],
  }
  service {'postgresql':
    ensure   => 'running',
    enable   => true,
    provider => 'redhat',
    require  => [Package['postgresql-server'], Exec['pginitdb'], File['/var/lib/pgsql/data/pg_hba.conf'], File['/var/lib/pgsql/data/postgresql.conf'], File['/var/lib/pgsql/data/pg_ident.conf'] ],
  }
  exec {'createpguserkoji':
    user    => 'postgres',
    group   => 'postgres',
    command => 'createuser --no-superuser --no-createdb --no-createrole koji',
    unless  => 'psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname=\'koji\'" > /dev/null',
    require => Service['postgresql'],
  }
  exec {'createpguserapache':
    user    => 'postgres',
    group   => 'postgres',
    command => 'createuser --no-superuser --no-createdb --no-createrole apache',
    unless  => 'psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname=\'apache\'" > /dev/null',
    require => Service['postgresql'],
  }
  exec {'createpgdbkoji':
    user    => 'postgres',
    group   => 'postgres',
    command => 'createdb -O koji koji',
    unless  => 'psql -l | grep koji > /dev/null',
    require => [ Exec['createpguserkoji'], Exec['createpguserapache'] ],
  }
  exec {'createpgdbkojifill':
    user    => 'postgres',
    group   => 'postgres',
    command => 'psql koji koji < /usr/share/doc/koji-1.7.0/docs/schema.sql',
    unless  => 'psql koji -c "select * from repo limit 2;" > /dev/null',
    require => Exec['createpgdbkoji'],
  }
  # psql koji koji -c "insert into users (name, status, usertype) values ('kojiadmin', 0,0);"
  # psql koji koji -c "insert into user_perms (user_id, perm_id, creator_id) values (1,1,1);"
}
