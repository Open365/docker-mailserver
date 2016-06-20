#!/usr/bin/env bash
THISDIR="$(cd "$(dirname "$0")" && pwd)"

echo "Test: IMAP server should allow auth with correct user and pwd"
python3 "$THISDIR/test_imap.py"
retval=$?

if [ $retval -ne 0 ] ; then
    echo "Test failed"
    exit 1
else
    echo "Test successful"
    exit 0
fi
