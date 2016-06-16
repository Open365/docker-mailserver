FROM ubuntu:14.04

ENV \
	DEBIAN_FRONTEND=noninteractive \
	WHATAMI=mailserver \
	EYEOS_MAILSERVER_LDAP_URL=ldap://ldap.service.consul \
	EYEOS_MAILSERVER_LDAP_DN=ou=People,dc=eyeos,dc=com \
	EYEOS_MAILSERVER_MANAGER_DN=cn=Manager,dc=eyeos,dc=com \
	EYEOS_MAILSERVER_MANAGER_PWD=manager \
	MYSQL_MAIL_USER=mail \
	MYSQL_MAIL_PWD=supersecret \
	MYSQL_MAIL_DB=mail \
	MYSQL_HOST=mysql.service.consul

COPY apt-sources.list /etc/apt/sources.list

RUN locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales

RUN apt-get update && \
    apt-get install -y --force-yes ssl-cert postfix postfix-pcre postfix-ldap postgrey dovecot-imapd dovecot-ldap \
                                   nodejs-legacy npm curl build-essential unzip git rsyslog dnsmasq postfix-mysql && \
    apt-get -y -q autoclean && \
    apt-get -y -q autoremove && \
    apt-get clean

RUN curl -sL https://deb.nodesource.com/setup_0.10 | bash -
RUN curl -L https://releases.hashicorp.com/serf/0.6.4/serf_0.6.4_linux_amd64.zip -o serf.zip && \
	unzip serf.zip && \
	mv serf /usr/bin/serf && \
	npm install -g npm@2.14.4

RUN	npm install -g eyeos-run-server eyeos-tags-to-dns eyeos-service-ready-notify-cli

# postfix configuration
RUN echo "mail.docker.container" > /etc/mailname
ADD ./postfix.main.cf /etc/postfix/main.cf
ADD ./postfix.login_maps.pcre /etc/postfix/login_maps.pcre
ADD ./postfix.master.cf.append /etc/postfix/master-additional.cf
RUN cat /etc/postfix/master-additional.cf >> /etc/postfix/master.cf

# configure mail delivery to dovecot
ADD ./virtual_domains /etc/postfix/virtual_domains.cf
ADD ./ldap_virtual_recipients.cf /etc/postfix/ldap_virtual_recipients.cf

# add user vmail who own all mail folders
RUN groupadd -g 5000 vmail
RUN useradd -g root -u 5000 vmail -d /srv/vmail -m

# dovecot configuration
ADD ./dovecot.mail /etc/dovecot/conf.d/10-mail.conf
ADD ./dovecot.ssl /etc/dovecot/conf.d/10-ssl.conf
ADD ./dovecot.auth /etc/dovecot/conf.d/10-auth.conf
ADD ./dovecot.master /etc/dovecot/conf.d/10-master.conf
ADD ./dovecot.lda /etc/dovecot/conf.d/15-lda.conf
ADD ./dovecot.imap /etc/dovecot/conf.d/20-imap.conf
ADD ./auth-ldap.conf /etc/dovecot/auth-ldap.conf.ext
# add verbose logging
ADD ./dovecot.logging /etc/dovecot/conf.d/10-logging.conf

COPY start.sh /bin/start.sh
RUN chmod +x /bin/start.sh
COPY services.sh /bin/services.sh
RUN chmod +x /bin/services.sh

# smtp port for incoming mail
EXPOSE 25 
# imap port
EXPOSE 143
# smtp port for outgoing
EXPOSE 587
#IMAPS
EXPOSE 993

COPY auth /opt/auth
RUN cd /opt/auth && chmod +x checkpassword.sh && npm install --production

CMD /bin/start.sh
