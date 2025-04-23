#!/usr/bin/env bash

THIS_SCRIPT=$(realpath "${BASH_SOURCE[0]}")
THIS_SCRIPT_DIR=$(cd "$(dirname "$THIS_SCRIPT")" && pwd)
readonly THIS_SCRIPT_DIR
readonly BASE_DIR=$THIS_SCRIPT_DIR

# --- 配置区域 ---
TEMPLATE_DIR=$BASE_DIR/template


TARGET_DIR="${1:-}"
# --- 参数校验 ---
if [[ -z "$TARGET_DIR" ]]; then
    echo "用法: ${BASH_SOURCE[0]} <目标目录>"
    exit 1
fi

# --- 检查目标目录是否存在 ---
if [[ -d "$TARGET_DIR" ]]; then
    echo "❌ 目标目录 '$TARGET_DIR' 已存在，请更换目录或删除旧目录"
    exit 2
fi

# --- 复制模板 ---
echo "📦 正在初始化项目 '$PROJECT_NAME' 到目录 '$TARGET_DIR'..."
mkdir -p "$TARGET_DIR"
cp -vR "$TEMPLATE_DIR/"* "$TARGET_DIR" | awk -F '->' '{ print $2 }'
mkdir -p "$TARGET_DIR"/work/html

# --- 设置启动脚本可执行 ---
chmod +x "$TARGET_DIR/start.sh"

echo "✅ 初始化完成。你可以运行:"
echo ""
echo "  cd $TARGET_DIR && ./start.sh"
echo ""
