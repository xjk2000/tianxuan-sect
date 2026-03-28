---
name: 自检心法
description: 自检技能 - 完成任务后执行自检清单，确保代码质量符合标准
user-invocable: false
---

# Self-Review (自检)

## 技能说明

各堂长老完成任务后，执行自检清单，确保代码质量符合标准。

## 核心原则

**发现问题立即修复** - 不要将问题留给执法堂。

## 详细参考文档

根据项目技术栈，查看对应的详细自检清单：

- **Java 项目**: 查看 [java-checklist.md](java-checklist.md)
- **Node.js/TypeScript 项目**: 查看 [nodejs-checklist.md](nodejs-checklist.md)
- **Python 项目**: 查看 [python-checklist.md](python-checklist.md)

这些文档包含详细的代码示例和最佳实践。

## 自动化检查工具

使用自动化脚本快速检查代码质量：

```bash
# 检查代码质量问题
./check-code-quality.sh src/

# 检查结果会显示：
# - TODO/FIXME 数量
# - 注释掉的代码
# - 调试语句（console.log 等）
# - 可能的魔法值
# - 空的 catch 块
```

详见 [check-code-quality.sh](check-code-quality.sh)。

## 自检清单

### 通用自检清单

- [ ] **没有 TODO/FIXME** - 所有待办都已完成
- [ ] **没有注释掉的代码** - 删除无用代码
- [ ] **没有调试代码** - 删除 console.log/print/debug 语句
- [ ] **变量命名语义清晰** - 使用有意义的变量名
- [ ] **魔法值已提取** - 提取为常量或枚举
- [ ] **代码符合规范** - 遵循项目代码规范

### 后端自检清单 (阵堂)

#### 参数校验

- [ ] **使用工具类而非手动判空**
  - 字符串: `StringUtils.isNotBlank()` 而非 `!= null`
  - 集合: `CollectionUtils.isNotEmpty()` 而非 `!= null`
  - 对象: `Objects.requireNonNull()` 或 `Objects.nonNull()`
- [ ] **所有入参都有校验**
- [ ] **校验失败抛出明确异常**

#### 异常处理

- [ ] **所有可能的异常都有 try-catch**
- [ ] **异常信息明确且用户友好**
- [ ] **敏感信息不暴露在异常中**
- [ ] **异常有日志记录**

#### 事务管理

- [ ] **数据库操作有 `@Transactional` 注解**
- [ ] **事务传播行为正确**
- [ ] **rollbackFor 包含所有异常**

#### 日志记录

- [ ] **关键操作有 `log.info` 记录**
- [ ] **异常有 `log.error` 记录**
- [ ] **日志信息完整（包含关键参数）**
- [ ] **敏感信息不记录到日志**

#### 代码规范

- [ ] **导入语句正确** - 使用正确的包
- [ ] **方法长度合理** - 单个方法 < 50 行
- [ ] **类职责单一** - 遵循单一职责原则
- [ ] **所有公共方法都有 Javadoc**

### 前端自检清单 (器堂)

#### 组件规范

- [ ] **组件命名符合规范**
  - Vue/React: PascalCase (如 `UserProfile`)
  - 文件名: kebab-case (如 `user-profile.vue`)
- [ ] **Props 校验完整**
  - 所有 props 都有类型定义
  - 必填 props 有 required 标记
  - 可选 props 有默认值
- [ ] **Events 命名规范**
  - Vue: kebab-case (如 `update:modelValue`)
  - React: camelCase (如 `onUpdate`)

#### 异常处理

- [ ] **所有 API 调用都有 try-catch**
- [ ] **异常有用户友好的提示**
- [ ] **Loading 状态处理完整**
- [ ] **错误状态处理完整**

#### 用户体验

- [ ] **Loading 状态显示**
- [ ] **成功提示显示**
- [ ] **错误提示显示**
- [ ] **空状态处理**
- [ ] **边界情况处理（如列表为空）**

#### 代码规范

- [ ] **组件职责单一**
- [ ] **可复用逻辑已抽取**
- [ ] **导入语句正确**
- [ ] **所有组件都有注释说明**

## 执行流程

### 1. 完成代码实现

按照任务文件完成所有代码实现。

### 2. 执行自检清单

逐项检查自检清单：

```
Self-Review 自检:

✅ 参数校验完整
✅ 异常处理完整
✅ 事务管理正确
✅ 日志记录完整
✅ 魔法值已提取
✅ 代码符合规范
✅ 没有 TODO/FIXME
✅ 没有调试代码
```

### 3. 发现问题立即修复

如果发现问题：

```
Self-Review 发现问题:

❌ 参数校验不完整 - userId 未校验
❌ 异常处理缺失 - createUser 方法未捕获异常

修复中...
(修复代码)

重新自检...
✅ 参数校验完整
✅ 异常处理完整
...
```

### 4. 全部通过后标记完成

```
Self-Review: ✅ 全部通过

@宗主 阵堂任务已完成
```

## 自检工具

### 代码静态检查

```bash
# Java
mvn checkstyle:check
mvn pmd:check

# JavaScript/TypeScript
npm run lint
npm run type-check

# Python
pylint src/
mypy src/
```

### 代码格式化

```bash
# Java
mvn spotless:apply

# JavaScript/TypeScript
npm run format

# Python
black src/
```

### 单元测试

```bash
# Java
mvn test

# JavaScript/TypeScript
npm test

# Python
pytest
```

## 好处

1. **减少返工** - 提前发现问题
2. **提高质量** - 自我把关
3. **加快速度** - 减少执法堂打回次数
4. **培养习惯** - 养成良好编码习惯

## 注意事项

1. **不要走形式** - 认真检查每一项
2. **不要跳过** - 即使赶时间也要自检
3. **不要自欺欺人** - 发现问题必须修复
4. **不要依赖执法堂** - 自检是第一道防线
