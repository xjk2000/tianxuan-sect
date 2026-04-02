# 天玄宗安装指南

## 前置要求

- Claude Code (最新版本)
- Git
- Node.js 16+ (可选，用于运行脚本)
- Python 3 (用于 hooks 通知脚本)
- 桌面通知依赖（可选，按平台安装）：
  - **macOS**：
    ```bash
    brew install terminal-notifier
    ```
  - **Windows**：安装 BurntToast 模块（以管理员身份打开 PowerShell）：
    ```powershell
    Install-Module -Name BurntToast -Force -Scope CurrentUser
    ```
  - **Linux**：
    ```bash
    sudo apt install libnotify-bin   # Debian/Ubuntu
    sudo dnf install libnotify       # Fedora
    ```

---

## 安装方式

天玄宗目前提供两种安装方式：

### 方式一：从 GitHub 克隆安装（推荐）

#### 1. 克隆仓库

```bash
git clone https://github.com/xjk2000/tianxuan-sect.git
cd tianxuan-sect
```

#### 2. 在 Claude Code 中添加插件

在 Claude Code 中运行：

```bash
# 安装插件market
/plugin marketplace add /path/to/tianxuan-sect
# 添加本地插件
/plugin add /path/to/tianxuan-sect
```

或者使用绝对路径：

```bash
# macOS/Linux 示例
/plugin add /Users/yourname/Projects/tianxuan-sect

# Windows 示例
/plugin add C:\Users\yourname\Projects\tianxuan-sect
```

#### 3. 验证安装

运行初始化命令：

```bash
# 创建天玄宗目录结构
/宗门初始化

# 勘查项目灵脉并生成文档
/灵脉勘查
```

如果看到天玄宗的目录结构被创建，说明安装成功！

```
✅ 创建目录: 天玄宗/宗门任务榜/
✅ 创建目录: 天玄宗/藏经阁/
✅ 创建目录: 天玄宗/执法堂/
✅ 创建目录: 天玄宗/丹堂/

灵脉勘查完毕，已将项目知识存入藏经阁！
```

---

### 方式二：直接从 GitHub 安装

```bash
# 直接从 GitHub 仓库安装
/plugin add https://github.com/xjk2000/tianxuan-sect
```

Claude Code 会自动克隆仓库并安装插件。

---

## 验证安装

### 检查插件列表

```bash
/plugin list
```

你应该能看到 `tianxuan-sect` 在插件列表中。

### 检查可用命令

```bash
/help
```

你应该能看到以下天玄宗命令：
- `/宗门初始化` - 初始化天玄宗目录结构
- `/灵脉勘查` - 勘查项目灵脉并生成藏经阁文档
- `/宗门新任务` - 创建新的开发任务
- `/宗门任务继续` - 继续未完成的任务
- `/任务查询` - 查看任务状态
- `/任务归档` - 归档完成的任务

### 检查可用 Agents

在 Claude Code 中，你应该能够使用 `@` 调用以下角色：
- `@宗主` - 需求探索、任务拆分、调度协调
- `@藏经阁长老` - 知识管理、文档调研
- `@丹堂长老` - 数据查询、日志分析
- `@阵堂长老` - 后端开发
- `@器堂长老` - 前端开发
- `@执法堂长老` - 测试验收、质量把关
- `@杂役弟子` - 处理简单任务

---

## 配置（可选）

### 自定义配置

在项目根目录创建 `.tianxuan.config.json`：

```json
{
  "defaultModel": "sonnet-4",
  "藏经阁路径": "天玄宗/藏经阁",
  "启用自动归档": true,
  "质量门禁": {
    "强制藏经阁查询": true,
    "强制自检": true,
    "强制两阶段审查": true
  }
}
```

---

## 更新插件

### 从 GitHub 更新

```bash
cd tianxuan-sect
git pull origin main
```

然后在 Claude Code 中重新加载插件：

```bash
/plugin reload tianxuan-sect
```

---

## 卸载

### 移除插件

```bash
/plugin remove tianxuan-sect
```

### 删除本地文件（可选）

```bash
rm -rf /path/to/tianxuan-sect
```

---

## 故障排除

### 问题 1: 插件未加载

**症状**: `/plugin list` 中看不到 tianxuan-sect

**解决方案**:
1. 检查 Claude Code 版本是否为最新
2. 确认插件路径正确
3. 尝试重新添加插件：
   ```bash
   /plugin remove tianxuan-sect
   /plugin add /path/to/tianxuan-sect
   ```

### 问题 2: 命令不可用

**症状**: `/宗门初始化` 等命令无法使用

**解决方案**:
1. 确认插件已正确加载（`/plugin list`）
2. 检查 `commands/` 目录是否存在
3. 重新加载插件：
   ```bash
   /plugin reload tianxuan-sect
   ```

### 问题 3: Agent 无法调用

**症状**: `@宗主` 等 Agent 无法使用

**解决方案**:
1. 确认 `agents/` 目录下有对应的 `.md` 文件
2. 检查 Agent 文件的 frontmatter 格式是否正确
3. 重启 Claude Code

### 问题 4: macOS 通知不生效

**症状**: Agent 完成任务后没有桌面通知弹出

**macOS 解决方案**:
1. 确认已安装 `terminal-notifier`：
   ```bash
   brew install terminal-notifier
   ```
2. 确认 Python 3 可用：
   ```bash
   python3 --version
   ```
3. 确认脚本有执行权限：
   ```bash
   chmod +x /path/to/tianxuan-sect/hooks/notify.py
   ```
4. 手动测试通知脚本：
   ```bash
   echo '{"hook_event_name":"Stop","transcript_path":""}' | python3 /path/to/tianxuan-sect/hooks/notify.py
   ```
5. 检查系统通知权限：**系统偏好设置 → 通知 → terminal-notifier** → 允许通知

**Windows 解决方案**:
1. 确认已安装 BurntToast 模块：
   ```powershell
   Install-Module -Name BurntToast -Force -Scope CurrentUser
   ```
2. 确认 PowerShell 执行策略允许运行脚本：
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```
3. 手动测试通知脚本：
   ```powershell
   echo '{"hook_event_name":"Stop","transcript_path":""}' | powershell.exe -ExecutionPolicy Bypass -File /path/to/tianxuan-sect/hooks/notify_windows.ps1
   ```
4. 检查系统通知权限：**设置 → 系统 → 通知** → 确认通知已开启

**Linux 解决方案**:
1. 确认已安装 `notify-send`：
   ```bash
   sudo apt install libnotify-bin   # Debian/Ubuntu
   sudo dnf install libnotify       # Fedora
   ```
2. 手动测试通知脚本：
   ```bash
   echo '{"hook_event_name":"Stop","transcript_path":""}' | python3 /path/to/tianxuan-sect/hooks/notify.py
   ```

---

### 问题 5: Git 克隆失败

**症状**: `git clone` 报错

**解决方案**:
1. 检查网络连接
2. 使用 SSH 方式克隆：
   ```bash
   git clone git@github.com:xjk2000/tianxuan-sect.git
   ```
3. 或者下载 ZIP 文件后解压

---

## 开发模式

如果你想修改插件代码：

### 1. Fork 仓库

在 GitHub 上 Fork `xjk2000/tianxuan-sect`

### 2. 克隆你的 Fork

```bash
git clone https://github.com/yourusername/tianxuan-sect.git
cd tianxuan-sect
```

### 3. 创建开发分支

```bash
git checkout -b feature/your-feature
```

### 4. 添加到 Claude Code

```bash
/plugin add /path/to/your/tianxuan-sect
```

### 5. 修改后重新加载

```bash
/plugin reload tianxuan-sect
```

---

## 获取帮助

- 📖 查看 [快速开始指南](docs/guides/getting-started.md)
- 🐛 提交 [Issue](https://github.com/xjk2000/tianxuan-sect/issues)
- 💬 加入讨论 [Discussions](https://github.com/xjk2000/tianxuan-sect/discussions)
- 📝 阅读 [完整文档](README.md)

---

## 下一步

安装成功后，建议：

1. 阅读 [快速开始指南](docs/guides/getting-started.md)
2. 了解 [Skills 系统](SKILLS_COMPLETE_SUMMARY.md)
3. 查看 [完整工作流程](README.md#完整工作流程)
4. 尝试第一个任务！

**欢迎来到天玄宗！** 🎊
