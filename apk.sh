#!/bin/bash

# Android 项目一键上传 GitHub 并配置 Actions 自动化构建脚本
# 使用方法: ./setup_android_gh.sh <项目目录> [仓库名称]

set -e  # 遇到错误立即退出

# 检查参数
if [ $# -lt 1 ]; then
    echo "使用方法: $0 <项目目录> [仓库名称]"
    echo "示例: $0 ~/my-android-app MyAndroidApp"
    exit 1
fi

PROJECT_DIR="$1"
REPO_NAME="${2:-$(basename "$PROJECT_DIR")}"

# 检查目录是否存在
if [ ! -d "$PROJECT_DIR" ]; then
    echo "错误: 目录 '$PROJECT_DIR' 不存在"
    exit 1
fi

# 检查是否安装了 GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "错误: 请先安装 GitHub CLI (gh)"
    echo "安装指南: https://cli.github.com/"
    exit 1
fi

# 检查是否已登录 GitHub
if ! gh auth status &> /dev/null; then
    echo "请先登录 GitHub:"
    gh auth login
fi

echo "开始设置 Android 项目自动化构建..."
cd "$PROJECT_DIR"

# 初始化 Git 仓库（如果尚未初始化）
if [ ! -d .git ]; then
    echo "初始化 Git 仓库..."
    git init
    git add .
    git commit -m "Initial commit"
else
    echo "检测到现有 Git 仓库，更新更改..."
    git add .
    git commit -m "Update before adding CI/CD" || echo "没有更改需要提交"
fi

# 创建 GitHub 仓库
echo "在 GitHub 上创建仓库 '$REPO_NAME'..."
gh repo create "$REPO_NAME" --public --push --source=. || {
    echo "仓库可能已存在，尝试推送现有仓库..."
    git push -u origin master || git push -u origin main
}

# 创建 GitHub Actions 工作流目录
mkdir -p .github/workflows

# 创建 Android CI 工作流文件
echo "创建 GitHub Actions 工作流..."
cat > .github/workflows/android-ci.yml << 'EOF'
name: Android CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      
      - name: Set up JDK 11
        uses: actions/setup-java@v3
        with:
          java-version: '11'
          distribution: 'temurin'
          
      - name: Setup Android SDK
        uses: android-actions/setup-android@v2
          
      - name: Grant Execute Permission for Gradlew
        run: chmod +x ./gradlew
          
      - name: Build with Gradle
        run: ./gradlew assembleDebug
        
      - name: Upload APK artifact
        uses: actions/upload-artifact@v3
        with:
          name: app-debug-apk
          path: app/build/outputs/apk/debug/app-debug.apk
          
      - name: Upload build reports
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: build-reports
          path: app/build/reports/
EOF

# 提交并推送工作流配置
echo "提交并推送 CI/CD 配置..."
git add .github/workflows/android-ci.yml
git commit -m "Add GitHub Actions CI/CD workflow"
git push

echo "完成！"
echo "GitHub 仓库: https://github.com/$(gh api user --jq .login)/$REPO_NAME"
echo "Actions 页面: https://github.com/$(gh api user --jq .login)/$REPO_NAME/actions"

# 打开浏览器查看仓库
read -p "是否要在浏览器中打开仓库？[y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh repo view --web
fi
