# Cookbook:: my_rabbitmq_cookbook
# Recipe:: rabbitmq_setup

# Install and update packages
package 'epel-release' do
  action :install
end

execute 'yum_update' do
  command 'yum update -y'
  action :run
end

package 'wget' do
  action :install
end

# Install RabbitMQ
execute 'install_rabbitmq_repo' do
  command 'dnf -y install centos-release-rabbitmq-38'
  action :run
end

package 'rabbitmq-server' do
  options '--enablerepo=centos-rabbitmq-38'
  action :install
end

# Enable and start RabbitMQ service
service 'rabbitmq-server' do
  action [:enable, :start]
end

# Open port 5672 for RabbitMQ
firewall_rule 'rabbitmq' do
  port     5672
  protocol :tcp
  command  :allow
end

# Make firewall changes permanent
execute 'firewall_permanent' do
  command 'firewall-cmd --runtime-to-permanent'
  action :run
end

# Create RabbitMQ configuration
file '/etc/rabbitmq/rabbitmq.config' do
  content '[{rabbit, [{loopback_users, []}]}].'
  action :create
end

# Add RabbitMQ user
execute 'add_rabbitmq_user' do
  command 'rabbitmqctl add_user test test'
  action :run
  not_if 'rabbitmqctl list_users | grep -q test'
end

# Set RabbitMQ user tags
execute 'set_rabbitmq_user_tags' do
  command 'rabbitmqctl set_user_tags test administrator'
  action :run
end

# Restart RabbitMQ service
service 'rabbitmq-server' do
  action :restart
end

