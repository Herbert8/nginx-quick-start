#!/usr/bin/env bash

THIS_SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly THIS_SCRIPT_DIR
readonly BASE_DIR=$THIS_SCRIPT_DIR

CFG_FILE=$BASE_DIR/conf/ngx.conf
WORK_DIR=$BASE_DIR/work

command_exists() {
    local cmd=${1:-}
    command -v "$cmd" >/dev/null
}

# 获取端口
PORT=$(grep listen "$CFG_FILE" | sed -nr 's/[[:space:]]+listen[[:space:]]+([0-9]+);/\1/p')

cat "$CFG_FILE" | grep -E '^[[:space:]]*listen' | column -t

# 创建检测工具执行标记，用于标记是否执行完
# 执行完的话才允许整个脚本退出，否则用于检测的任务完成后，没法显示提示符
checking_status_file=$(mktemp)
# 开始标记为 0
echo 0 >"$checking_status_file"
{
    # 等 1 秒后执行检测
    sleep 1
    printf '\n\033[92;1mService status >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\033[0m\n' >&2
    if command_exists bat; then
        curl -sSIf "http://127.0.0.1:${PORT}" | bat --theme gruvbox-dark -p
    else
        curl -sSIf "http://127.0.0.1:${PORT}"
    fi

    printf '\033[92;1m<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\033[0m\n' >&2
    # 执行后（不管成功失败）标记为 1
    echo 1 >"$checking_status_file"
} &

clean_status_file() {
    [[ -f "$checking_status_file" ]] && rm -f "$checking_status_file"
}

trap clean_status_file EXIT

if command_exists tspin; then
    openresty -p "$WORK_DIR" -c "$CFG_FILE" -g 'daemon off;' 2>&1 | tspin
else
    openresty -p "$WORK_DIR" -c "$CFG_FILE" -g 'daemon off;'
fi

while [[ $(<"$checking_status_file") != 1 ]]; do
    sleep 1
done
