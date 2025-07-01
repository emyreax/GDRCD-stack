#!/usr/bin/env bash
set -e

# PHP > Start services
memcached -u memcached -d
php-fpm -D
nginx -g 'daemon off;'
