#!/bin/bash
echo --------------------------------------------------
echo SynchWeb container started - now setting up required services...
export COMPOSER_ALLOW_SUPERUSER=1 #This allows compose to run as root in this container
cd /app/SynchWeb/api && /tmp/composer install && /tmp/composer update
httpd -f /etc/httpd/conf/httpd.conf -k start
if [[ "$1" == "-7" ]]; then
    PHP_INI_SCAN_DIR=/etc/php.d php-fpm -e -y /app/SynchWeb/php-fpm.conf -F -O -c /app/SynchWeb/php.ini &
else
    PHP_INI_SCAN_DIR=/opt/remi/php54/root/etc/php.d php-fpm -F -y /app/SynchWeb/php-fpm.conf -c /app/SynchWeb/php.ini &
fi
tail -f /var/log/httpd/error.log
echo Required services started on SynchWeb container.
echo --------------------------------------------------
wait
