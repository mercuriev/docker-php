FROM php:8.1-cli-buster

RUN apt-get update \ 
	&& apt-get install -y unzip git zlib1g-dev libzip-dev supervisor lighttpd \
	&& docker-php-ext-install pdo_mysql bcmath zip \
	&& pecl install xdebug && docker-php-ext-enable xdebug \
 	&& apt-get clean

ADD https://getcomposer.org/composer-stable.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

RUN lighttpd-enable-mod rewrite fastcgi-php
# configured in lighttpd.conf so that tracked in git
RUN rm -v /etc/lighttpd/conf-enabled/15-fastcgi-php.conf
RUN echo 'url.rewrite-if-not-file = ( "/\??(.*)$" => "/index.php?$1", )' >> /etc/lighttpd/conf-enabled/10-rewrite.conf
RUN mkdir /var/run/lighttpd && chown www-data: /var/run/lighttpd
# because /dev/stdout is owned by root
RUN mkfifo -m 600 /tmp/stdout && chown www-data: /tmp/stdout

COPY php.ini /usr/local/etc/php/conf.d/app.ini
COPY lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf

CMD ["supervisord"]
WORKDIR "/srv"
EXPOSE 80
