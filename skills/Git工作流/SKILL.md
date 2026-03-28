---
name: Git工作流
description: Git 工作流技能 - 规范的分支管理和提交流程
user-invocable: false
---

# Git Workflow (Git 工作流)

## 技能说明

为天玄宗任务提供规范的 Git 工作流程，包括分支管理、提交规范、合并策略。

## 核心原则

**一任务一分支** - 每个任务都在独立的分支上开发，确保主分支稳定。

## 分支命名规范

### 任务分支

```
task/YYYY-MM-DD-<任务简称>
```

示例：
- `task/2026-03-28-user-management`
- `task/2026-03-29-payment-integration`

### 其他分支

```
hotfix/<问题描述>    # 紧急修复
feature/<功能名称>   # 功能开发（非天玄宗任务）
bugfix/<Bug描述>     # Bug 修复
```

## 提交信息规范

### 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

- `feat` - 新功能
- `fix` - Bug 修复
- `docs` - 文档更新
- `style` - 代码格式调整
- `refactor` - 重构
- `test` - 测试相关
- `chore` - 构建/工具相关

### Scope 范围

- `宗主` - 宗主相关
- `藏经阁` - 藏经阁相关
- `阵堂` - 后端相关
- `器堂` - 前端相关
- `执法堂` - 测试相关
- `丹堂` - 数据相关

### 示例

```
feat(阵堂): 实现用户注册接口

- 添加 POST /api/users/register 接口
- 实现参数校验（username, email, password）
- 添加密码加密逻辑
- 添加单元测试

Closes #123
```

## 工作流程

### 1. 创建任务分支

宗主在创建任务时自动执行：

```bash
# 获取最新代码
git checkout main
git pull origin main

# 创建任务分支
TASK_ID=$(date +"%Y-%m-%d")-<任务简称>
git checkout -b task/$TASK_ID

# 推送到远程
git push -u origin task/$TASK_ID
```

### 2. 开发过程中提交

各堂在开发时：

```bash
# 添加修改
git add <files>

# 提交（遵循提交信息规范）
git commit -m "feat(阵堂): 实现用户注册接口"

# 推送到远程
git push
```

### 3. 定期同步主分支

```bash
# 切换到主分支
git checkout main
git pull origin main

# 切回任务分支
git checkout task/$TASK_ID

# 合并主分支的更新
git merge main

# 解决冲突（如果有）
# 推送
git push
```

### 4. 任务完成后合并

宗主在归档任务时执行：

```bash
# 切换到主分支
git checkout main
git pull origin main

# 合并任务分支（使用 --no-ff 保留分支历史）
git merge --no-ff task/$TASK_ID -m "完成任务: $TASK_ID"

# 推送到远程
git push origin main

# 删除本地分支
git branch -d task/$TASK_ID

# 删除远程分支
git push origin --delete task/$TASK_ID
```

## 冲突解决

### 预防冲突

1. **频繁同步** - 定期从主分支合并更新
2. **小步提交** - 避免一次性修改大量文件
3. **沟通协调** - 多人修改同一文件时提前沟通

### 解决冲突

```bash
# 1. 合并主分支时出现冲突
git merge main
# Auto-merging src/user.js
# CONFLICT (content): Merge conflict in src/user.js

# 2. 查看冲突文件
git status

# 3. 手动解决冲突
# 编辑冲突文件，保留正确的代码

# 4. 标记为已解决
git add src/user.js

# 5. 完成合并
git commit -m "merge: 解决与 main 分支的冲突"

# 6. 推送
git push
```

## 最佳实践

### 提交频率

- ✅ **小步快跑** - 完成一个小功能就提交
- ✅ **功能完整** - 每次提交都是可运行的代码
- ❌ **避免大提交** - 不要一次性提交几百行代码

### 提交内容

- ✅ **单一职责** - 一次提交只做一件事
- ✅ **相关文件** - 只提交相关的文件
- ❌ **避免混合** - 不要在一次提交中混合多个功能

### 分支管理

- ✅ **及时删除** - 任务完成后及时删除分支
- ✅ **保持同步** - 定期从主分支合并更新
- ❌ **避免长期分支** - 避免分支存在时间过长

## Git Worktree（可选）

对于需要同时处理多个任务的情况，可以使用 Git Worktree：

```bash
# 创建 worktree
git worktree add ../tianxuan-task-2 task/2026-03-28-task-2

# 在新目录工作
cd ../tianxuan-task-2

# 完成后删除 worktree
git worktree remove ../tianxuan-task-2
```

## 注意事项

1. **主分支保护** - 主分支应该始终是稳定的
2. **代码审查** - 重要修改应该经过代码审查
3. **测试通过** - 合并前确保测试通过
4. **文档同步** - 代码修改时同步更新文档
