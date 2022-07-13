FROM centos:7
 
WORKDIR /app
 
# Install httpd, PHP and required dependencies
RUN yum install wget git tar xz-utils httpd mod_ssl -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/remi-php54.repo && \
    yum install -y php5.4 php54-php-mysql php54-php-mbstring php54-php-xml php54-php-gd php54-php-fpm php54-php-cli
 
# Add php to path
ENV PATH="${PATH}:/opt/remi/php54/root/usr/bin:/opt/remi/php54/root/usr/sbin"
 
# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/tmp --filename=composer
 
# Copy config file and adjust access permissions
COPY httpd.conf /etc/httpd/conf/
RUN chmod 744 /etc/httpd/conf/httpd.conf

# Set access port and startup script 
EXPOSE 8082
ENTRYPOINT ["/app/SynchWeb/entrypoint.bash"]
