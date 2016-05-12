#!/usr/bin/env bash
service rsyslog start
service postgrey start
service postfix start
dovecot
tailf /var/log/mail.log
