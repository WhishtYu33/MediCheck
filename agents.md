# MediCheck 项目 Agents & Skills 参考

> 自动生成于 2026-06-23。列出当前环境中所有可用的 Agent 子类型、全局/项目级 Skills、以及已安装插件中的 Agent。

---

## 一、内置 Agent 子类型（系统级）

这些 Agent 由 Claude Code 运行时内置，无需额外安装。在 `Agent` 工具中通过 `subagent_type` 调用。

| Agent | 说明 | 适用场景 |
|-------|------|---------|
| **claude** | 通用万能 Agent，无特定类别 | 任何不匹配其他专用 Agent 的任务 |
| **general-purpose** | 通用复杂任务 Agent | 搜索、研究、多步骤操作 |
| **Explore** | 只读搜索 Agent（快速） | 按文件模式查找、grep 符号、定位定义 |
| **Plan** | 软件架构设计 Agent | 设计实现计划、识别关键文件、权衡架构方案 |
| **claude-code-guide** | Claude Code 问答 Agent | "Claude 能...?"、"怎么做...?" 类问题 |
| **statusline-setup** | 状态栏配置 Agent | 配置用户的状态栏显示 |

---

## 二、全局用户技能（`~/.claude/skills/`）

以下技能存储在用户 `.claude/skills/` 目录中，可跨项目使用。匹配时通过 `Skill` 工具自动加载。

### 核心工作技能

| 技能 | 路径 | 说明 |
|------|------|------|
| **core-deploy** | `~/.claude/skills/core-deploy/` | 自动匹配项目结构、生成部署配置、执行部署流程 |
| **code-review** | `~/.claude/skills/code-review/` | 检查 diff 中的 bug、重复代码、简化机会和效率问题 |
| **simplify-code** | `~/.claude/skills/simplify-code/` | 重构冗余代码、提取公共逻辑、提升可读性 |
| **test-gen** | `~/.claude/skills/test-gen/` | 自动为现有代码生成单元测试和集成测试 |
| **playwright-skill** | `~/.claude/skills/playwright-skill/` | 完整浏览器自动化，支持 Playwright，自动检测 dev server |
| **web-access** | `~/.claude/skills/web-access/` | 所有联网操作统一入口：搜索、网页抓取、登录后操作、浏览器 CDP |

### Superpowers 开发方法论技能

全部位于 `~/.claude/skills/superpowers/` 下，提供完整的开发流程约束。

| 技能 | 说明 |
|------|------|
| **using-superpowers** | 会话启动时自动加载，管理所有 Superpowers 技能的发现和调用 |
| **brainstorming** | 任何创造性工作前强制使用：探索用户意图、需求和设计 |
| **writing-plans** | 有规格或需求时，在写代码前先编写实现计划 |
| **executing-plans** | 在独立会话中执行已写好的实现计划 |
| **subagent-driven-development** | 使用独立子 Agent 执行实现计划的每个任务，每个任务后做 review |
| **dispatching-parallel-agents** | 面对多个独立任务时并行派发子 Agent |
| **test-driven-development** | 新功能/修 bug/重构前先写测试，Red-Green-Refactor 循环 |
| **systematic-debugging** | 遇到任何 bug 或测试失败时，系统性找根因（4 阶段） |
| **verification-before-completion** | 声称完成前必须先运行验证命令获得证据 |
| **requesting-code-review** | 完成任务/主要功能/合并前请求代码审查 |
| **receiving-code-review** | 接收代码审查反馈时的技术性处理流程 |
| **finishing-a-development-branch** | 实现完成且所有测试通过后，引导合并/PR/清理流程 |
| **using-git-worktrees** | 启动功能工作时确保工作空间隔离 |
| **writing-skills** | 创建/编辑/验证技能（TDD 方法应用于文档） |

---

## 三、系统可用技能（运行时注册）

这些技能通过系统提示中的 `<skill>` 列表注册，可通过 `Skill` 工具直接调用。

| 技能 | 说明 |
|------|------|
| **code-review** | 代码审查 — 检查 diff 中的 bug、重复代码、简化机会 |
| **core-deploy** | 核心部署 — 自动匹配项目结构、生成部署配置、执行部署 |
| **playwright-skill** | 浏览器自动化 — Playwright 驱动，自动检测 dev server |
| **simplify-code** | 代码简化 — 重构冗余代码、提取公共逻辑、提升可读性 |
| **test-gen** | 测试生成 — 自动生成单元测试和集成测试 |
| **web-access** | 联网操作 — 搜索、网页抓取、登录后操作等所有网络交互 |
| **deep-research** | 深度调研 — 多源搜索、对抗验证、综合引用报告 |
| **verify** | 验证代码变更是否按预期工作（运行应用并观察行为） |
| **simplify** | 审查变更代码的复用/简化/效率/高层次清理 |
| **update-config** | 配置 settings.json（权限、环境变量、hooks 等） |
| **keybindings-help** | 自定义键盘快捷键 |
| **loop** | 定时循环运行命令或提示词 |
| **claude-api** | Claude API / Anthropic SDK 参考（定价、参数、流式等） |
| **run** | 启动并驱动项目的应用查看变更效果 |
| **init** | 初始化新的 CLAUDE.md 文件 |
| **review** | 审查 Pull Request |
| **security-review** | 对当前分支的变更进行安全审查 |
| **fewer-permission-prompts** | 扫描历史记录生成权限白名单以减少权限提示 |

---

## 四、已安装插件中的 Agent

插件安装于 `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/`。

### agent-sdk-dev

| Agent | 说明 |
|-------|------|
| **agent-sdk-verifier-py** | 验证 Python Agent SDK 实现 |
| **agent-sdk-verifier-ts** | 验证 TypeScript Agent SDK 实现 |

### code-modernization

| Agent | 说明 |
|-------|------|
| **architecture-critic** | 架构批评者 — 审查现代化过程中的架构决策 |
| **business-rules-extractor** | 业务规则提取器 — 从遗留代码中提取业务逻辑 |
| **legacy-analyst** | 遗留代码分析师 — 分析和理解遗留系统 |
| **scaffolder** | 脚手架生成器 — 为新代码生成项目结构 |
| **security-auditor** | 安全审计员 — 检查安全漏洞 |
| **test-engineer** | 测试工程师 — 为现代化代码编写测试 |
| **version-delta-analyst** | 版本差异分析师 — 分析版本间的变更 |

### code-simplifier

| Agent | 说明 |
|-------|------|
| **code-simplifier** | 代码简化器 — 识别并消除重复/冗余代码 |

### feature-dev

| Agent | 说明 |
|-------|------|
| **code-architect** | 代码架构师 — 设计功能架构 |
| **code-explorer** | 代码探索器 — 搜索和分析代码库 |
| **code-reviewer** | 代码审查器 — 审查功能代码质量 |

### hookify

| Agent | 说明 |
|-------|------|
| **conversation-analyzer** | 对话分析器 — 分析对话以建议 hooks |

### plugin-dev

| Agent | 说明 |
|-------|------|
| **agent-creator** | Agent 创建器 — 创建新的 Agent 定义 |
| **plugin-validator** | 插件验证器 — 验证插件结构和清单 |
| **skill-reviewer** | 技能审查器 — 审查技能文档质量 |

### pr-review-toolkit

| Agent | 说明 |
|-------|------|
| **code-reviewer** | 代码审查器 — 全面审查 PR 变更 |
| **code-simplifier** | 代码简化器 — 发现 PR 中的简化机会 |
| **comment-analyzer** | 评论分析器 — 分析 PR 中的评论和反馈 |
| **pr-test-analyzer** | PR 测试分析器 — 评估 PR 中的测试覆盖 |
| **silent-failure-hunter** | 静默故障猎人 — 发现潜在的静默失败点 |
| **type-design-analyzer** | 类型设计分析器 — 审查类型系统设计 |

### skill-creator (嵌套技能内的 Agent)

| Agent | 说明 |
|-------|------|
| **analyzer** | 分析器 — 分析技能需求 |
| **comparator** | 比较器 — 比较不同实现方案 |
| **grader** | 评分器 — 评估技能文档质量 |

---

## 五、使用指南

### 调用 Agent

```
Agent({ subagent_type: "Explore", description: "...", prompt: "..." })
Agent({ subagent_type: "general-purpose", description: "...", prompt: "..." })
Agent({ subagent_type: "Plan", description: "...", prompt: "..." })
```

### 调用 Skill

```
Skill({ skill: "code-review" })
Skill({ skill: "test-gen" })
Skill({ skill: "web-access" })
```

### Superpowers 工作流

```
brainstorming → writing-plans → subagent-driven-development → verification-before-completion → requesting-code-review → finishing-a-development-branch
```

### 自动化技能触发

根据 `~/.claude/CLAUDE.md` 全局规则，匹配场景下会自动加载对应技能，无需手动调用：

- 部署相关 → `core-deploy`
- 代码审查 → `code-review`
- 代码简化 → `simplify-code`
- 测试生成 → `test-gen`
