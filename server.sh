#!/bin/sh

port=1234
runningServerPid=$(lsof -t -i :$port)

if [ -n "${runningServerPid-}" ]; then
    echo "killing server with pid $runningServerPid"
    kill -9 $runningServerPid
fi

echo "running new server on $port"
nohup python -m SimpleHTTPServer $port &
