FROM debian:bullseye

RUN apt update -y && apt upgrade -y
RUN apt-get install -y nginx

RUN mkdir -p /etc/nginx/ssl
RUN apt install -y openssl
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=CH/ST=VD/L=Lausanne/O=42/OU=42/CN=myanez-p.42.fr/emailAddress=myanez-p@student.42lausanne.ch"

RUN mkdir -p /var/run/nginx
RUN mkdir -p /var/www/wordpress
RUN chmod -R 755 /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/init_nx.sh /usr/local/init_nx.sh
RUN chmod +x /usr/local/init_nx.sh

EXPOSE 443

ENTRYPOINT [ "sh", "/usr/local/init_nx.sh" ]