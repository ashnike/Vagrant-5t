class rabbitmq {

  # Package management
  package { 'epel-release':
    ensure => present,
  }

  exec { 'update_system':
    command => 'yum update -y',
    require => Package['epel-release'],
  }

  package { 'wget':
    ensure => present,
  }

  # RabbitMQ repository and package
  exec { 'install_rabbitmq_repo':
    command => 'dnf -y install centos-release-rabbitmq-38',
    cwd     => '/tmp',
    require => Package['wget'],
  }

  package { 'rabbitmq-server':
    ensure   => present,
    provider => 'dnf',
    source   => 'centos-rabbitmq-38',
    require  => Exec['install_rabbitmq_repo'],
  }

  # Firewall configuration
  firewall { '5672':
    port   => 5672,
    proto  => tcp,
    action => accept,
  }

  # Service management
  service { 'rabbitmq-server':
    ensure  => running,
    enable  => true,
    require => Package['rabbitmq-server'],
  }

  # Configuration file
  file { '/etc/rabbitmq/rabbitmq.config':
    ensure  => file,
    content => '[{rabbit, [{loopback_users, []}]}].',
    require => Package['rabbitmq-server'],
  }

  # User creation
  exec { 'create_rabbitmq_user':
    command => 'rabbitmqctl add_user test test',
    require => Service['rabbitmq-server'],
  }

  exec { 'set_user_tags':
    command => 'rabbitmqctl set_user_tags test administrator',
    require => Exec['create_rabbitmq_user'],
  }

  # Restart after configuration changes
  exec { 'restart_rabbitmq':
    command     => 'systemctl restart rabbitmq-server',
    refreshonly => true,
    subscribe   => [File['/etc/rabbitmq/rabbitmq.config'], Exec['set_user_tags']],
  }

}
