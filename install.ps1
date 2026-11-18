# 在 PowerShell 中运行： .\install.ps1
$ErrorActionPreference = "Stop"

$InstallDir = "$env:USERPROFILE\bin"
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path

$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) {
    $py = Get-Command py -ErrorAction SilentlyContinue
}
if (-not $py) {
    Write-Host "错误：未找到 python，请先安装 Python 3 并勾选 Add to PATH。" -ForegroundColor Red
    Write-Host "下载： https://www.python.org/downloads/windows/"
    exit 1
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item "$ScriptDir\cq.py" "$InstallDir\cq.py" -Force

# cq.bat 包装，顺便切 UTF-8，保证边框和中文正常
$bat = @"
@echo off
chcp 65001 >nul
python "%~dp0cq.py" %*
"@
Set-Content -Path "$InstallDir\cq.bat" -Value $bat -Encoding ASCII

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$InstallDir*") {
    if ([string]::IsNullOrEmpty($userPath)) {
        $newPath = $InstallDir
    } else {
        $newPath = "$userPath;$InstallDir"
    }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "已把 $InstallDir 加入用户 PATH。" -ForegroundColor Green
    Write-Host "请关闭并重新打开终端，然后输入： cq"
} else {
    Write-Host "PATH 已包含 $InstallDir，直接输入： cq" -ForegroundColor Green
}

Write-Host "安装完成： $InstallDir\cq.bat"