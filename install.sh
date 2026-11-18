#!/usr/bin/env bash
set -e

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v python3 >/dev/null 2>&1; then
  echo "错误：未找到 python3，请先安装 Python 3。"
  echo "  macOS:  brew install python"
  echo "  Ubuntu: sudo apt install python3"
  exit 1
fi

mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/cq.py" "$INSTALL_DIR/cq"
chmod +x "$INSTALL_DIR/cq"

echo "已安装到 $INSTALL_DIR/cq"

case ":$PATH:" in
  *":$INSTALL_DIR:"*)
    echo "PATH 已包含 $INSTALL_DIR，直接运行：cq"
    ;;
  *)
    SHELL_RC="$HOME/.bashrc"
    [ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"
    echo ""
    echo "请把下面这行加到 $SHELL_RC："
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "然后执行： source $SHELL_RC"
    echo "之后就可以直接输入： cq"
    ;;
esac