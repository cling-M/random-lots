# 在 PowerShell 中运行： .\uninstall.ps1
$ErrorActionPreference = "Stop"

$InstallDir = "$env:USERPROFILE\bin"
$PyFile     = Join-Path $InstallDir "cq.py"
$BatFile    = Join-Path $InstallDir "cq.bat"

Write-Host "即将卸载 cq" -ForegroundColor Yellow
Write-Host "  文件： $PyFile"
Write-Host "  文件： $BatFile"
Write-Host "  并从用户 PATH 中移除： $InstallDir"
Write-Host ""

# 1. 删除文件
$deleted = $false
if (Test-Path $PyFile) {
    Remove-Item $PyFile -Force
    Write-Host "已删除 $PyFile" -ForegroundColor Green
    $deleted = $true
}
if (Test-Path $BatFile) {
    Remove-Item $BatFile -Force
    Write-Host "已删除 $BatFile" -ForegroundColor Green
    $deleted = $true
}
if (-not $deleted) {
    Write-Host "未找到 cq 文件（可能未安装）" -ForegroundColor Gray
}

# 2. 从用户 PATH 中移除 $InstallDir
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not [string]::IsNullOrEmpty($userPath)) {
    $target = [Environment]::ExpandEnvironmentVariables($InstallDir).TrimEnd('\').ToLower()
    $parts = $userPath -split ';' | Where-Object { $_ -ne '' }
    $kept = @()
    $removedPath = $false

    foreach ($p in $parts) {
        $expanded = [Environment]::ExpandEnvironmentVariables($p).TrimEnd('\').ToLower()
        if ($expanded -eq $target) {
            $removedPath = $true
        } else {
            $kept += $p
        }
    }

    if ($removedPath) {
        $newPath = ($kept -join ';')
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "已从用户 PATH 移除 $InstallDir" -ForegroundColor Green
    } else {
        Write-Host "用户 PATH 中没有 $InstallDir（可能已手动清理）" -ForegroundColor Gray
    }
} else {
    Write-Host "用户 PATH 为空，无需清理" -ForegroundColor Gray
}

# 3. 如果 bin 目录已空，删除它（不删非空目录，避免误伤）
if (Test-Path $InstallDir) {
    $remaining = Get-ChildItem -Force $InstallDir -ErrorAction SilentlyContinue
    if (-not $remaining) {
        Remove-Item $InstallDir -Force
        Write-Host "空目录 $InstallDir 已删除" -ForegroundColor Green
    } else {
        Write-Host "目录 $InstallDir 非空，保留（里面还有其他文件）" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "卸载完成。请关闭并重新打开终端，输入 cq 应提示找不到命令。" -ForegroundColor Cyan