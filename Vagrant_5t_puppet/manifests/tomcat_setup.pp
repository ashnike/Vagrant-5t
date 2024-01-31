class tomcat {

  # Packages
  package { ['java-11-openjdk', 'java-11-openjdk-devel', 'git', 'maven', 'wget']:
    ensure => present,
  }

  # User and group
  user { 'tomcat':
    ensure => present,
    shell  => '/sbin/nologin',
  }

  group { 'tomcat':
    ensure => present,
  }

  # Tomcat download and installation
  exec { 'download_tomcat':
    command => "wget ${TOMURL} -O /tmp/tomcatbin.tar.gz",
    creates => '/tmp/tomcatbin.tar.gz',
  }

  exec { 'extract_tomcat':
    command     => 'tar xzvf /tmp/tomcatbin.tar.gz',
    cwd         => '/tmp',
    refreshonly => true,
    subscribe   => Exec['download_tomcat'],
  }

  file { '/usr/local/tomcat':
    ensure => directory,
  }

  exec { 'copy_tomcat':
    command     => "rsync -avzh /tmp/${TOMDIR}/ /usr/local/tomcat/",
    refreshonly => true,
    subscribe   => Exec['extract_tomcat'],
  }

  # Permissions
  file { '/usr/local/tomcat':
    ensure  => directory,
    owner   => 'tomcat',
    group   => 'tomcat',
    recurse => true,
  }

  # Service file
  file { '/etc/systemd/system/tomcat.service':
    ensure  => file,
    content => template('tomcat/tomcat.service.erb'),
  }

  # Service management
  service { 'tomcat':
    ensure  => running,
    enable  => true,
    require => [File['/usr/local/tomcat'], File['/etc/systemd/system/tomcat.service']],
  }

  # Disable firewalld (optional)
  service { 'firewalld':
    ensure => stopped,
    enable => false,
  }

  # Build the application (assume Maven is installed)
  exec { 'build_application':
    command => '/bin/bash -c "cd ../app && mvn install"',
    timeout => 0,
    require => File['../app/pom.xml'],  # Ensure pom.xml is present
  }

  # Copy application files
  file { '/usr/local/tomcat/webapps/ROOT':
    ensure  => directory,
    source  => '../app/src',
    recurse => true,
    owner   => 'tomcat',
    group   => 'tomcat',
    require => Exec['build_application'],  # Ensure application is built first
  }

  file { '/usr/local/tomcat/webapps/ROOT/pom.xml':
    ensure  => file,
    source  => '../app/pom.xml',
    owner   => 'tomcat',
    group   => 'tomcat',
    require => File['/usr/local/tomcat/webapps/ROOT'],
  }

}

