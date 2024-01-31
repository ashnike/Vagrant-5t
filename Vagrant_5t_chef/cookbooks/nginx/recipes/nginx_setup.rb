# Cookbook:: my_nginx_cookbook
# Recipe:: nginx_setup

# Update package repositories
execute 'apt_update' do
  command 'apt update'
  action :run
end

# Install nginx package
package 'nginx' do
  action :install
end

# Create nginx configuration file
file '/etc/nginx/sites-available/vproapp' do
  content <<-EOH
  upstream vproapp {
    server app01:8080;
  }

  server {
    listen 80;
    location / {
      proxy_pass http://vproapp;
    }
  }
  EOH
end

# Enable vproapp site
link '/etc/nginx/sites-enabled/vproapp' do
  to '/etc/nginx/sites-available/vproapp'
  link_type :symbolic
  action :create
end

# Remove the default site if it exists
file '/etc/nginx/sites-enabled/default' do
  action :delete
  only_if { ::File.exist?('/etc/nginx/sites-enabled/default') }
end

# Restart nginx service
service 'nginx' do
  action [:enable, :start, :restart]
end

