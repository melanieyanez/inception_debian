#!/bin/bash

echo "------------------------------- MARIADB STARTING -------------------------------------"

echo "Checking MariaDB data directory..."
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysqld --initialize --user=mysql --datadir=/var/lib/mysql
    echo "MariaDB data directory initialized successfully."
else
    echo "MariaDB data directory already exists."
fi

echo "Setting correct permissions for MariaDB directories..."
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /run/mysqld

echo "Starting MariaDB..."
mysqld --user=mysql --datadir=/var/lib/mysql &

echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping --silent; do
    sleep 1
done

echo "MariaDB is ready. Proceeding with configuration."

if [ -n "${MARIADB_ROOT_PASSWORD}" ] && [ -n "${MARIADB_DATABASE}" ] && [ -n "${MARIADB_USER}" ] && [ -n "${MARIADB_PASSWORD}" ]; then
    echo "Configuring database and user..."
    mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"
    mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};"
    mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS '${MARIADB_USER}' IDENTIFIED BY '${MARIADB_PASSWORD}';"
    mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"
    mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"
else
    echo "One or more required environment variables are missing. Skipping configuration."
fi

echo "------------------\n"
mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "SHOW DATABASES;"
echo "------------------\n"
mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "SELECT User FROM mysql.user;"
echo "------------------\n"

echo "Configuration complete. Stopping background MariaDB process..."
mysqladmin -u root -p${MARIADB_ROOT_PASSWORD} shutdown

echo "Starting MariaDB as the main process..."
exec mysqld --user=mysql --datadir=/var/lib/mysql