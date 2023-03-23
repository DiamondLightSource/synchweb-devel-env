#!/bin/bash
app_home=/app/SynchWeb

echo --------------------------------------------------
echo SynchWeb container started - now setting up required services...
export COMPOSER_ALLOW_SUPERUSER=1 #This allows compose to run as root in this container

cd $app_home/api && /tmp/composer install
cd $app_home/api && /tmp/composer upgrade  # only do this during dev

httpd -f /etc/httpd/conf/httpd.conf -k start
if [[ "$1" == "-7" ]]; then
    PHP_INI_SCAN_DIR=/etc/php.d php-fpm -e -y $app_home/php-fpm.conf -F -O -c $app_home/php.ini &
else
    PHP_INI_SCAN_DIR=/opt/remi/php54/root/etc/php.d php-fpm -F -y $app_home/php-fpm.conf -c $app_home/php.ini &
fi

tail -f /var/log/httpd/error.log
echo Required services started on SynchWeb container.
echo --------------------------------------------------
wait
