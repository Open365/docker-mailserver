#!/usr/bin/env bash

finish_everything() {
	echo "Stopping everything..." >&2
	set -x
	/usr/sbin/postfix stop
	dovecot stop
	pgrep rsyslogd | xargs -r kill
	pgrep postgrey | xargs -r kill

	kill "$TAILPID"
}

trap finish_everything TERM INT

/usr/sbin/rsyslogd
/usr/sbin/postgrey \
	--inet=127.0.0.1:10030 \
	--daemonize \
	--delay=300 \
	--greylist-text="Greylisted for %s seconds"
/usr/sbin/postfix start
/usr/sbin/dovecot
tail -F /var/log/maillog &
TAILPID="$!"

# wait causes this script to block until a background process finishes.
# The only background process here is tail -F, which will never finish.
# We do this `wait` thing instead of leaving `tail -F` in the foreground
# because wait is a builtin command and it processes signals, while if we are
# running an external command we won't process signals until the command
# returns
wait
