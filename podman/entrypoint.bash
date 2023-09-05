#!/bin/bash

echo '#!/usr/bin/php

<?php
        $logfile = "/app/SynchWeb/emails.txt";
        //* Get the email content
        $log_output = "****" . date("Y-m-d H:i:s") . "****\r\n";
        $handle = fopen("php://stdin", "r");
        while(!feof($handle))
        {
                $buffer = trim(fgets($handle));
                $log_output .= $buffer . "\r\n";
        }
        //* Write the log
        file_put_contents($logfile, $log_output);
?>' > /usr/sbin/sendmail
chmod a+x /usr/sbin/sendmail
touch /app/SynchWeb/emails.txt
chmod a+w /app/SynchWeb/emails.txt

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
