node 'db01' {
  include mariadb_setup.pp
}
node 'mc01' {
  include memcached.pp
}
node 'rmq01' {
  include rabbitmq_setup.pp
}
node 'app01' {
  include tomcat_setup.pp
}
node 'web01' {
  include nginx_setup.pp
}
