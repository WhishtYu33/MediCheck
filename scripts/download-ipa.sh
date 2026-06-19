#!/bin/bash
# ============================================
# 📥 下载最新 Medicheck IPA 到桌面
# ============================================
# 用法:
#   bash scripts/download-ipa.sh
#
# 前提:
#   - 安装 GitHub CLI: winget install GitHub.cli  (Windows)
#                      brew install gh           (Mac)
#   - 登录: gh auth login
# ============================================

set -e

DESKTOP="${USERPROFILE:-$HOME}/Desktop"
REPO="MediCheck"

echo "🔍 正在查找最新的 MediCheck IPA artifact..."

# 获取最新的成功 workflow run
RUN_ID=$(gh run list --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo '')" \
  --workflow build.yml --status success --limit 1 --json databaseId -q '.[0].databaseId' 2>/dev/null)

if [ -z "$RUN_ID" ]; then
  # Fallback: 尝试获取当前仓库
  REPO_FULL=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||')
  if [ -z "$REPO_FULL" ]; then
    echo "❌ 无法确定 GitHub 仓库。请确保在仓库目录中运行此脚本。"
    echo "   或者手动从 GitHub Actions → Artifacts 下载。"
    exit 1
  fi
  RUN_ID=$(gh run list --repo "$REPO_FULL" --workflow build.yml --status success --limit 1 --json databaseId -q '.[0].databaseId')
fi

if [ -z "$RUN_ID" ]; then
  echo "❌ 找不到成功的构建。请先触发一次 CI 构建。"
  echo "   访问: https://github.com/$REPO_FULL/actions/workflows/build.yml"
  exit 1
fi

echo "✅ 找到 Build Run ID: $RUN_ID"

# 下载 artifact
echo "📥 正在下载 IPA..."

gh run download "$RUN_ID" --repo "${REPO_FULL:-$(git remote get-url origin | sed 's|.*github.com[:/]||;s|\.git$||')}" \
  --dir "$DESKTOP/MediCheck-IPA" 2>/dev/null

echo ""
echo "🎉 完成！IPA 已下载到桌面:"
echo "   $DESKTOP/MediCheck-IPA/"
ls -lh "$DESKTOP/MediCheck-IPA/" 2>/dev/null || echo "   (检查桌面上的 MediCheck-IPA 文件夹)"
