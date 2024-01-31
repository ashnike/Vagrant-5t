# manifests/mariadb_setup.pp

class mariadb::install {
  package { 'epel-release':
    ensure => installed,
  }

  package { 'git':
    ensure => installed,
  }

  package { 'zip':
    ensure => installed,
  }

  package { 'unzip':
    ensure => installed,
  }

  package { 'mariadb-server':
    ensure => installed,
  }
}

class mariadb::configure {
  exec { 'start_mariadb':
    command     => 'systemctl start mariadb',
    path        => '/usr/bin',
    refreshonly => true,
  }

  exec { 'enable_mariadb':
    command     => 'systemctl enable mariadb',
    path        => '/usr/bin',
    refreshonly => true,
  }

  exec { 'set_database_password':
    command => 'mysqladmin -u root password "admin123"',
    path    => '/usr/bin',
    onlyif  => 'mysql -u root -e "show databases" | grep -q information_schema',
    require => Exec['start_mariadb'],
  }

  exec { 'mysql_secure_installation':
    command => 'mysql_secure_installation',
    path    => '/usr/bin',
    require => Exec['set_database_password'],
  }

  exec { 'create_database_and_user':
    command => 'mysql -u root -padmin123 -e "CREATE DATABASE accounts; GRANT ALL PRIVILEGES ON accounts.* TO ''admin''@''localhost'' IDENTIFIED BY ''admin123''; GRANT ALL PRIVILEGES ON accounts.* TO ''admin''@''%'' IDENTIFIED BY ''admin123'';"',
    path    => '/usr/bin',
    require => Exec['mysql_secure_installation'],
  }

  exec { 'restore_database_backup':
    command => 'mysql -u root -padmin123 accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql',
    path    => '/usr/bin',
    require => Exec['create_database_and_user'],
  }

  exec { 'flush_privileges':
    command => 'mysql -u root -padmin123 -e "FLUSH PRIVILEGES"',
    path    => '/usr/bin',
    require => Exec['restore_database_backup'],
  }

  exec { 'restart_mariadb':
    command     => 'systemctl restart mariadb',
    path        => '/usr/bin',
    refreshonly => true,
  }
}

class mariadb::firewall {
  exec { 'start_firewalld':
    command     => 'systemctl start firewalld',
    path        => '/usr/bin',
    refreshonly => true,
  }

  exec { 'enable_firewalld':
    command     => 'systemctl enable firewalld',
    path        => '/usr/bin',
    refreshonly => true,
  }

  exec { 'add_firewall_rule':
    command => 'firewall-cmd --zone=public --add-port=3306/tcp --permanent && firewall-cmd --reload',
    path    => '/usr/bin',
    require => Exec['enable_firewalld'],
  }
}

# Include the classes
class { 'mariadb::install': }
class { 'mariadb::configure': }
class { 'mariadb::firewall': }

