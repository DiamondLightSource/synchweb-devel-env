FROM rockylinux:8.9

WORKDIR /app
 
# Install httpd, PHP, git and required dependencies
RUN dnf module enable php:7.4 -y && \
    yum install -y wget git tar xz httpd mod_ssl zip unzip php-zip && \
    yum install -y php php-mysqlnd php-mbstring php-xml php-gd php-fpm php-cli php-ldap
 
# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/tmp --filename=composer
 
# Copy config
COPY httpd.conf /etc/httpd/conf/

RUN chmod 744 /etc/httpd/conf/httpd.conf
 
# Create self signed certificate for use in dev
RUN mkdir /etc/pki/tls/private/synchweb && \
    mkdir /etc/pki/tls/certs/synchweb && \
    openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes \
            -out /etc/pki/tls/certs/synchweb/cert.pem \
            -keyout /etc/pki/tls/private/synchweb/key.pem \
            -subj "/C=UK/ST=Oxfordshire/L=Test/O=Test/OU=Test/CN=local-oidc-test.diamond.ac.uk"

EXPOSE 8082 9003
ENTRYPOINT ["/app/SynchWeb/entrypoint.bash", "-7"]
