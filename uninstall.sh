#!/usr/bin/env bash
set -e

INSTALL_DIR="$HOME/.local/bin"
BIN="$INSTALL_DIR/cq"

echo "即将卸载 cq"
echo "  可执行文件： $BIN"
echo "  同时清理 shell 配置里的 PATH 行"
echo ""

# 1. 删除可执行文件
if [ -f "$BIN" ]; then
  rm -f "$BIN"
  echo "已删除 $BIN"
else
  echo "未找到 $BIN（可能未安装）"
fi

# 2. 从 shell 配置里删除安装脚本写入的那一行
LINE='export PATH="$HOME/.local/bin:$PATH"'
REMOVED=0
for RC in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
  if [ -f "$RC" ] && grep -Fqx "$LINE" "$RC"; then
    # 用临时文件重写，兼容 macOS 的 sed
    TMP="$(mktemp)"
    grep -Fvx "$LINE" "$RC" > "$TMP"
    mv "$TMP" "$RC"
    echo "已从 $RC 删除 PATH 行"
    REMOVED=1
  fi
done

if [ "$REMOVED" -eq 0 ]; then
  echo "未在 shell 配置里找到安装脚本写入的 PATH 行（可能已手动清理过）"
fi

# 3. 如果 ~/.local/bin 已空，可选删除（不强制）
if [ -d "$INSTALL_DIR" ] && [ -z "$(ls -A "$INSTALL_DIR")" ]; then
  rmdir "$INSTALL_DIR" 2>/dev/null && echo "空目录 $INSTALL_DIR 已删除" || true
fi

echo ""
echo "卸载完成。请执行 source ~/.zshrc 或 source ~/.bashrc 让 PATH 改动生效，"
echo "然后重开终端，输入 cq 应提示 command not found。"