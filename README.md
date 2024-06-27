README - Docker PHP Environment
===============================

Description
-----------

This project sets up a Docker environment for PHP with Apache and PostgreSQL. The environment includes the following PHP extensions and tools:

*   intl
*   pdo\_pgsql
*   xsl
*   amqp
*   gd
*   openssl
*   sodium
*   composer
*   Node.js
*   npm
*   Symfony CLI

Files
-----

The project includes the following files:

*   `Dockerfile`: Defines the custom PHP image with necessary extensions.
*   `docker-compose.yml`: Configures the Docker services.

Dockerfile
----------

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
    
    # Install Node.js and npm
    RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
        && apt-get install -y nodejs
    
    # Install Symfony CLI
    RUN wget https://get.symfony.com/cli/installer -O - | bash \
        && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony
    
    # Enable Apache rewrite module
    RUN a2enmod rewrite
    
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

docker-compose.yml
------------------

    version: '3.8'
    
    services:
      php-apache:
        build:
          context: .
          dockerfile: Dockerfile
        volumes:
          - ./src/:/var/www/html/public
        ports:
          - "9090:80"
          - "9091:8080"
        environment:
          - APACHE_RUN_USER=www-data
          - APACHE_RUN_GROUP=www-data
        networks:
          - app-network
    
      postgres:
        image: postgres:latest
        environment:
          POSTGRES_DB: mydatabase
          POSTGRES_USER: myuser
          POSTGRES_PASSWORD: mypassword
        volumes:
          - postgres_data:/var/lib/postgresql/data
        networks:
          - app-network
    
    volumes:
      postgres_data:
    
    networks:
      app-network:
        driver: bridge

Instructions
------------

### 1\. Place files in the same directory

Ensure that the `Dockerfile` and `docker-compose.yml` files are in the same directory as your PHP application.

### 2\. Build and run containers

Run the following command in your terminal:

    docker-compose up --build

### 3\. Access your application

Open your browser and go to [http://localhost:9090](http://localhost:9090).

### 4\. Verify installed PHP extensions

To verify that the PHP extensions are installed correctly, you can run the following command inside the PHP container:

    docker-compose exec php-apache php -m

This command will list all PHP extensions currently installed and enabled in the container.