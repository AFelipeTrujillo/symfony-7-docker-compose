# Use official PHP image with Apache
FROM php:8.2-apache

# Install necessary dependencies to build extensions and librabbitmq
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpq-dev \
    libxslt-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libssl-dev \
    libsodium-dev \
    libssh-dev \
    libmagickwand-dev \
    libmagickcore-dev \
    wget \
    unzip \
    git \
    pkg-config \
    librabbitmq-dev \
    curl

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    intl \
    pdo_pgsql \
    xsl \
    gd \
    opcache \
    sodium \
    bcmath

# Install AMQP extension
RUN pecl install amqp \
    && docker-php-ext-enable amqp

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

# Install Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Configure Apache to point to /var/www/html/public directory
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/apache2.conf

# Expose port 80
EXPOSE 80

# Set working directory
WORKDIR /var/www/html

# Copy application source code into the container
COPY . /var/www/html

# Optionally grant permissions to www-data user
# RUN chown -R www-data:www-data /var/www/html

# Run Apache in foreground
CMD ["apache2-foreground"]
