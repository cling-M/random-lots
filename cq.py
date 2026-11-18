#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
命令行抽签：输入 cq 抽一签。
每次抽签前概率都重新随机，结果竖排显示，像真实签文。
"""
import os
import random
import sys
import time
import unicodedata

# Windows 终端输出 UTF-8，避免边框和中文乱码
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass


SIGNS = [
    ("上上签", "大吉大利，所愿皆成。"),
    ("上签",   "顺风顺水，渐入佳境。"),
    ("中签",   "平稳顺遂，静待时机。"),
    ("下签",   "小有波折，谨慎行事。"),
    ("下下签", "暂缓行动，转机在后。"),
]


def pick_weighted():
    """每次调用都重新生成一套随机权重，再按权重抽签。"""
    luck = (random.random() + random.random() + random.random()) / 3

    base = [
        luck ** 3 * 1.2 + 0.05,          # 上上签
        luck ** 1.5 + 0.1,               # 上签
        0.8,                             # 中签
        (1 - luck) ** 1.5 + 0.1,         # 下签
        (1 - luck) ** 3 * 1.2 + 0.05,    # 下下签
    ]

    weights = [b * (0.25 + random.random() * 1.5) for b in base]
    total = sum(weights)

    r = random.random() * total
    for i, w in enumerate(weights):
        r -= w
        if r <= 0:
            return SIGNS[i]
    return SIGNS[-1]


def disp_width(s):
    """按终端显示宽度计算字符串宽度（中文/全角算 2）。"""
    w = 0
    for ch in s:
        if unicodedata.east_asian_width(ch) in ("W", "F"):
            w += 2
        else:
            w += 1
    return w


def render_sign(level, text, per_col=5):
    """
    竖排渲染：
    - 从右往左读
    - 最右列是签等
    - 签文按每列 per_col 字从右往左排列
    """
    text_cols = [text[i:i + per_col] for i in range(0, len(text), per_col)]

    # 从右到左：签等 + 签文列
    cols_rtl = [level] + text_cols
    # 转成从左到右，方便逐行拼接
    cols_ltr = list(reversed(cols_rtl))

    max_len = max(len(c) for c in cols_ltr)

    lines = []
    for row in range(max_len):
        parts = []
        for col in cols_ltr:
            parts.append(col[row] if row < len(col) else "  ")
        lines.append("  ".join(parts))

    content_width = max(disp_width(l) for l in lines)
    inner_width = content_width + 2

    out = ["╭" + "─" * inner_width + "╮"]
    for l in lines:
        pad = inner_width - 1 - disp_width(l)
        out.append("│ " + l + " " * pad + "│")
    out.append("╰" + "─" * inner_width + "╯")

    return "\n".join(out)


def animate():
    """终端里加一点摇签滚动效果；非终端或 CQ_FAST=1 时跳过。"""
    if not sys.stdout.isatty() or os.environ.get("CQ_FAST") == "1":
        return
    for _ in range(8):
        level = random.choice(SIGNS)[0]
        sys.stdout.write(f"\r  摇签中... {level}   ")
        sys.stdout.flush()
        time.sleep(0.06)
    sys.stdout.write("\r" + " " * 40 + "\r")


def main():
    animate()
    level, text = pick_weighted()
    print()
    print(render_sign(level, text))
    print()


if __name__ == "__main__":
    main()