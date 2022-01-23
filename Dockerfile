FROM ubuntu
  
# Install.
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN \
  apt-get update && \
  apt-get -y upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -q -y iputils-ping && \
  apt-get install -y php-redis nginx php php-pgsql  php-gd php-curl php-fpm php-cgi php-cli php-zip  && \
  apt-get install -y postgresql-client supervisor  postgresql-client postgresql-client-common postgresql-contrib && \
  apt-get install -y telnet php-memcached php-soap php-ctype  php-zip php-simplexml  php-dom php-xml php-json php-intl php-fpm php-common php-mbstring php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-cli php-ldap php-zip php-curl libpq-dev  rsyslog  && \
  apt-get install -y net-tools memcached curl git htop man unzip vim wget
RUN apt-get install -y --no-install-recommends --no-install-suggests supervisor cron

#RUN useradd -ms /bin/bash elearning
#RUN mkdir /home/elearning/moodle
#RUN chown -R elearning:elearning /home/elearning/moodle
COPY config/cronmoodle /etc/cron.d/cronmoodle
RUN chmod 644 /etc/cron.d/cronmoodle
RUN crontab /etc/cron.d/cronmoodle
RUN mkdir /var/www/localcache
RUN chown -R www-data:www-data /var/www/localcache

WORKDIR /var/www/html
COPY sites .
RUN chown -R www-data:www-data .
#RUN mkdir /var/www/html/localcache
#RUN chown www-data:www-data /var/www/html/localcache
RUN mkdir /var/data
RUN chmod 777 -R /var/data
#RUN chown -R www-data:www-data /var/data

WORKDIR /
RUN mkdir -p /run/php
COPY config/php.ini /etc/php/7.4/fpm/php.ini
COPY config/default /etc/nginx/sites-enabled/default
COPY config/www.conf /etc/php/7.4/fpm/pool.d/www.conf


CMD ["/usr/sbin/php-fpm7.4", "-F"]
RUN phpenmod opcache
COPY config/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

CMD ["/usr/bin/supervisord"]
