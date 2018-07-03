FROM xtremxpert/docker-qemu-debian

MAINTAINER Benoit Vezina a.k.a. XtremXpert "benoit@xtremxpert.com"

ENV REFRESHED_AT 2018-07-01

RUN [ "cross-build-start" ]

# Update the package repository
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yqq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq wget curl

RUN mkdir -p /usr/share/man/man1 && \
	mkdir -p /usr/share/man/man7

# Added dotdeb to apt and install PHP
RUN apt-get install -y \
		php-cli \
		php \
		php-mcrypt \
		php-curl \
		php-pgsql \
		postgresql-contrib \
		phppgadmin && \
	curl -sS https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer && \
	sed -i 's/;include_path = ".:\/usr\/share\/php"/include_path = ".:\/var\/www\/library"/g' /etc/php/7.0/cli/php.ini && \
	sed -i 's/\;include_path = ".:\/usr\/share\/php"/include_path = ".:\/var\/www\/library"/g' /etc/php/7.0/apache2/php.ini && \
	a2enmod rewrite

# Fix phppgadmin
COPY ./phppgadmin.conf /etc/apache2/conf.d/phppgadmin
COPY ./config.inc.php /usr/share/phppgadmin/conf/config.inc.php

RUN sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/g' /etc/php/7.0/apache2/php.ini
# Clean image
RUN apt-get -yqq clean && \
	apt-get -yqq purge && \
	rm -rf /tmp/* /var/tmp/* && \
	rm -rf /var/lib/apt/lists/*

# Set Apache environment variables (can be changed on docker run with -e)
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV POSTGRES_DEFAULTDB defaultdb
ENV POSTGRES_HOST db
ENV POSTGRES_PORT 5432

EXPOSE 80

COPY start.sh /start.sh

CMD ["bash", "start.sh"]

RUN [ "cross-build-end" ]
