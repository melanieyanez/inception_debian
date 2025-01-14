#!/bin/bash

echo "------------------------------- WORDPRESS START -----------------------------------"

echo "Checking PHP version..."
php-fpm7.4 -v

echo "Waiting for MariaDB to be ready..."
while ! mariadb -u "$MARIADB_USER" --password="$MARIADB_PASSWORD" -h "$WP_HOST" -P 3306 --silent 2>/dev/null; do
    echo "MariaDB is not ready yet, retrying..."
    sleep 2
done
echo "MariaDB is ready!"

echo "Displaying existing databases as ${MARIADB_USER}..."
mariadb -u $MARIADB_USER --password=$MARIADB_PASSWORD -h "$WP_HOST" -P 3306 -e "SHOW DATABASES;" || {
    echo "Error: Unable to connect to MariaDB as ${MARIADB_USER}.";
    exit 1;
}

echo "Checking if WordPress is already installed..."
if [ -e /var/www/wordpress/wp-config.php ]; then
    echo "WordPress configuration file (wp-config.php) exists. Skipping installation."
else
    echo "WordPress configuration file not found. Proceeding with installation..."

    echo "Downloading WP-CLI..."
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    echo "Setting executable permissions for WP-CLI..."
    chmod +x wp-cli.phar
    echo "Moving WP-CLI to /usr/local/bin..."
    mv wp-cli.phar /usr/local/bin/wp
    echo "WP-CLI installed successfully."

    echo "Downloading WordPress core..."
    cd /var/www/wordpress
    wp core download --allow-root

    echo "Configuring WordPress..."
    wp config create --dbname=$MARIADB_DATABASE --dbuser=$MARIADB_USER --dbpass=$MARIADB_PASSWORD --dbhost=$WP_HOST --dbcharset="utf8" --dbcollate="utf8_general_ci" --allow-root

    echo "Installing WordPress core..."
    wp core install --url=$DOMAIN_NAME --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root

    echo "Creating WordPress user..."
    wp user create $WP_USER $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PASS --allow-root
fi

echo "Starting PHP-FPM in foreground mode..."
php-fpm7.4 -F