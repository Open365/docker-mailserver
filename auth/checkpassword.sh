#!/bin/bash

# The first and only argument is path to checkpassword-reply binary.
# It should be executed at the end if authentication succeeds.
CHECKPASSWORD_REPLY_BINARY="$1"

# Messages to stderr will end up in mail log (prefixed with "dovecot: auth: Error:")
LOG=/dev/stderr

# User and password will be supplied on file descriptor 3.
INPUT_FD=3

# Error return codes.
ERR_PERMFAIL=1
ERR_NOUSER=3
ERR_TEMPFAIL=111

# Credentials verification function. Given a user name and password it should output non-empty
# string (this implementation outputs 'user:password') in case supplied credentials are valid
# or nothing if they are not. Return non-zero code in case of error.
credentials_verify()
{
	local user="$1"
	local pass="$2"

	if /opt/auth/index.js $pass &> /tmp/password.node.log; then
		echo "TRUE"
	fi
}

# Read input data. It is available from $INPUT_FD as "${USER}\0${PASS}\0".
# Password may be empty if not available (i.e. if doing credentials lookup).
read -d $'\0' -r -u $INPUT_FD USER
read -d $'\0' -r -u $INPUT_FD PASS

export USER="`echo \"$USER\" | tr 'A-Z' 'a-z'`"
export HOME="/mnt/rawFS/users/$USER/mailbox/"

lookup_result=`credentials_verify "$USER" "$PASS"` || {
	# If it failed, consider it an internal temporary error.
	# This usually happens due to permission problems.
	exit $ERR_TEMPFAIL
}

if [ -n "$lookup_result" ]; then
	# At the end of successful authentication execute checkpassword-reply binary.
	exec $CHECKPASSWORD_REPLY_BINARY
else
	# If matching credentials were not found, return proper error code depending on lookup mode.
	if [ "$AUTHORIZED" = 1 -a "$CREDENTIALS_LOOKUP" = 1 ]; then
		exit $ERR_NOUSER
	else
		exit $ERR_PERMFAIL
	fi
fi
