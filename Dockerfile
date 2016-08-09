FROM ubuntu:vivid
MAINTAINER Guillaume Peres  <gperes@teikhos.eu>

# Timezone
RUN echo "Europe/Paris" | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

# mise a jour et installation des paquets
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y \
    && apt-get dist-upgrade -y \
    && apt-get install -y logrotate apache2 supervisor \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

#### Apache2

# activation fast cgi
RUN /usr/sbin/a2enmod proxy
RUN /usr/sbin/a2enmod proxy_fcgi
RUN /usr/sbin/a2enmod rewrite
# site par defaut
RUN /usr/sbin/a2dissite 000-default
COPY site.conf /etc/apache2/sites-available/
RUN /usr/sbin/a2ensite site

# on met les confs de cote
RUN cp -a /etc/apache2 /root

#### supervisor
RUN sed -i '/^logfile /c logfile=/var/log/supervisor/supervisord_apache2.log' /etc/supervisor/supervisord.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#### script de lancement
COPY entrypoint /entrypoint
RUN chmod +x /entrypoint

#### partage volumes
VOLUME ["/var/log/apache2","/var/log/supervisor","/var/www/html","/etc/apache2"]

#### ports
EXPOSE 80

# dossier par défaut
WORKDIR /var/www/html

#### execution
ENTRYPOINT ["/entrypoint"]
