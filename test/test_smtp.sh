#!/usr/bin/env bash
echo "Test: smtp server should allow authentication with correct user and pwd"
if [ ! -f /usr/bin/swaks ] ; then
    yum install -y swaks
fi

OUTPUT=$(echo eyeos | swaks --from eyeos@open365.io --to eyeos1@open365.io --server 127.0.0.1:25 --auth plain --auth-user=eyeos@open365.io 2> /dev/null)
retval=$?

if [ $retval -ne 0 ] ; then
    echo "Test failed"
    echo "========OUTPUT======="
    echo $OUTPUT
    exit 1
else
    echo "Test successful"
    exit 0
fi
