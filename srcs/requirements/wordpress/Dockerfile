FROM debian:bullseye

RUN apt update -y && apt upgrade -y
RUN apt install -y wget
RUN apt-get install -y iputils-ping php7.4 php-fpm php-mysql php-imagick mariadb-client

RUN mkdir -p /run/php 
RUN mkdir -p /var/www/wordpress

RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www

RUN mkdir -p /var/www/wordpress/wp-content/uploads
RUN chown -R www-data:www-data /var/www/wordpress/wp-content/uploads
RUN chmod -R 755 /var/www/wordpress/wp-content/uploads

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/init_wp.sh /usr/local/init_wp.sh
RUN chmod +x /usr/local/init_wp.sh

EXPOSE 9000

ENTRYPOINT ["sh", "/usr/local/init_wp.sh"]