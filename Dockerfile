FROM php:7.3-apache

# ========= APACHE SETUP =========
# The webserver runs as www-data, with UID:GID of 33:33 by default
# This will cause permission problems as the webserver will be unable to write
# files in directories created on the host. Instead, we can set for user and
# group ID to match the user on the host system. This can only be done at
# buildtime.
ARG UID=1000
ARG GID=1000

# Set the UID and GID to 1000 to match the host machine
RUN usermod -u ${UID} www-data && \
      groupmod -g ${GID} www-data && \
      chsh -s /bin/bash www-data

RUN chmod a+w /tmp

# Allow document root to be configured at runtime
# `docker run <options> -e APACHE_DOCUMENT_ROOT=/path/to/new/root <image>`
# or in your `docker-compose.yml`
ENV APACHE_DOCUMENT_ROOT /var/www/html
# No composer memory limit and use caching for better performance
ENV COMPOSER_MEMORY_LIMIT -1
ENV COMPOSER_CACHE_DIR /tmp

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
      /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g'\
    /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && a2enmod rewrite \
    && service apache2 restart

# ========= PHP SETUP =========
# install php extensions - database connectors, gd and zip
RUN apt-get update && \
    apt-get install -yyq --no-install-recommends \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      libpq-dev \
      libwebp-dev \
      libxpm-dev \
      libzip-dev \
      mariadb-client \
      unzip \
      zip; \
    rm -rf /var/lib/apt/lists/* ; \
    docker-php-ext-configure gd \
      --with-freetype-dir \
      --with-jpeg-dir \
      --with-png-dir \
      --with-webp-dir \
      --with-xpm-dir \
      --with-zlib-dir \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install -j$(nproc) \
        gd \
        opcache \
        pdo_mysql \
        pdo_pgsql \
        zip \
    && pecl install uploadprogress \
    && docker-php-ext-enable uploadprogress

# install composer
RUN curl  -o /usr/local/bin/composer \
      https://getcomposer.org/download/1.10.6/composer.phar; \
    chmod +x /usr/local/bin/composer

# install Drush launcher
RUN curl  -o /usr/local/bin/drush \
          -L https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar; \
      chmod +x /usr/local/bin/drush

