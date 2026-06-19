# ============================================
# 📥 下载最新 Medicheck IPA 到桌面 (Windows PowerShell)
# ============================================
# 用法:
#   .\scripts\download-ipa.ps1
#
# 前提:
#   - 安装 GitHub CLI: winget install GitHub.cli
#   - 登录: gh auth login
# ============================================

$ErrorActionPreference = "Stop"

$Desktop = [Environment]::GetFolderPath("Desktop")
$DestFolder = Join-Path $Desktop "MediCheck-IPA"

Write-Host "🔍 正在查找最新的 MediCheck IPA artifact..." -ForegroundColor Cyan

# 获取仓库信息
try {
    $repoInfo = git remote get-url origin 2>$null
    if ($repoInfo) {
        $repoFull = $repoInfo -replace '.*github.com[:/]', '' -replace '\.git$', ''
    }
} catch {
    $repoFull = $null
}

if (-not $repoFull) {
    Write-Host "❌ 无法确定 GitHub 仓库。请确保在仓库目录中运行此脚本。" -ForegroundColor Red
    Write-Host "   或者手动从 GitHub Actions → Artifacts 下载。" -ForegroundColor Yellow
    exit 1
}

# 获取最新的成功 run
$runId = gh run list --repo $repoFull --workflow build.yml --status success --limit 1 --json databaseId --jq '.[0].databaseId' 2>$null

if (-not $runId) {
    Write-Host "❌ 找不到成功的构建。请先触发一次 CI 构建。" -ForegroundColor Red
    Write-Host "   访问: https://github.com/$repoFull/actions/workflows/build.yml" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ 找到 Build Run ID: $runId" -ForegroundColor Green

# 下载 artifact
Write-Host "📥 正在下载 IPA 到桌面..." -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path $DestFolder | Out-Null
gh run download $runId --repo $repoFull --dir $DestFolder

Write-Host ""
Write-Host "🎉 完成！IPA 已下载到桌面:" -ForegroundColor Green
Write-Host "   $DestFolder" -ForegroundColor Green
Get-ChildItem $DestFolder | ForEach-Object { Write-Host "   $_" }
