#!/usr/bin/env sh

if [ -f "freebsd13.pid" ]; then
    _pid="$(cat ./freebsd13.pid)"
    echo "Stopping pid: ${_pid}"
    kill -TERM "${_pid}"
fi
