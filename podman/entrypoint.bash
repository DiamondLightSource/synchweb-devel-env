#!/bin/bash
echo --------------------------------------------------
echo SynchWeb container started - now setting up required services...
cd /app/SynchWeb/api && /tmp/composer install
httpd -f /etc/httpd/conf/httpd.conf -k start
PHP_INI_SCAN_DIR=/opt/remi/php54/root/etc/php.d php-fpm -F -y /app/SynchWeb/php-fpm.conf -c /app/SynchWeb/php.ini
echo Required services started on SynchWeb container.
echo --------------------------------------------------
wait
