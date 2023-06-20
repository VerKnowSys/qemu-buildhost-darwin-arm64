#!/usr/bin/env sh

if [ -f "freebsd.pid" ]; then
    _pid="$(cat ./freebsd.pid)"
    echo "Stopping pid: ${_pid}"
    kill -TERM "${_pid}"
fi
