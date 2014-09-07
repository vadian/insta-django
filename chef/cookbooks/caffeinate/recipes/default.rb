#
# Cookbook Name:: django
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'apt'
#include_recipe 'mysql::client'
#include_recipe 'mysql::server'

#script "rmfile" do
#  interpreter "bash"
#  user "root"
#  code "rm /vagrant/vagrant.rb"
#end

#Create Swap File, 2GB, prod only
if node[:role] == "prod" or "test" then
  script "make-swap" do
    interpreter "bash"
    user "root"
    cwd "/var"
    creates "/var/swap.img"
    code <<-EOH
      touch /var/swap.img
      dd if=/dev/zero of=/var/swap.img bs=2048k count=1000
      chmod 600 /var/swap.img
      mkswap /var/swap.img
      swapon /var/swap.img
    EOH
  end
end

#script 'apt-get update' do
#  interpreter 'bash'
#  command "apt-get update"
#end

apt_repository 'jessie' do
  uri        'http://ftp.debian.org/debian'
  components ['jessie', 'main']
end

#Run config from data passed in CHANGED FROM UPGRADE TO INSTALL (worked through build-essential)
node[:base_packages].each do |pkg|
    package pkg do
        :install
    end
end

#script 'apt-configure-jessie' do
#  interpreter 'bash'
#  command "add-apt-repository \"deb http://ftp.debian.org/debian jessie main\""
#end

#script 'apt-get update' do
#  interpreter 'bash'
#  command "apt-get update"
#end


#Apt-get apt-packages
node[:apt_packages].each_pair do |pkg, pkg_ver|
   apt_package pkg do
     package_name = pkg
     version = pkg_ver
     action :upgrade
   end
end


script "extra-apts" do
  interpreter "bash"
  command "apt-get build-dep -y python-imaging && pip3 install --upgrade pip"
end


node[:ubuntu_python_packages].each do |pkg|
    package pkg do
        :upgrade
    end
end


# System-wide packages installed by pip.
# Careful here: most Python stuff should be in a virtualenv.
# Note that these are python2.7 packages

node[:pip_python_packages].each do |pkg|
    execute "pip-base-install-#{pkg}" do
        command "pip install \'#{pkg}\'"
    end
end

#node[:pip_python_packages].each_pair do |pkg, version|
#    execute "install-#{pkg}" do
#        command "pip install #{pkg}==#{version}"
#        not_if "[ `pip freeze | grep #{pkg} | cut -d'=' -f3` = '#{version}' ]"
#    end
#end

#Deal with users
node[:users].each_pair do |username, info|
    group username do
       gid info[:id]
    end

    user username do
        comment info[:full_name]
        uid info[:id]
        gid info[:id]
        shell info[:disabled] ? "/sbin/nologin" : info[:shell]
        supports :manage_home => true
        home "/home/#{username}"
    end

    directory "/home/#{username}" do
      owner username
      group username
      mode 0755
    end

    directory "/home/#{username}/.ssh" do
        owner username
        group username
        mode 0700
    end

    directory "/home/#{username}/logs" do
	owner username
	group username
	mode 0666
    end

    file "/home/#{username}/.ssh/authorized_keys" do
        owner username
        group username
        mode 0600
        content info[:key]
    end

    cookbook_file "/home/#{username}/.bashrc" do
        source "bashrc"
        owner username
        group username
    end
end

node[:groups].each_pair do |name, info|
    group name do
        gid info[:gid]
        getmembers = Array[info[:members]]

        if node[:role] == "dev"
          getmembers.push("vagrant")
        end
        members getmembers
    end
end

if node[:role] == "prod" or "test"
  cookbook_file "/root/.bashrc" do
    source "bashrc"
    owner "root"
    group "root"
    mode "0644"
  end
else
  cookbook_file "/home/vagrant/.bashrc" do
    source "bashrc"
    owner "vagrant"
    group "vagrant"
    mode "0644"
  end
end

#Install Python by version ['caffeinate']['python_version']
#directory "/tmp/python" do
#  owner 'caffeinate'
#  group 'caffeine'
#  action :create
#end

#python_file = Chef::Config[:file_cache_path] + "/python/python.tar.gz"

#remote_file python_file do
#  source "https://www.python.org/ftp/python/#{node['caffeinate']['python_version']}/Python-#{node['caffeinate']['python_version']}.tgz"
#  mode "0644"
#  owner 'caffeinate'
#  group 'caffeine'
#  path "/tmp/python/python.tgz"
#  action :create_if_missing
#end

#execute "untar-python" do
#  cwd "tmp/python"
#  user 'caffeinate'
#  group 'caffeine'
#  command "tar --strip-components 1 -xzf python.tgz && ./configure --with-ensurepip=install && make"
#  creates "/usr/local/bin/python3"
#end

#execute "make-install-python" do
#  cwd "tmp/python"
#  user 'root'
#  command "make install"
#  creates "/usr/local/bin/python3"
#end

#Configure webroot and environments directory
directory node[:webroot] do
    owner node[:web_user]
    group node[:web_user]
    mode 0775
end

directory "#{node[:webroot]}/envs" do
    owner node[:web_user]
    group node[:web_user]
    mode 0775
end

directory "#{node[:webroot]}/log" do
  owner node[:web_user]
  group node[:web_user]
  mode 0774
end

directory "#{node[:webroot]}/wsgi" do
  owner node[:web_user]
  group node[:web_user]
  mode 0774
end