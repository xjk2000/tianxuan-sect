# 变更日志

本文档记录天玄宗插件的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.0.0] - 2026-03-28

### 新增
- ✨ 初始版本发布
- 🎯 6个专业 Agent：宗主、藏经阁长老、丹堂长老、阵堂长老、器堂长老、执法堂长老
- 📝 5个核心 Skill：
  - tianxuan-brainstorming - 需求探索
  - tianxuan-藏经阁优先 - 知识优先
  - tianxuan-self-review - 自检
  - tianxuan-two-stage-review - 两阶段审查
  - tianxuan-systematic-debugging - 系统化调试
- 🔧 3个管理 Command：
  - /init-tianxuan - 初始化项目
  - /task-status - 查看任务状态
  - /archive-task - 归档任务
- 📚 藏经阁知识管理机制
- 🔒 HARD-GATE 质量门槛
- 🚫 No Placeholders 原则
- 🔄 隔离上下文传递
- 📊 任务状态追踪（.task-status.json）
- 🪝 SessionStart hook

### 文档
- 📖 完整的 README.md
- 📦 详细的 INSTALL.md
- 🏗️ PLUGIN_STRUCTURE.md 结构验证文档

### 技术特性
- ⚙️ 完全配置驱动（.tianxuan.config.json）
- 🌐 技术栈无关
- 🔄 模型可配置（primary + fallbacks）
- 📝 完整的 frontmatter 配置
- ✅ 符合 Claude Code 官方插件规范

## [未来计划]

### 计划新增
- [ ] 更多 Skills
  - [ ] tianxuan-git-workflow - Git 工作流
  - [ ] tianxuan-code-review - 代码审查
  - [ ] tianxuan-documentation - 文档生成
- [ ] 更多 Commands
  - [ ] /create-task - 手动创建任务
  - [ ] /list-knowledge - 列出藏经阁知识
- [ ] 测试套件
- [ ] CI/CD 集成
- [ ] 多语言支持（英文文档）

### 计划改进
- [ ] 性能优化
- [ ] 错误处理增强
- [ ] 更详细的文档
- [ ] 示例项目

---

**格式说明**:
- `新增` - 新功能
- `变更` - 现有功能的变更
- `弃用` - 即将移除的功能
- `移除` - 已移除的功能
- `修复` - Bug 修复
- `安全` - 安全相关的修复
