# Create image based on the official PHP-FMP image
FROM php:8.0-fpm-bullseye AS base-stage

# Arguments defined in docker-compose.yml
ARG uid

# Update the base libraries
RUN apt-get -y update --fix-missing && apt-get upgrade -y

# Install useful tools and install important libaries
RUN apt-get -y --no-install-recommends install --fix-missing \
    git nano wget dialog \
    apt-utils build-essential \
    zip openssl curl \
    libmcrypt4 \
    libfreetype6 \
    libjpeg62-turbo \
    libpng16-16 \
    libxpm4 \
    libsqlite3-dev \
    libsqlite3-0 \
    default-mysql-client \
    libmcrypt-dev \
    zlib1g-dev \
    libzip-dev \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libonig-dev \
    libcurl3-dev \
    libcurl3-openssl-dev \
    libmemcached-dev \
    zlib1g-dev

# Other PHP5.6 Extensions
RUN echo "Installing PHP extensions" && \
    docker-php-ext-install pdo pdo_mysql mysqli curl tokenizer zip mbstring gettext opcache && \
    docker-php-ext-configure \
        # ref: https://github.com/docker-library/php/issues/920#issuecomment-562864296
        gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd

# Other PHP5.6 Extensions
RUN echo "Enabling PHP extensions" && \
    docker-php-ext-enable pdo_mysql && \
    docker-php-ext-enable pdo && \
    docker-php-ext-enable mysqli && \
    docker-php-ext-enable zip

# Install intl extension
RUN echo "Install PHP Intl" \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-enable intl \
    && rm -rf /tmp/*

# Install sendmailer for Mailhog
RUN  curl --location --output /usr/local/bin/mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64  \
     && chmod +x /usr/local/bin/mhsendmail

# Clean up, try to reduce image size
RUN apt-get remove -y libmcrypt-dev libicu-dev libpng-dev libjpeg-dev libfreetype6-dev libxpm-dev libvpx-dev gcc \
  && apt-get autoremove -y \
  && apt-get clean all \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*

# -------------------------------------------------------
# SERVE STAGE
# -------------------------------------------------------

# Get API Base Image
FROM base-stage AS serve-stage

# Arguments defined in compose.yml
ARG uid

# Install serve dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get -y --no-install-recommends install \
    nginx \
    memcached \
    ssl-cert

# Clean up, try to reduce image size
RUN apt-get autoremove -y \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# Generate ssl certificate
RUN make-ssl-cert generate-default-snakeoil --force-overwrite

# Copy nginx config
COPY .docker/services/webserver/config/sites-available/default.nginx /etc/nginx/sites-available/default

# Copy entrypoint
COPY .docker/services/webserver/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN ln -s /usr/local/bin/entrypoint.sh /

# Specify the entrypoint
ENTRYPOINT ["entrypoint.sh"]

# Set working dir
WORKDIR /var/www/html
