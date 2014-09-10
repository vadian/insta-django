package "nginx" do
    :upgrade
end

#service "lighttpd" do
#  enabled false
#  running false
#  supports :status => true, :restart => true, :reload => true
#  action [:stop, :disable]
#end

service "nginx" do
  enabled true
  running true
  supports :status => true, :restart => true, :reload => true
#  action [:start, :enable]
end

script "/www/_ownership" do
  interpreter "bash"
  code <<-EOH
  chown -R #{node[:web_user]}:www-data /www/** > /dev/null
  EOH
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0640"
  notifies :restart, resources(:service => "nginx")
end

node[:sites].each do |site|
  template "/etc/nginx/sites-enabled/#{site[:name]}" do
    source "site.nginx.erb"
    owner "root"
    group "root"
    mode "0640"
    variables :site => site
    notifies :restart, resources(:service => "nginx")
  end
end

execute "supervisor_start" do
  user node[:web_user]
  group node[:web_user]
  cwd "/tmp"
  command "supervisord"
  creates "/tmp/supervisor.sock"
  action :nothing
end

execute "supervisor_reload" do
  user node[:web_user]
  group node[:web_user]
  command "supervisorctl reload"
  action :nothing
end

template "/etc/supervisord.conf" do
  source "supervisord.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[supervisor_start]"
  notifies :run, "execute[supervisor_reload]"
end

node[:sites].each do |site|
  node[:sites].each do |site|
    template "#{node[:webroot]}/wsgi/#{site[:name]}.xml" do
      source "uwsgi.xml.erb"
      owner node[:web_user]
      group node[:web_user]
      mode "0640"
      variables :site => site
    end
  end
end