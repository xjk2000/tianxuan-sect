# 天玄宗插件安装指南

## 安装方式

### 方式 1: 从本地路径安装（开发测试）

```bash
# 在 Claude Code 中执行
/plugin install /Users/x/Projects/my-project/claudecode-xiuxian
```

### 方式 2: 从 Git 仓库安装（推荐）

```bash
# 从 GitHub 安装
/plugin install https://github.com/xjk2000/tianxuan-sect

# 或使用 Git URL
/plugin install git@github.com:xjk2000/tianxuan-sect.git
```

### 方式 3: 通过市场安装（未来）

待插件提交到官方市场后，可通过市场界面安装。

## 验证安装

安装成功后，执行以下命令验证：

```bash
# 查看已安装的插件
/plugin list

# 查看可用的 agents
/agents

# 查看可用的 commands
/help
```

你应该能看到：
- **Agents**: 宗主、藏经阁长老、丹堂长老、阵堂长老、器堂长老、执法堂长老
- **Commands**: /init-tianxuan, /task-status, /archive-task
- **Skills**: tianxuan-brainstorming, tianxuan-藏经阁优先, tianxuan-self-review, tianxuan-two-stage-review, tianxuan-systematic-debugging

## 初始化项目

在你的项目根目录执行：

```bash
/init-tianxuan
```

这将创建 `天玄宗/` 目录结构和配置文件。

## 开始使用

向宗主下达任务：

```
@宗主 我想实现一个用户管理系统
```

宗主会引导你完成需求探索、设计确认、任务拆分和协作开发。

## 卸载插件

```bash
/plugin uninstall tianxuan-sect
```

## 故障排除

### 插件未加载

1. 检查插件是否已启用：
   ```bash
   /plugin list
   ```

2. 如果显示已禁用，启用插件：
   ```bash
   /plugin enable tianxuan-sect
   ```

3. 重启 Claude Code

### Agents 未显示

1. 检查 `.claude-plugin/plugin.json` 是否存在
2. 检查 `agents/` 目录是否存在
3. 检查 agent 文件是否有正确的 frontmatter

### Commands 未显示

1. 检查 `commands/` 目录是否存在
2. 检查 command 文件是否有正确的 frontmatter
3. 使用 `/help` 查看所有可用命令

### Skills 未触发

1. 检查 `skills/` 目录是否存在
2. 检查 skill 文件是否有正确的 frontmatter
3. 检查 agent 的 `skills` 字段是否正确配置

## 更新插件

```bash
/plugin update tianxuan-sect
```

## 获取帮助

- GitHub Issues: https://github.com/xjk2000/tianxuan-sect/issues
- 文档: README.md
