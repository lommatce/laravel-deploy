#!/bin/bash

# Change to the project directory
cd /var/www/html/your-project || exit

# Set the COMPOSER_ALLOW_SUPERUSER environment variable
export COMPOSER_ALLOW_SUPERUSER=1

# Set app to maintenance mode
php artisan down || true

# Pull the latest changes
git pull origin main

# Install PHP dependencies without dev packages
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
if [ $? -ne 0 ]; then
  echo "Following command returned a error: 'composer install'."
  exit 1
fi

# Restart PHP service
service php8.3-fpm restart

# Run database migrations
php artisan migrate --force

# Clear and optimize caches
php artisan cache:clear
php artisan auth:clear-resets
php artisan route:cache
php artisan config:cache
php artisan view:cache

# Install JavaScript dependencies
npm install
if [ $? -ne 0 ]; then
  echo "Following command returned a error: 'npm install'."
  exit 1
fi

# Bring the application back online
php artisan up