# MediCheck — 用药提醒

一个简洁易用的 iOS 吃药提醒 App，支持多种药品的定时提醒和服药打卡。

## 功能

- ✅ 多种药品独立管理，每种药品支持多个提醒时间
- ✅ 定时本地通知提醒吃药
- ✅ 一键打卡记录（已服/跳过），直观的圆形打卡按钮
- ✅ 今日进度环形图，一目了然
- ✅ 历史依从性日历视图 + 柱状图
- ✅ 通知横幅直接"标记已服用"
- ✅ 支持中文/英文

## 技术栈

- **SwiftUI** — 声明式 UI 框架
- **SwiftData** — 原生数据持久化
- **UserNotifications** — 本地通知
- **MVVM** 架构
- 最低支持 **iOS 16**

## 项目结构

```
MediCheck/
├── MediCheckApp.swift              # @main 入口
├── ContentView.swift               # 主 TabView
├── Models/                         # 数据模型
│   ├── Medication.swift            # 药品
│   ├── ReminderTime.swift          # 提醒时间
│   ├── MedicationRecord.swift      # 服药记录
│   └── UserSettings.swift          # 用户设置
├── ViewModels/                     # 视图模型
├── Views/                          # 视图
│   ├── Today/                      # 今天 Tab
│   ├── History/                    # 历史 Tab
│   ├── Medication/                 # 药品 CRUD
│   └── Settings/                   # 设置 Tab
├── Services/                       # 服务层
│   ├── NotificationManager.swift
│   └── RecordManager.swift
├── Extensions/                     # 扩展
└── Preview Content/                # SwiftUI 预览数据
```

## 使用方式

### 在 Mac 上运行

**方式一：XcodeGen 自动生成项目（推荐）**

```bash
brew install xcodegen
xcodegen generate
open MediCheck.xcodeproj
```

**方式二：手动创建项目**

1. 将此 `MediCheck` 文件夹复制到 Mac
2. 打开 Xcode，选择 **File → New → Project**，选择 iOS → App
3. 项目名称设为 `MediCheck`，Interface 选 **SwiftUI**，Language 选 **Swift**
4. 将本目录下的所有 `.swift` 文件拖入 Xcode 项目中（按文件夹结构分组）
5. 在 Target 的 **General** 中确保 Deployment Target 设为 **iOS 16.0**
6. 选择模拟器或真机，按 **Cmd+R** 运行

### 通知测试注意事项

- 本地通知在 **真机** 上才能正常触发
- 模拟器上通知可能延迟或无法显示
- 首次启动会请求通知权限，请选择"允许"

## 设计理念

- **简洁优先**：3 个 Tab，一目了然，无需学习
- **快速打卡**：点击打卡、长按跳过，操作直觉
- **视觉反馈**：完成状态绿色填充、过期提醒橙色脉冲
- **零学习成本**：5 分钟内完成所有药品设置

## CI / 自动构建 IPA

本项目配置了 GitHub Actions，每次推送代码后自动在 **GitHub 免费 macOS 云 Runner** 上编译并输出 IPA。

### 首次配置

1. 推送代码到 GitHub 仓库
2. 在仓库页面进入 **Settings → Secrets and variables → Actions → New repository secret**
3. 添加以下 Secret（必填）：

| Secret 名称 | 说明 |
|---|---|
| `DEVELOPMENT_TEAM` | 你的 Apple Team ID，在 [developer.apple.com/account](https://developer.apple.com/account) 查看 |
| `APPLE_ID` | （可选）Apple ID 邮箱，用于自动签名 |
| `APPLE_ID_PASSWORD` | （可选）Apple ID 专用密码 |

> 💡 即使没有付费开发者账号，免费 Apple ID 也可获得 Team ID，用于开发签名。

### 触发构建

- **自动**：推送代码到 `main` 分支
- **手动**：Actions 标签页 → **Build IPA** → **Run workflow**
- **发布**：创建 GitHub Release 时自动构建并附加 IPA

### 📥 下载 IPA 到桌面

**方式一：一键脚本**

```bash
# Windows (PowerShell)
.\scripts\download-ipa.ps1

# Mac / Git Bash
bash scripts/download-ipa.sh
```

**方式二：手动下载**

1. 打开 GitHub 仓库 → **Actions** 标签页
2. 点击最近一次成功的 **Build IPA** 运行
3. 在 **Artifacts** 区域下载 `MediCheck-*.ipa`

### 项目生成

CI 使用 [XcodeGen](https://github.com/yonaskolb/XcodeGen) 从 `project.yml` 自动生成 `.xcodeproj`。本地也可用：

```bash
brew install xcodegen
xcodegen generate
```

## 许可证

MIT License
