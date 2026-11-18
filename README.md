# cq —— 命令行抽签

在终端输入 `cq`，随机抽一支签，结果竖排显示，像真实签纸。

- 上上签
- 上签
- 中签
- 下签
- 下下签

每次抽签前都会重新随机生成一整套概率，不是固定比例。

## 效果

```bash
$ cq

╭────────────╮
│ 所  大  上 │
│ 愿  吉  上 │
│ 皆  大  签 │
│ 成  利    │
│ 。  ，    │
╰────────────╯
```

竖排从右往左读：**上上签 → 大吉大利，→ 所愿皆成。**

想跳过摇签动画：

```bash
CQ_FAST=1 cq
```

## 依赖

- Python 3

检查：

```bash
python3 --version    # macOS / Linux
python --version     # Windows
```

没有的话：

- macOS：`brew install python`
- Ubuntu / Debian：`sudo apt install python3`
- Windows：https://www.python.org/downloads/windows/ ，安装时勾选 **Add Python to PATH**

## 文件说明

| 文件 | 用途 |
| --- | --- |
| `cq.py` | 核心抽签脚本 |
| `install.sh` | macOS / Linux 安装脚本 |
| `install.ps1` | Windows 安装脚本 |
| `install.bat` | Windows 一键安装入口 |

## 安装

### macOS

进入本目录后执行：

```bash
bash install.sh
```

如果提示 PATH 未包含，执行一次：

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Linux

进入本目录后执行：

```bash
bash install.sh
```

如果提示 PATH 未包含，执行一次：

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Windows

在 PowerShell 或 CMD 中进入本目录，执行：

```powershell
.\install.bat
```

或者直接**双击 `install.bat`**。

安装完成后**关闭并重新打开终端**，然后输入 `cq`。

## 使用

任意目录输入：

```bash
cq
```

快速模式：

```bash
CQ_FAST=1 cq          # macOS / Linux
set CQ_FAST=1 && cq   # Windows CMD
$env:CQ_FAST=1; cq    # Windows PowerShell
```

## 概率说明

不是固定 20%。每次抽签前：

1. 随机一个「手气值」`luck`（三个随机数取平均，集中在 0.5 附近）；
2. 按 `luck` 生成五支签的初始权重：手气好上签权重高，手气差下签权重高，中签始终有存在感；
3. 每支签再乘一个随机扰动，模拟签筒位置、摇动手劲的不确定性；
4. 按本次权重抽取。

所以每次概率都在变，长期大致均衡，单次波动明显。

## 卸载

### macOS / Linux

```bash
rm -f ~/.local/bin/cq
```

再把 `~/.zshrc` 或 `~/.bashrc` 里这一行删掉（如果加过）：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Windows

```powershell
Remove-Item "$env:USERPROFILE\bin\cq.py" -Force
Remove-Item "$env:USERPROFILE\bin\cq.bat" -Force
```

再把 `%USERPROFILE%\bin` 从用户 PATH 中移除（系统设置 → 环境变量 → 用户变量 Path）。