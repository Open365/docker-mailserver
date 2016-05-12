#!/usr/bin/env bash
echo "Test: IMAP server should allow auth with correct user and pwd"
python3 test_imap.py
retval=$?

if [ $retval -ne 0 ] ; then
    echo "Test failed"
    exit 1
else
    echo "Test successful"
    exit 0
fi
