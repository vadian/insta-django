module Localdata

  #Descriptor of your site, your shortname
  Base_sitename = "mycoolsite"
  
  #All aliases that you want the dev server to respond to
  Dev_aliases = %w(mysite.dev mysitemezz.dev)

  #
  Rsa_keypath = "~/.ssh/id_rsa_digitalocean"

  #Configure local website-root directory.  Your projects live here. Put them here or symlink.
  Localroot = "~/www"
  #Where the above files should live on the server.
  Webroot = "/www"

  #These are the folders in Localroot that will be rsynced.  They should match the sites described in Jsondata below.
  Sites = ["mysite", "mysitemezz"]

  #Rsync (true) allows remote editing on the VM, helpful for creating new projects (vagrant plugin rsync-back is helpful!)
  #regular (false) reflects changes instantly for ease of development
  #This setting ONLY affects 'dev' servers.
  Local_Rsync = true

  Jsondata = {
    "role" => Role,
    "webroot" => Webroot,

    #This is the account you will log on to manage web services.  Nginx and Supervisor run under this user.
    "web_user" => "www-user",

    #These are packages required for installation.  You can probably leave them untouched.
    "base_packages" => ["git-core", "bash-completion", "software-properties-common", "python-software-properties"],

    #These are the apt packages to install and their versions.  This list currently works, but can be tweaked.
    "apt_packages" => {
    'vim' => nil,
    'curl' => nil,
    'git' => '1.7.10.4',
    'build-essential' => nil,
    'nmap' => nil,
    'libssl-dev' => nil, 
    'openssl' => nil, 
    'libsqlite3-dev' => nil,
    'python-sqlite' => nil,
    'libpq-dev' => nil,
    'postgresql' => 9.4,
    'postgresql-contrib' => nil,
    'php5-cgi' => nil,
    'php5' => nil,
    'libjpeg8' => nil,
    'libjpeg8-dev' => nil,
    'libbz2-dev' => nil,
    'python-dev' => nil,
    'libxml2-dev' => nil,
    'libxslt1-dev' => nil,
    'libffi-dev' => nil,
    'python3.4-dev' => nil,
    'python3.2-dev' => nil,
    'python-pip' => nil,
    'python3-pip' => nil,
    'python3-venv' => nil,
    'python3-virtualenv' => nil,
    'python-virtualenv' => nil,
    'lighttpd' => nil,
    'python-software-properties' => nil,
    'gcc' => nil,
    'postgresql-client' => nil,
    'mysql-server' => nil,
    'mysql-client' => nil
    },

    #Packages installed system-wide. You can probably leave these untouched.
    "ubuntu_python_packages" => ["python-setuptools", "python-pip", "python-dev", "libpq-dev"],

    #Python 2.7 Packages for System Administration.  You can probably leave these untouched.
    "pip_python_packages" => [
     "pip>=1.5",
     "uwsgi==2.0.6",
     "supervisor>=3.1.1"
    ],

    #Add new sites to this array as desired.  Each will be deployed and automatically configured.
    "sites" => [{
        #This is the MEZZANINE example template, which should deploy a working site environment for Mezz 3.0.9
        "name" => "mysitemezz", #This should match the appropriate directory listed in the Sites array at top.

        #What domains should direct here, for both dev and prod.  This configures Nginx.
        "aliases" => "mysitemezz.com mysitemezz.dev dev.mysitemezz.com *.mysitemezz.com",

        #Currently, only python is supported.
        "type" => "python", #python or php

        #Python version should be one of: '2.7', '3.2', '3.4'
        "python_version" => "3.4",

        #The pip packages you wish installed in your virtual environment. 
        #Your 'pip freeze' or requirements.txt files go here.
        #It should always start with 'pip>=1.5'
        "pip_packages" => [
          "pip>=1.5",
          "south",
          "Django==1.6.6",
          "html5lib==1.0b3",
          "Mezzanine==3.0.9",
          "mezzanine-meze",
          "Pillow==2.3.1",
          "bleach==1.4",
          "django-toolbelt",
          "grappelli-safe==0.3.7",
          "oauthlib==0.6.3",
          "pytz==2014.2",
          "requests==2.2.1",
          "requests-oauthlib",
          "tzlocal==1.0",
          "future>=0.13.0",
          "sphinx",
          "uwsgi==2.0.6"
        ],
        #WSGI configuration relative to project root.
        #Workdir is the directory the server should be in when it runs uWSGI.  Usually project root.
        #The below configuration works for Mezzanine.
        "workdir" => "",
        "wsgi_file" => "wsgi.py"
      },
      {
        #This is the default django project template.
        "name" => "mysite", #This should match the appropriate directory listed in the Sites array at top.

        #What domains should direct here, for both dev and prod.  This configures Nginx.
        "aliases" => "mysite.coffee www.mysite.coffee mysite.dev *.mysite.coffee",
       
        #Currently, only python is supported.
        "type" => "python", #python or php

        #Python version should be one of: '2.7', '3.2', '3.4'
        "python_version" => "3.4",

        #The pip packages you wish installed in your virtual environment. 
        #Your 'pip freeze' or requirements.txt files go here.
        #It should always start with 'pip>=1.5'
        "pip_packages" => [
          "pip>=1.5",
          "Django==1.7",
          "requests>=2.4",
          "requests-oauthlib>=0.0.0",
          "uwsgi==2.0.6",
          "psycopg2",
          "django-compressor",
          "django_extensions",
        ],
        #WSGI configuration relative to project root.
        #Workdir is the directory the server should be in when it runs uWSGI.  Usually project root.
        #The below configuration works for a default Django project.
        "workdir" => "",
        "wsgi_file" => "mysite/wsgi.py"
      },
      
    ],

    #The most important user is the one you defined above as web-user.  You will use this to log on.
    "users" => {
      "www-user" => {
        "id" => 1001,
        "full_name" => "Web Services",
        "key" => Ssh_key,
        "shell" => "/bin/bash"
      },

      #Another example user.  You can define another key in your vagrant.rb to replace the key below.
      #Note that this user is restricted to git commands by the shell specified.
      "git" => {
        "id" => 1002,
        "full_name" => "Git Client",
        "key" => Ssh_key,
        "shell" => "/usr/bin/git-shell"
      }
    },

    "groups" => {
      "mysite" => {
        "gid" => 201,
        "members" => ["www-user", "root"]
      },

      #Your web-user defined above should be a member of this group.
      "www-data" => {
        "members" => ["www-user", "root"]
      }
    }
  }
end