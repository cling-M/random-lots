# cq —— 命令行抽签

在终端输入 `cq`，随机抽一支签，结果竖排显示，像真实签纸。

- 上上签
- 上签
- 中签
- 下签
- 下下签

**双重随机**：每次抽签前，概率本身先随机一次；再按这套随机出来的概率抽一次结果。所以不是固定比例，也不是「固定比例里的随机」，而是「随机比例里的随机」。

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

## 双重随机是怎么随机的

一次 `cq` 背后其实发生了两层随机。

### 第一层：概率先随机

抽签前先掷一个「手气值」：

```
luck = (random() + random() + random()) / 3
```

三个随机数取平均，结果集中在 0.5 附近——大多数时候手气平平，偶尔极好或极差。然后用 `luck` 生成五支签的**本次权重**：

| 签等 | 本次权重（随 luck 变化） |
| --- | --- |
| 上上签 | `luck³ × 1.2 + 0.05` |
| 上签 | `luck¹·⁵ + 0.1` |
| 中签 | `0.8`（始终有存在感） |
| 下签 | `(1-luck)¹·⁵ + 0.1` |
| 下下签 | `(1-luck)³ × 1.2 + 0.05` |

手气好，上签权重高；手气差，下签权重高。**每一签被抽中的概率，在这一步就已经变了。**

### 第二层：结果再随机

权重算好后，每支签再乘一个随机扰动：

```
weight × (0.25 + random() × 1.5)
```

模拟签筒里位置、摇动手劲的不确定性。然后按最终权重真正抽一次。

### 所以每次都是「双重随机」

1. **概率随机**：本次五支签各占多少比例，每次都不一样；
2. **结果随机**：在本次这套比例里再随机落一签。

换句话说，**没有「固定概率」这回事**。上一签抽到上上签，不代表下一签的概率还是上次那套；每一次 `cq` 都是重新定概率、重新抽。

### 长期表现

- **单次**：波动明显，可能连续出中签，也可能突然蹦出上上签或下下签；
- **长期**：因为 `luck` 对称分布在 0.5 两侧，抽很多次后五种签大致均衡，但不会精确等于 20%；
- **相邻两次**：概率互不影响，没有「垫刀」也没有「保底」。

想观察每次的真实概率，可以临时加一行日志（改 `cq.py` 的 `pick_weighted`）：

```python
print([round(w / total * 100, 1) for w in weights])
```

每次抽签都会打印本次五支签的实际百分比，能直观看到「概率本身在变」。

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
| `cq.py` | 核心抽签脚本（双重随机 + 竖排渲染） |
| `install.sh` | macOS / Linux 安装脚本 |
| `uninstall.sh` | macOS / Linux 卸载脚本 |
| `install.ps1` | Windows 安装脚本 |
| `install.bat` | Windows 一键安装入口 |
| `uninstall.ps1` | Windows 卸载脚本 |
| `uninstall.bat` | Windows 一键卸载入口 |

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

快速模式（不播放摇签动画）：

```bash
CQ_FAST=1 cq          # macOS / Linux
set CQ_FAST=1 && cq   # Windows CMD
$env:CQ_FAST=1; cq    # Windows PowerShell
```

## 卸载

### macOS / Linux

在项目目录执行：

```bash
bash uninstall.sh
```

它会：

1. 删除 `~/.local/bin/cq`；
2. 从 `~/.zshrc`、`~/.bashrc`、`~/.bash_profile`、`~/.profile` 中精确删除安装脚本写入的那一行 `export PATH="$HOME/.local/bin:$PATH"`；
3. 如果 `~/.local/bin` 已空，顺手删掉这个空目录（非空则保留）。

卸载后执行一次：

```bash
source ~/.zshrc      # 或 source ~/.bashrc
```

重开终端，输入 `cq` 应提示 `command not found`。

### Windows

在项目目录执行：

```powershell
.\uninstall.bat
```

或直接**双击 `uninstall.bat`**。

它会：

1. 删除 `%USERPROFILE%\bin\cq.py` 和 `%USERPROFILE%\bin\cq.bat`；
2. 从**用户 PATH** 中精确移除 `%USERPROFILE%\bin`，其他 PATH 项保持不变；
3. 如果 `%USERPROFILE%\bin` 已空，删除该空目录（非空则保留）。

卸载后**关闭并重新打开终端**，输入 `cq` 应提示找不到命令。

### 手动卸载（备用）

如果脚本无法运行，可以手动清理。

macOS / Linux：

```bash
rm -f ~/.local/bin/cq
# 然后编辑 ~/.zshrc 或 ~/.bashrc，删除这一行：
# export PATH="$HOME/.local/bin:$PATH"
source ~/.zshrc
```

Windows（PowerShell）：

```powershell
Remove-Item "$env:USERPROFILE\bin\cq.py" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:USERPROFILE\bin\cq.bat" -Force -ErrorAction SilentlyContinue
# 再到「系统属性 → 环境变量 → 用户变量 Path」里删除 %USERPROFILE%\bin
```

### 卸载是否彻底

脚本只删除安装时创建的文件和 PATH 项，**不会删除**：

- `~/.local/bin` 里你自己的其他程序；
- `%USERPROFILE%\bin` 里你自己的其他文件；
- 你的 shell 配置里除安装行以外的内容。

所以是「彻底删除 cq，但不误伤其他东西」。