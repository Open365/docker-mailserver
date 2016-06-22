#!/usr/bin/env bash

eyeos-service-ready-notify-cli &
mailPath=maildir:/mnt/rawFS/users/%d/%n/mailbox:LAYOUT=fs

sed -i 's@LDAPHOST@'$EYEOS_MAILSERVER_LDAP_URL'@g' /etc/dovecot/auth-ldap.conf.ext
sed -i 's@MANAGERDN@'$EYEOS_MAILSERVER_MANAGER_DN'@g' /etc/dovecot/auth-ldap.conf.ext
sed -i 's@MANAGERPWD@'$EYEOS_MAILSERVER_MANAGER_PWD'@g' /etc/dovecot/auth-ldap.conf.ext
sed -i 's@BASEDN@'$EYEOS_MAILSERVER_LDAP_DN'@g' /etc/dovecot/auth-ldap.conf.ext
sed -i 's@%MAIL_LOCATION%@'$mailPath'@g' /etc/dovecot/conf.d/10-mail.conf

sed -i 's@LDAPHOST@'$EYEOS_MAILSERVER_LDAP_URL'@g' /etc/postfix/ldap_virtual_recipients.cf
sed -i 's@MANAGERDN@'$EYEOS_MAILSERVER_MANAGER_DN'@g' /etc/postfix/ldap_virtual_recipients.cf
sed -i 's@MANAGERPWD@'$EYEOS_MAILSERVER_MANAGER_PWD'@g' /etc/postfix/ldap_virtual_recipients.cf
sed -i 's@BASEDN@'$EYEOS_MAILSERVER_LDAP_DN'@g' /etc/postfix/ldap_virtual_recipients.cf

sed -i 's@%USER%@'$MYSQL_MAIL_USER'@g' /etc/postfix/virtual_domains.cf
sed -i 's@%PWD%@'$MYSQL_MAIL_PWD'@g' /etc/postfix/virtual_domains.cf
sed -i 's@%DB%@'$MYSQL_MAIL_DB'@g' /etc/postfix/virtual_domains.cf
sed -i 's@%HOST%@'$MYSQL_HOST'@g' /etc/postfix/virtual_domains.cf

sed -i 's@%MAILSERVER_HOSTNAME%@'"$EYEOS_MAILSERVER_HOSTNAME"'@g' /etc/postfix/main.cf

# save container envars to a file to be able to be sourced later in a script
declare -p -x > /tmp/environment

exec eyeos-run-server --serf /bin/services.sh
