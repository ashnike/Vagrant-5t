# Cookbook:: my_memcached_cookbook
# Recipe:: memcached_setup

# Install and enable EPEL repository
package 'epel-release' do
  action :install
end

# Install memcached package
package 'memcached' do
  action :install
end

# Start and enable memcached service
service 'memcached' do
  action [:start, :enable]
end

# Modify memcached configuration to listen on all interfaces
ruby_block 'change_memcached_config' do
  block do
    fe = Chef::Util::FileEdit.new('/etc/sysconfig/memcached')
    fe.search_file_replace(/127.0.0.1/, '0.0.0.0')
    fe.write_file
  end
  only_if { ::File.exist?('/etc/sysconfig/memcached') }
end

# Restart memcached service
service 'memcached' do
  action :restart
end

# Open ports 11211 and 11111 for memcached
firewall_rule 'memcached_tcp' do
  port     11211
  protocol :tcp
  command  :allow
end

firewall_rule 'memcached_udp' do
  port     11111
  protocol :udp
  command  :allow
end

# Make firewall rules permanent
execute 'firewall_permanent' do
  command 'firewall-cmd --runtime-to-permanent'
  action :run
end

# Start memcached with custom parameters
execute 'start_memcached' do
  command 'memcached -p 11211 -U 11111 -u memcached -d'
  not_if 'pgrep memcached'
  action :run
end

