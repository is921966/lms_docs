# Build stage for dependencies
FROM composer:2.6 AS composer-build
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Build stage for frontend assets (if needed)
FROM node:20-alpine AS node-build
WORKDIR /app
# COPY package.json package-lock.json ./
# RUN npm ci --only=production
# COPY . .
# RUN npm run build

# Production image
FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    postgresql-dev \
    icu-dev \
    oniguruma-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libzip-dev \
    supervisor \
    nginx

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo \
        pdo_pgsql \
        pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        intl \
        zip \
        soap \
        opcache \
        sockets

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Install APCu extension
RUN pecl install apcu && docker-php-ext-enable apcu

# Configure PHP
COPY docker/php/php.ini /usr/local/etc/php/conf.d/custom.ini

# Configure OPcache
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.interned_strings_buffer=16" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.revalidate_freq=0" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/opcache.ini

# Create application user
RUN addgroup -g 1000 -S www && \
    adduser -u 1000 -S www -G www

# Set working directory
WORKDIR /var/www

# Copy application files
COPY --chown=www:www . .

# Copy dependencies from build stage
COPY --from=composer-build --chown=www:www /app/vendor ./vendor

# Copy frontend assets from build stage (if needed)
# COPY --from=node-build --chown=www:www /app/public/build ./public/build

# Generate autoloader
RUN composer dump-autoload --optimize --no-dev

# Create necessary directories
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views \
    && chown -R www:www storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Configure supervisor (skip for now)
# COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose port
EXPOSE 9000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD php-fpm -t || exit 1

# Switch to non-root user
USER www

# Start PHP-FPM
CMD ["php-fpm"] 