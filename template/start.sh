#!/usr/bin/env bash

THIS_SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly THIS_SCRIPT_DIR
readonly BASE_DIR=$THIS_SCRIPT_DIR

CFG_FILE=$BASE_DIR/conf/ngx.conf
WORK_DIR=$BASE_DIR/work

if PORT=$(grep listen "$CFG_FILE" | sed -nr 's/[[:space:]]+listen[[:space:]]+([0-9]+);/\1/p'); then
    echo "listen $PORT;"
fi

{
    sleep 1 && curl -I "http://127.0.0.1:${PORT}"
} &

if command -v tspin >/dev/null; then
    openresty -p "$WORK_DIR" -c "$CFG_FILE" -g 'daemon off;' 2>&1 | tspin
else
    openresty -p "$WORK_DIR" -c "$CFG_FILE" -g 'daemon off;'
fi
