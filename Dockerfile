FROM php:8.0.2-fpm-alpine as php

ARG UID=1000
ARG GID=1000

ENV PHPREDIS_VERSION 5.3.3

RUN apk update && apk add --no-cache \
        shadow \
        vim \
        curl \
        wget \
        git \
        jpeg \
        libwebp \
        libzip-dev \
        zip \
        unzip \
        postgresql-dev && \

        mkdir -p /usr/src/php/ext/redis \
        && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
        && echo 'redis' >> /usr/src/php-available-exts && \

        docker-php-ext-install -j "$(nproc)" \
        zip \
        pdo pdo_pgsql \
        opcache \
        bcmath \
        redis && \

        addgroup -S php && adduser -S php -G php && \
        usermod -u $UID php && \
        groupmod -g $GID php && \
        mkdir /app && \
        chown php:php /app

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY php.ini /usr/local/etc/php/conf.d/
COPY php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

WORKDIR /app

USER php
