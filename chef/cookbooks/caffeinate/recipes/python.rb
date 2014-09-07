node[:sites].each do |site|
  if site[:type] == "python" then
    if site[:python_version] == "3.4" then
      script "#{site[:name]}-pyvenv" do
        interpreter "bash"
        user node[:web_user]
        group node[:web_user]
        creates "#{node[:webroot]}/envs/#{site[:name]}"
        code "pyvenv-3.4 #{node[:webroot]}/envs/#{site[:name]}"
      end
    else
      script "#{site[:name]}-virtualenv" do
        interpreter "bash"
        user node[:web_user]
        group node[:web_user]
        creates "#{node[:webroot]}/envs/#{site[:name]}"
        code "virtualenv --python=python#{site[:python_version]} #{node[:webroot]}/envs/#{site[:name]}"
      end
    end

    site[:pip_packages].each do |pkg|
      script "#{site[:name]}-#{pkg}" do
        interpreter "bash"
        user node[:web_user]
        group node[:web_user]
        pkg = pkg.encode('ascii')
        code <<-EOH
        #{node[:webroot]}/envs/#{site[:name]}/bin/pip install \'#{pkg}\'
        EOH
      end
    end
  end
end