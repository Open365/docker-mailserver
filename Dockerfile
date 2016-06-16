FROM docker-registry.eyeosbcn.com/alpine6-node-base

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

# add user vmail who own all mail folders
RUN \
	addgroup -g 5000 vmail && \
	adduser -G root -u 5000 -h /srv/mail -D -H vmail

RUN apk update && \
 apk add \
  postfix \
  postfix-ldap \
  postfix-mysql \
  postfix-pcre \
  postgrey \
  dovecot \
  dovecot-ldap \
  rsyslog


RUN	npm install -g --production eyeos-service-ready-notify-cli

# postfix configuration
ADD ./postfix/ /etc/postfix/
RUN echo "mail.docker.container" > /etc/mailname && \
	cat /etc/postfix/master-additional.cf >> /etc/postfix/master.cf

# dovecot configuration
ADD ./dovecot/ /etc/dovecot/

COPY ["start.sh", "services.sh", "/bin/"]

# 25: smtp port for incoming mail
# 143: imap port
# 587: smtp port for outgoing
# 993: IMAPS
EXPOSE \
	25 \
	143 \
	587 \
	993

COPY auth /opt/auth
RUN cd /opt/auth && chmod +x checkpassword.sh && npm install --production

CMD /bin/start.sh
