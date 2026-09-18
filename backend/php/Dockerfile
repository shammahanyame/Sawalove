# SawaLove PHP API — production container.
# PHP 8.3 served by Apache, document root at public/ (only entry point is
# public/index.php; src/, schema, and env files are never web-readable).
FROM php:8.3-apache

# Required PHP extensions. curl/openssl/json are compiled into the base image.
RUN docker-php-ext-install pdo_mysql

# Serve the API from public/ so src/ and .env are unreachable over HTTP.
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Send Apache logs to the container stdout/stderr so App Platform shows them.
RUN sed -ri -e 's!CustomLog \S+!CustomLog /proc/self/fd/1 combined!g; s!ErrorLog \S+!ErrorLog /proc/self/fd/2!g' \
    /etc/apache2/conf-available/*.conf || true

# Copy the application source.
COPY public/ /var/www/html/public/
COPY src/ /var/www/html/src/

# Uploaded photos need a writable location.
# SECURITY: the app writes a .htaccess into this dir at runtime, but the base
# image sets AllowOverride None, which would silently ignore it. The same
# rules are therefore baked into the vhost here so they are ALWAYS honored:
# uploads may only ever be served as static files, never executed.
RUN mkdir -p /var/www/html/public/uploads/profile-photos \
    && printf '%s\n' \
        '# Uploaded images must never execute as code.' \
        '<FilesMatch "\.(php|phtml|php3|php4|php5|php7|phps|phar|pl|py|cgi|sh|asp|aspx|jsp)$">' \
        'Require all denied' \
        '</FilesMatch>' \
        'php_flag engine off' \
        'Options -Indexes -ExecCGI' \
        > /etc/apache2/conf-available/sawalove-uploads.conf \
    && a2enconf sawalove-uploads \
    && a2enmod headers \
    && chown -R www-data:www-data /var/www/html/public/uploads

ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data

EXPOSE 8080

# App Platform routes HTTP to 8080; Apache in the image listens on 80 by
# default, so remap via ports.conf.
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/:80>/:8080>/' /etc/apache2/sites-available/000-default.conf

# Health checks hit /health inside the container.
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD php -r 'exit(strpos(@file_get_contents("http://127.0.0.1:8080/health"), "\"ok\":true") !== false ? 0 : 1);'
