class nginx {

  # Package management
  package { 'nginx':
    ensure => present,
  }

  # Configuration file
  file { '/etc/nginx/sites-available/webapp':
    ensure  => file,
    content => template('nginx/webapp.conf.erb'),  # Use a template for flexibility
  }

  # Symbolic link
  file { '/etc/nginx/sites-enabled/webapp':
    ensure => link,
    target => '/etc/nginx/sites-available/webapp',
  }

  # Remove default site (optional)
  file { '/etc/nginx/sites-enabled/default':
    ensure => absent,
  }

  # Service management
  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => [Package['nginx'], File['/etc/nginx/sites-enabled/webapp']],
  }

}

