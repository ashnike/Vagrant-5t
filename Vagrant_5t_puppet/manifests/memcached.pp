class memcached {

  # Package management
  package { 'epel-release':
    ensure => present,
  }

  package { 'memcached':
    ensure => present,
  }

  # Configuration file
  file_line { 'bind_address':
    path  => '/etc/sysconfig/memcached',
    line  => 'OPTIONS="-l 0.0.0.0"',  # Set bind address to 0.0.0.0
    match => '^OPTIONS=',
  }

  # Service management
  service { 'memcached':
    ensure  => running,
    enable  => true,
    require => [Package['memcached'], File_line['bind_address']],
  }

  # Firewall configuration
  firewall { '11211':
    port   => 11211,
    proto  => tcp,
    action => accept,
  }

  firewall { '11111':
    port   => 11111,
    proto  => udp,
    action => accept,
  }

}
