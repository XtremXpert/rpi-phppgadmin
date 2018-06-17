# phppgadmin in a container
#
# docker run -rm -i -d \
#       -p 80 \
#       -e APACHE_SERVERNAME=jacksoncage.se  \
#       -e POSTGRES_HOST=localhost \
#       -e POSTGRES_PORT=5432 \
#       -v /etc/localtime:/etc/localtime \
#       jacksoncage/phppgadmin

FROM        arm32v7/debian:jessie
MAINTAINER  Benoit Vezina a.k.a. XtremXpert "benoit@xtremxpert.com"
ENV         REFRESHED_AT 2018-06-17

# Update the package repository
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yqq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq wget curl

# Added dotdeb to apt and install PHP
RUN apt-get install -y \
		php5-cli \
		php5 \
		php5-mcrypt \
		php5-curl \
		php5-pgsql 
		postgresql-contrib \
		phppgadmin && \
	curl -sS https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer && \
	sed -i 's/;include_path = ".:\/usr\/share\/php"/include_path = ".:\/var\/www\/library"/g' /etc/php5/cli/php.ini && \
	sed -i 's/\;include_path = ".:\/usr\/share\/php"/include_path = ".:\/var\/www\/library"/g' /etc/php5/apache2/php.ini && \
	a2enmod rewrite

# Fix phppgadmin
COPY ./phppgadmin.conf /etc/apache2/conf.d/phppgadmin
COPY ./config.inc.php /usr/share/phppgadmin/conf/config.inc.php

RUN sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/g' /etc/php5/apache2/php.ini

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
