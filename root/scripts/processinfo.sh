#!/bin/sh

if [ $# -ne 1 ]; then
    echo Usage: $0 PID
    exit 1
fi

PID=$1

kill -0 $PID 2>/dev/null >/dev/null

if [ $? -eq 0 ]; then
    echo -n "--- Working Directory: "
    readlink /proc/$PID/cwd
    echo
    echo -n "--- Command line: "
    ps eho command -p $PID
    echo
    echo -n "--- Running for: "
    ps -p $PID -o etime=
    echo
    echo "--- Environment:"
    strings -f /proc/$PID/environ | cut -f2 -d ' '
    echo
    echo "--- Resource usage:"
    echo "CPU: `ps eho %cpu -p $PID`"%
    echo "MEM: `ps eho %mem -p $PID`"%
    echo
    echo "--- TCP connections:"
    netstat -pan | grep " $PID/" | grep tcp | awk ' { print "Status: "$6" local: "$4" remote: "$5; }'
    echo
    echo "--- UDP connections:"
    netstat -pan | grep " $PID/" | grep udp | awk ' { print "Local: "$4" remote: "$5; }'
    echo
    echo "--- Open files:"
    lsof -p $PID
else
    echo Process $PID does not exist
    exit 2
fi