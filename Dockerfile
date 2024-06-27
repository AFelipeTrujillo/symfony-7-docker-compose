# Usa la imagen oficial de PHP con Apache
FROM php:8.2-apache

# Instala las dependencias necesarias para compilar las extensiones y librabbitmq
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

# Instala las extensiones de PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    intl \
    pdo_pgsql \
    xsl \
    gd \
    opcache \
    sodium \
    bcmath

# Instala la extensión AMQP
RUN pecl install amqp \
    && docker-php-ext-enable amqp

# Instala Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Habilita el módulo de reescritura de Apache
RUN a2enmod rewrite

# Instala Node.js y npm
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

# Instala Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Configura Apache para apuntar al directorio /var/www/html/public
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/apache2.conf

# Expone el puerto 80
EXPOSE 80

# Configura el directorio de trabajo
WORKDIR /var/www/html

# Copia el código fuente de la aplicación al contenedor
COPY . /var/www/html

# Otorga permisos al usuario www-data (opcional)
# RUN chown -R www-data:www-data /var/www/html

# Ejecuta el servidor Apache en primer plano
CMD ["apache2-foreground"]
