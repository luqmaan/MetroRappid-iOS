#!/bin/sh

kill -9 $(lsof -t -i :1234)
nohup python -m SimpleHTTPServer 1234 &
