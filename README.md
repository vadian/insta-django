insta-django

Vagrant deployment with Chef provisioner to quickly create a working nginx/supervisor/django server. Manages both development VM and production deployment. Easily migrate existing code or create new projects. Supports any wsgi project.

Quickstart Instructions
--------------------------------------------

This package is designed for you to be able to quickly deploy a VM to test changes, and then push those changes to a digitalocean droplet. The high level process is to edit the 'vagrant.rb' file in the 'dev' directory, and place all your site requirements in 'siteinfo.rb'.
After you 'vagrant up' the VM, you may have to configure your database (unless you are using mysqlite). Test to your liking, change to the 'prod' directory and 'vagrant up' to deploy to digitalocean.

Development Server:
--------------------------------------------

cd into 'dev' directory

Edit vagrant.rb as below:

	module MyVars
		Role = "dev"
		Ssh_key = "ssh-rsa AJFADKNFWOHIFWOI89724DNKJDWANKJDAWNKDAWDAKLDWetcetcetc name@host"
	end

Note that you can add additional keys here that you intend to use for users (as you will see in the next step). The private versions of these keys should exist in your appropriate directory for your computer, usually '~/.ssh'

Copy siteinfo-example.rb to siteinfo-rb.

Edit the siteinfo.rb in a text editor. Many of the default options here will work, but you should configure the specifics of your site. Instructions are included in the file.

'vagrant up' in 'dev' directory.

'vagrant ssh' to connect to your server, and configure your databases.

Production Server:
--------------------------------------------

CD into 'prod' directory

Edit vagrant.rb as below:

	module MyVars
		Role = "prod"
		Token = "DigitalOcean OAuth Token"
		Ssh_key = "ssh-rsa AJFADKNFWOHIFWOI89724DNKJDWANKJDAWNKDAWDAKLDWetcetcetc name@host"
	end

None of the information in 'siteinfo.rb' is particular to dev or prod sites. Your current config you tested on dev should work in prod.

'vagrant up' in 'dev' directory.

'vagrant ssh' to connect to your droplet and configure your databases.

Usage:
--------------------------------------------

If you need to restart the webserver, while root, 'sudo service nginx restart'.

If you need to restart uWSGI, while root, 'sudo -u supervisorctl restart all' while logged on as your web-user, simply 'supervisorctl restart all', or 'supervisorctl' to view the interactive prompt.

All logs are stored in /logs/, next to your sites.

Deploying a new django site:
--------------------------------------------

Set 'Local_Rsync = true' in siteinfo.rb.

Create a new directory in your local webroot, and add it to the Sites = [] array in siteinfo.rb.

Configure your site by adding appropriate information to the JSON data.

In dev/ directory, 'vagrant up'. 

'ssh web_user@web_alias'

'source /envs/sitename/bin/activate'

'cd webroot'

'rm sitename'

'django-admin startproject sitename'

'logout'

NOTE: THIS WILL DESTRUCTIVELY OVERWRITE ANY CHANGED FILES IN YOUR SYNCED SITES!

'vagrant rsync-back' (requires vagrant plugin rsync-back')

Set 'Local_Rsync = false'

'vagrant reload'


You should now have a working Django dev site, which automatically reflects changes on local disk. Start working on your site's configuration and enjoy!
-------------------------------------------
