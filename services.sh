#!/usr/bin/env bash

/usr/sbin/rsyslogd
/usr/sbin/postgrey \
	--inet=127.0.0.1:10030 \
	--daemonize \
	--delay=300 \
	--greylist-text="Greylisted for %s seconds"
/usr/sbin/postfix start
/usr/sbin/dovecot
tail -F /var/log/maillog
