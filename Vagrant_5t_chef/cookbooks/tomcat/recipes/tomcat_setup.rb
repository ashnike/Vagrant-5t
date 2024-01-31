# Cookbook:: my_tomcat_cookbook
# Recipe:: tomcat_setup

TOMURL = "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz"

# Install Java and required packages
package %w(java-11-openjdk java-11-openjdk-devel git maven wget) do
  action :install
end

# Download and extract Tomcat
remote_file '/tmp/tomcatbin.tar.gz' do
  source TOMURL
  action :create
end

execute 'extract_tomcat' do
  command 'tar xzvf /tmp/tomcatbin.tar.gz -C /tmp/'
  action :run
end

# Set up Tomcat user and directory permissions
user 'tomcat' do
  shell '/sbin/nologin'
end

execute 'move_tomcat' do
  command 'mv /tmp/apache-tomcat-*/* /usr/local/tomcat/'
  action :run
end

execute 'set_permissions' do
  command 'chown -R tomcat:tomcat /usr/local/tomcat'
  action :run
end

# Create and configure systemd service for Tomcat
file '/etc/systemd/system/tomcat.service' do
  content <<-EOT
  [Unit]
  Description=Tomcat
  After=network.target

  [Service]
  User=tomcat
  Group=tomcat
  WorkingDirectory=/usr/local/tomcat
  Environment=JAVA_HOME=/usr/lib/jvm/jre
  Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
  Environment=CATALINA_HOME=/usr/local/tomcat
  Environment=CATALINA_BASE=/usr/local/tomcat
  ExecStart=/usr/local/tomcat/bin/catalina.sh run
  ExecStop=/usr/local/tomcat/bin/shutdown.sh
  RestartSec=10
  Restart=always

  [Install]
  WantedBy=multi-user.target
  EOT
end

# Reload systemd and start Tomcat service
execute 'reload_systemd' do
  command 'systemctl daemon-reload'
  action :run
end

service 'tomcat' do
  action [:start, :enable]
end

# Clone the repository and deploy the application
git '/tmp/vprofile-project' do
  repository 'https://github.com/hkhcoder/vprofile-project.git'
  revision 'main'
  action :sync
end

execute 'build_and_deploy' do
  command 'mvn install && systemctl stop tomcat && sleep 20 && rm -rf /usr/local/tomcat/webapps/ROOT* && cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war && sleep 20 && systemctl stop firewalld && systemctl disable firewalld && systemctl restart tomcat'
  cwd '/tmp/vprofile-project'
  action :run
end

