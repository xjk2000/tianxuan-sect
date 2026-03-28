# 贡献指南

感谢你考虑为天玄宗项目做出贡献！

## 如何贡献

### 报告 Bug

如果你发现了 Bug，请在 GitHub Issues 中创建一个新的 issue，并包含：

1. **清晰的标题** - 简洁描述问题
2. **重现步骤** - 详细的步骤说明
3. **预期行为** - 你期望发生什么
4. **实际行为** - 实际发生了什么
5. **环境信息** - Claude Code 版本、操作系统等
6. **截图/日志** - 如果适用

### 建议新功能

如果你有新功能的想法：

1. 先检查 Issues 中是否已有类似建议
2. 创建一个新的 Feature Request issue
3. 详细描述功能的用途和价值
4. 如果可能，提供使用示例

### 提交代码

1. **Fork 项目**
   ```bash
   git clone https://github.com/xjk2000/tianxuan-sect.git
   cd tianxuan-sect
   ```

2. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/your-bug-fix
   ```

3. **进行修改**
   - 遵循现有代码风格
   - 添加必要的注释
   - 更新相关文档

4. **测试修改**
   - 确保插件能正常加载
   - 测试相关功能
   - 验证不会破坏现有功能

5. **提交修改**
   ```bash
   git add .
   git commit -m "feat: 添加新功能描述"
   # 或
   git commit -m "fix: 修复Bug描述"
   ```

   提交信息格式：
   - `feat:` - 新功能
   - `fix:` - Bug 修复
   - `docs:` - 文档更新
   - `style:` - 代码格式调整
   - `refactor:` - 重构
   - `test:` - 测试相关
   - `chore:` - 构建/工具相关

6. **推送到 GitHub**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **创建 Pull Request**
   - 在 GitHub 上创建 PR
   - 填写 PR 模板
   - 等待代码审查

## 代码规范

### Agent 文件

- 必须包含正确的 frontmatter
- 描述要清晰明确
- 工具列表要准确
- 模型配置要合理

示例：
```markdown
---
name: 示例Agent
description: 清晰的描述
tools: Read, Write, Edit
model: sonnet
effort: medium
maxTurns: 20
---

# Agent 内容
```

### Skill 文件

- 必须包含 `SKILL.md` 文件
- 必须有正确的 frontmatter
- 描述要详细，包含使用场景
- 提供清晰的执行流程

### Command 文件

- 必须包含正确的 frontmatter
- 提供详细的执行步骤
- 包含使用示例
- 说明注意事项

### 文档

- 使用清晰的中文
- 代码示例要完整可运行
- 保持格式一致
- 更新相关的 CHANGELOG.md

## 开发环境设置

1. **安装插件到本地**
   ```bash
   /plugin install /path/to/claudecode-xiuxian
   ```

2. **测试修改**
   ```bash
   # 重新加载插件
   /plugin disable tianxuan-sect
   /plugin enable tianxuan-sect
   
   # 或重启 Claude Code
   ```

3. **验证功能**
   ```bash
   /agents  # 查看 agents
   /help    # 查看 commands
   ```

## 审查流程

1. 提交 PR 后，维护者会进行代码审查
2. 可能会要求修改
3. 所有讨论解决后，PR 会被合并
4. 你的贡献会在 CHANGELOG.md 中记录

## 行为准则

请阅读并遵守我们的 [行为准则](CODE_OF_CONDUCT.md)。

## 许可证

通过贡献代码，你同意你的贡献将在 MIT 许可证下授权。

## 问题？

如有任何问题，请：
- 创建 GitHub Issue
- 发送邮件到 [email protected]

感谢你的贡献！🎉
