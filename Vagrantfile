Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vb|
  end
  #Nginx_VM
  config.vm.define "web01" do |web01|
    web01.vm.box = "generic/centos8"
    web01.vm.hostname = "web01"
    web01.vm.network "private_network", ip: "192.168.60.11"
    web01.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
  end

  #Tomcat_VM
  config.vm.define "app01" do |app01|
    app01.vm.box = "generic/centos8"
    app01.vm.hostname = "app01"
    app01.vm.network "private_network", ip: "192.168.60.12"
    app01.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
  end

  #RabbitMQ_VM 
  config.vm.define "rmq01" do |rmq01|
    rmq01.vm.box = "generic/centos8"
    rmq01.vm.hostname = "rmq01"
    rmq01.vm.network "private_network", ip: "192.168.60.13"
    rmq01.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
  end

  #Memcache_VM
  config.vm.define "mc01" do |mc01|
    mc01.vm.box = "generic/centos8"
    mc01.vm.hostname = "mc01"
    mc01.vm.network "private_network", ip: "192.168.60.14"
    mc01.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
  end

  #Database_VM
  config.vm.define "db01" do |db01|
    db01.vm.box = "generic/centos8"
    db01.vm.hostname = "db01"
    db01.vm.network "private_network", ip: "192.168.60.15"
    db01.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
  end
end

