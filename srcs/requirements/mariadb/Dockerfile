FROM debian:bullseye

RUN apt update -y && apt upgrade -y
RUN apt install -y mariadb-server mariadb-client

RUN mkdir -p /run/mysqld /var/lib/mysql
RUN chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init_mdb.sh /usr/local/init_mdb.sh
RUN chmod +x /usr/local/init_mdb.sh

EXPOSE 3306

ENTRYPOINT [ "sh", "/usr/local/init_mdb.sh" ]