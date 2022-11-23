#!/bin/bash
echo --------------------------------------------------
echo SynchWeb container started - now setting up required services...
export COMPOSER_ALLOW_SUPERUSER=1 #This allows compose to run as root in this container
cd /app/SynchWeb/api && /tmp/composer install
httpd -f /etc/httpd/conf/httpd.conf -k start
# comment/uncomment appropriate line to run with php5.4 (1st definition) or php7.4 (2nd definition)
PHP_INI_SCAN_DIR=/opt/remi/php54/root/etc/php.d php-fpm -F -y /app/SynchWeb/php-fpm.conf -c /app/SynchWeb/php.ini &
#PHP_INI_SCAN_DIR=/etc/php.d php-fpm -e -y php-fpm.conf -F -O -c php.ini &
tail -f /var/log/httpd/error.log
echo Required services started on SynchWeb container.
echo --------------------------------------------------
wait
