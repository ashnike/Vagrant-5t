# Cookbook:: my_mariadb_cookbook
# Recipe:: mariadb_setup

# Define the database password
DATABASE_PASS = 'admin123'

# Update the package repositories
execute 'yum_update' do
  command 'yum update -y'
  action :run
end

# Install required packages
package %w(epel-release git zip unzip mariadb-server) do
  action :install
end

# Start and enable mariadb-server
service 'mariadb' do
  action [:start, :enable]
end

# Clone the repository
git '/tmp/vprofile-project' do
  repository 'https://github.com/hkhcoder/vprofile-project.git'
  revision 'main'
  action :sync
end

# Configure mariadb
execute 'configure_mariadb' do
  command <<-EOH
    mysqladmin -u root password "#{DATABASE_PASS}"
    mysql -u root -p#{DATABASE_PASS} -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
    mysql -u root -p#{DATABASE_PASS} -e "DELETE FROM mysql.user WHERE User=''"
    mysql -u root -p#{DATABASE_PASS} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
    mysql -u root -p#{DATABASE_PASS} -e "FLUSH PRIVILEGES"
    mysql -u root -p#{DATABASE_PASS} -e "create database accounts"
    mysql -u root -p#{DATABASE_PASS} -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by '#{DATABASE_PASS}'"
    mysql -u root -p#{DATABASE_PASS} -e "grant all privileges on accounts.* TO 'admin'@'%' identified by '#{DATABASE_PASS}'"
    mysql -u root -p#{DATABASE_PASS} accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
    mysql -u root -p#{DATABASE_PASS} -e "FLUSH PRIVILEGES"
  EOH
  action :run
  only_if { ::File.exist?('/tmp/vprofile-project/src/main/resources/db_backup.sql') }
end

# Restart mariadb-server
service 'mariadb' do
  action :restart
end

# Configure firewall to allow access to port 3306
execute 'firewall_configure' do
  command <<-EOH
    firewall-cmd --get-active-zones
    firewall-cmd --zone=public --add-port=3306/tcp --permanent
    firewall-cmd --reload
  EOH
  action :run
end

