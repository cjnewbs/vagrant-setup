#!/usr/bin/env bash

sudo -i

if (( $EUID != 0 )); then
    echo "Sudo failed"
    exit
fi

sudo apt-get update -y

sudo apt-get install -y software-properties-common apt-transport-https lsb-release ca-certificates

sudo apt-get update -y

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

# apt get setup for php
echo 'Adding PHP repo for Debian'
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sudo echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

sudo apt-get update -y

# apt get setup for mariadb
echo 'Adding MariaDB repo for Debian'
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
sudo add-apt-repository -y 'deb [arch=amd64,i386,ppc64el] http://mirror.sax.uk.as61049.net/mariadb/repo/10.1/debian jessie main'

sudo apt-get update -y

# get our packages
echo 'Installing Packages'

echo 'Installing Curl'
sudo apt-get install -y curl
echo 'Installing MariaDB Server'
sudo apt-get install -y mariadb-server
echo 'Installing NGINX'
sudo apt-get install -y nginx
echo 'Install Redis'
sudo apt-get install redis-server -y
echo 'Installing Unzip'
sudo apt-get install -y unzip
echo 'Installing Zip'
sudo apt-get install -y zip
echo 'Installing PHP FPM'
sudo apt-get install -y php7.4-fpm
echo 'Installing PHP BCMath'
sudo apt-get install -y php7.4-bcmath
echo 'Installing PHP CLI'
sudo apt-get install -y php7.4-cli
echo 'Installing PHP CGI'
sudo apt-get install -y php7.4-cgi
echo 'Installing PHP Curl'
sudo apt-get install -y php7.4-curl
echo 'Installing PHP GD'
sudo apt-get install -y php7.4-gd
echo 'Installing PHP Intl'
sudo apt-get install -y php7.4-intl
echo 'Installing PHP MBString'
sudo apt-get install -y php7.4-mbstring
echo 'Installing PHP MCrypt'
sudo apt-get install -y php7.4-mcrypt
echo 'Installing PHP MySQL'
sudo apt-get install -y php7.4-mysql
echo 'Installing PHP SOAP'
sudo apt-get install -y php7.4-soap
echo 'Installing PHP XML'
sudo apt-get install -y php7.4-xml
echo 'Installing PHP Zip'
sudo apt-get install -y php7.4-zip
echo 'Installing PHP XDebug'
sudo apt-get install -y php-xdebug
echo 'Installing Git'
sudo apt-get install -y git
echo 'Installing PV (Pipe Viewer)'
sudo apt-get install pv -y

echo 'Creating empty DB for application'
mysql -uroot -proot -e"CREATE DATABASE cover_me;"
if test -f "/home/vagrant/www/db.sql.gz"; then
	echo 'Restoring SQL dump'
	pv --interval 10 --force /home/vagrant/www/db.sql.gz | gunzip | mysql -uroot -proot magento
fi
if test -f "/home/vagrant/www/vagrant/local.sql.dist"; then
	echo 'Updating DB for local development'
	envsubst '$DOMAIN' < /home/vagrant/www/vagrant/local.sql.dist > /home/vagrant/www/local.sql
	mysql -uroot -proot laravel < /home/vagrant/www/local.sql
	rm /home/vagrant/www/local.sql
fi


# Configure xdebug
echo 'Configuring XDebug'
cat << EOF | sudo tee -a /etc/php/7.4/mods-available/xdebug.ini
xdebug.remote_enable=1
xdebug.remote_host=10.0.2.2
xdebug.cli_color=1
xdebug.show_local_vars=1
xdebug.idekey=PHPSTORM
EOF

echo 'Disabling XDebug'
sed -i 's/^zend_extension=xdebug.so$/#zend_extension=xdebug.so/g' /etc/php/7.4/fpm/conf.d/20-xdebug.ini
sed -i 's/^zend_extension=xdebug.so$/#zend_extension=xdebug.so/g' /etc/php/7.4/cli/conf.d/20-xdebug.ini

# change cgi setting in php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/fpm/php.ini

# copy nginx config
echo 'Copying NGINX config'
envsubst '$DOMAIN' </home/vagrant/www/vagrant/laravel.conf > /home/vagrant/www/laravel.conf
sudo cp /home/vagrant/www/vagrant/laravel.conf /etc/nginx/sites-available
sudo ln -f -s /etc/nginx/sites-available/laravel.conf /etc/nginx/sites-enabled

# delete default
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default

# Lets get secured!
echo 'Setting up SSL'
sudo mkdir /etc/nginx/certs
cd /etc/nginx/certs
echo 'Creating private key'
sudo openssl genrsa -out "laravel.key" 2048
sudo openssl req -new -key "laravel.key" -out "laravel.csr" -subj "/C=GB"
sudo openssl x509 -req -days 365 -in "laravel.csr" -signkey "laravel.key" -out "laravel.crt"

# restart nginx and php
echo 'Restarting NGINX'
sudo service nginx restart
echo 'Restarting PHP'
sudo service php7.4-fpm restart

# Download and install Composer
echo 'Downloading and Installing Composer'
curl -Ss https://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer

# Install Prestissimo
echo 'Installing Prestissimo'
composer global require hirak/prestissimo

echo 'Running Laravel installation'
cd /home/vagrant/www
composer install
