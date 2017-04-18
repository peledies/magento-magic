#! /usr/bin/env bash

# Variables
DBHOST=localhost
DBNAME=$1
DBUSER=$1
DBPASSWD=SECRET

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update

echo -e "\n--- Install base packages ---\n"
apt-get -y install composer build-essential python-software-properties >> /vagrant/vm_build.log 2>&1

echo -e "\n--- Installing PHP-specific packages ---\n"
apt-get -y install php apache2 libapache2-mod-php php-common php-mcrypt php-intl php-mbstring php-zip php-curl php-gd php-mysql php-gettext >> /vagrant/vm_build.log 2>&1

# MySQL setup for development purposes ONLY
echo -e "\n--- Install MySQL specific packages and settings ---\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

apt-get -y install mysql-server >> /vagrant/vm_build.log 2>&1

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" >> /vagrant/vm_build.log 2>&1
mysql -uroot -p$DBPASSWD -e "grant all privileges on *.* to '$DBUSER'@'%' identified by '$DBPASSWD'" > /vagrant/vm_build.log 2>&1
sed -i '/skip-external-locking/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i '/bind-address/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf

sudo service mysql restart >> /vagrant/vm_build.log 2>&1

echo -e "\n--- Enabling mod-rewrite ---\n"
a2enmod rewrite >> /vagrant/vm_build.log 2>&1

echo -e "\n--- Allowing Apache override to all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo -e "\n--- Setting document root to public directory ---\n"
#rm -rf /var/www/html
#ln -fs /vagrant/$DBUSER /var/www/html

echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart >> /vagrant/vm_build.log 2>&1

echo -e "\n--- Executing Magento Setup ---\n"
cd /var/www/html/bin
./magento setup:install --admin-firstname="$DBUSER" --admin-lastname="$DBUSER" --admin-email="example@example.com" --admin-user="$DBUSER" --admin-password="TH3S3CR3T" --db-name="$DBNAME" --db-host="localhost" --db-user="$DBUSER" --db-password="$DBPASSWD" >> /vagrant/magento_setup.log 2>&1
