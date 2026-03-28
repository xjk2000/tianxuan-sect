# 天玄宗测试套件

本目录包含天玄宗插件的测试文件。

## 测试结构

```
tests/
├── agents/          # Agent 功能测试
├── skills/          # Skill 功能测试
├── commands/        # Command 功能测试
├── integration/     # 集成测试
└── README.md        # 本文件
```

## 运行测试

### 手动测试

1. **测试插件加载**
   ```bash
   /plugin install /path/to/claudecode-xiuxian
   /plugin list
   ```

2. **测试 Agents**
   ```bash
   /agents
   # 应该看到 6 个 agents
   ```

3. **测试 Commands**
   ```bash
   /help
   # 应该看到 /init-tianxuan, /task-status, /archive-task
   ```

4. **测试初始化**
   ```bash
   /init-tianxuan
   # 检查是否创建了 天玄宗/ 目录
   ```

### 集成测试场景

详见 `integration/` 目录下的测试场景。

## 测试清单

### Agent 测试

- [ ] 宗主 - 需求探索流程
- [ ] 藏经阁长老 - 文档查询和存储
- [ ] 丹堂长老 - 数据查询
- [ ] 阵堂长老 - 后端开发
- [ ] 器堂长老 - 前端开发
- [ ] 执法堂长老 - 两阶段测试

### Skill 测试

- [ ] tianxuan-brainstorming - HARD-GATE 验证
- [ ] tianxuan-藏经阁优先 - 强制查询验证
- [ ] tianxuan-self-review - 自检清单验证
- [ ] tianxuan-two-stage-review - 两阶段流程验证
- [ ] tianxuan-systematic-debugging - 3次失败机制验证

### Command 测试

- [ ] /init-tianxuan - 目录创建验证
- [ ] /task-status - 状态显示验证
- [ ] /archive-task - 归档流程验证

## 贡献测试

如果你添加了新功能，请：

1. 在相应目录添加测试文件
2. 更新本 README 的测试清单
3. 确保所有测试通过后再提交 PR
