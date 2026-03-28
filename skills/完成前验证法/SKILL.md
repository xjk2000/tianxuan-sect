---
name: 完成前验证法
description: 任务完成前的最终验证 - 确保所有要求都已满足
user-invocable: false
---

# 完成前验证法 (Verification Before Completion)

## 技能说明

在宣布任务完成之前，执行全面的验证检查，确保所有要求都已满足。

## 核心原则

**不要相信自己的记忆，用测试和检查来验证。**

## 何时使用

**在以下情况之前**：
- ✅ 向宗主报告任务完成
- ✅ 提交最终代码
- ✅ 请求代码审查
- ✅ 合并分支

## 验证清单

### 1. 功能完整性

```
执法堂长老: 验证功能完整性

检查:
- [ ] 所有需求都已实现
- [ ] 没有遗漏的功能
- [ ] 没有 TODO/FIXME
- [ ] 没有占位符代码
```

**如何验证**：
```bash
# 搜索 TODO/FIXME
grep -r "TODO\|FIXME" src/

# 搜索占位符
grep -r "placeholder\|TBD\|待实现" src/
```

### 2. 测试覆盖

```
执法堂长老: 验证测试覆盖

检查:
- [ ] 所有功能都有测试
- [ ] 测试覆盖率 ≥ 80%
- [ ] 所有测试通过
- [ ] 没有跳过的测试
```

**如何验证**：
```bash
# 运行所有测试
npm test

# 检查覆盖率
npm run test:coverage

# 查看覆盖率报告
open coverage/index.html
```

### 3. 代码质量

```
执法堂长老: 验证代码质量

检查:
- [ ] 代码符合规范
- [ ] 没有 lint 错误
- [ ] 没有类型错误
- [ ] 没有调试代码
```

**如何验证**：
```bash
# Lint 检查
npm run lint

# 类型检查
npm run type-check

# 搜索调试代码
grep -r "console.log\|debugger" src/
```

### 4. 文档完整性

```
执法堂长老: 验证文档

检查:
- [ ] README 已更新
- [ ] API 文档已更新
- [ ] 注释清晰完整
- [ ] 变更日志已更新
```

**如何验证**：
```bash
# 检查是否有未注释的公共方法
# 检查 README 是否提到新功能
# 检查 CHANGELOG 是否记录变更
```

### 5. 依赖和构建

```
执法堂长老: 验证构建

检查:
- [ ] 依赖已安装
- [ ] 构建成功
- [ ] 没有构建警告
- [ ] 产物正确
```

**如何验证**：
```bash
# 清理并重新安装
rm -rf node_modules
npm install

# 构建
npm run build

# 检查构建产物
ls -la dist/
```

### 6. 集成测试

```
执法堂长老: 验证集成

检查:
- [ ] 与现有功能集成正常
- [ ] 没有破坏现有功能
- [ ] 端到端测试通过
- [ ] 性能可接受
```

**如何验证**：
```bash
# 运行集成测试
npm run test:integration

# 运行端到端测试
npm run test:e2e

# 性能测试
npm run test:performance
```

### 7. Git 状态

```
执法堂长老: 验证 Git 状态

检查:
- [ ] 所有更改已提交
- [ ] 提交消息清晰
- [ ] 没有未跟踪文件
- [ ] 分支是最新的
```

**如何验证**：
```bash
# 检查状态
git status

# 检查提交历史
git log --oneline -10

# 检查未跟踪文件
git ls-files --others --exclude-standard
```

## 验证流程

### 阶段 1: 自动化检查

```bash
#!/bin/bash
# 完成前验证脚本

echo "🔍 开始验证..."

# 1. 测试
echo "1️⃣ 运行测试..."
npm test || exit 1

# 2. Lint
echo "2️⃣ Lint 检查..."
npm run lint || exit 1

# 3. 类型检查
echo "3️⃣ 类型检查..."
npm run type-check || exit 1

# 4. 构建
echo "4️⃣ 构建..."
npm run build || exit 1

# 5. 搜索问题
echo "5️⃣ 搜索问题..."
if grep -r "TODO\|FIXME\|console.log" src/; then
  echo "❌ 发现 TODO/FIXME/console.log"
  exit 1
fi

echo "✅ 所有自动化检查通过"
```

### 阶段 2: 手动检查

```
执法堂长老: 手动验证

1. 功能演示
   - 运行应用
   - 测试所有新功能
   - 测试边界情况

2. 代码审查
   - 阅读所有更改
   - 检查逻辑正确性
   - 检查错误处理

3. 文档检查
   - 阅读 README
   - 检查 API 文档
   - 验证示例代码

4. 性能检查
   - 测试响应时间
   - 检查内存使用
   - 检查资源泄漏
```

### 阶段 3: 报告

```
执法堂长老: 验证报告

@宗主 任务验证完成

✅ 通过项：
- 所有测试通过（覆盖率 85%）
- Lint 无错误
- 类型检查通过
- 构建成功
- 文档已更新
- Git 状态干净

⚠️ 注意项：
- 性能测试显示响应时间略有增加（+50ms）
- 建议后续优化

📊 测试结果：
- 单元测试: 45/45 通过
- 集成测试: 12/12 通过
- 覆盖率: 85%

准备提交审查。
```

## 常见问题处理

### 问题 1: 测试失败

```
执法堂长老: 发现测试失败

处理:
1. 查看失败的测试
2. 分析失败原因
3. 修复代码或测试
4. 重新运行验证

不要忽略失败的测试。
```

### 问题 2: 覆盖率不足

```
执法堂长老: 覆盖率只有 65%

处理:
1. 查看覆盖率报告
2. 找到未覆盖的代码
3. 添加测试
4. 重新运行验证

目标: 至少 80%
```

### 问题 3: 发现遗漏功能

```
执法堂长老: 发现需求中的功能未实现

处理:
1. 立即报告宗主
2. 补充实现
3. 添加测试
4. 重新验证

不要隐瞒遗漏。
```

### 问题 4: 性能问题

```
执法堂长老: 发现性能下降

处理:
1. 记录性能数据
2. 分析原因
3. 报告宗主
4. 讨论是否可接受

如果不可接受，优化后重新验证。
```

## 与天玄宗的集成

### 执法堂使用

```
执法堂长老: 收到阵堂的任务完成报告

(使用完成前验证法)

1. 运行自动化检查
   ./scripts/verify-completion.sh

2. 手动验证功能
   - 启动应用
   - 测试所有功能
   - 检查边界情况

3. 代码审查
   - 阅读所有更改
   - 检查质量

4. 生成报告
   - 记录所有发现
   - 报告宗主

5. 决定
   - ✅ 通过 → 批准
   - ❌ 不通过 → 打回修复
```

### 宗主使用

```
宗主: 最终验收前使用

(使用完成前验证法)

1. 验证所有任务完成
2. 验证集成正常
3. 验证文档完整
4. 验证可以交付

通过后归档到藏经阁。
```

## 验证脚本示例

### verify-completion.sh

```bash
#!/bin/bash
# 完成前验证脚本

set -e

echo "🔍 天玄宗完成前验证"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 计数器
PASSED=0
FAILED=0

# 检查函数
check() {
  local name=$1
  local command=$2
  
  echo -n "检查 $name... "
  
  if eval "$command" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 通过${NC}"
    ((PASSED++))
  else
    echo -e "${RED}❌ 失败${NC}"
    ((FAILED++))
  fi
}

# 1. 测试
check "单元测试" "npm test"

# 2. Lint
check "代码规范" "npm run lint"

# 3. 类型检查
check "类型检查" "npm run type-check"

# 4. 构建
check "构建" "npm run build"

# 5. TODO/FIXME
check "无 TODO" "! grep -r 'TODO\|FIXME' src/"

# 6. 调试代码
check "无调试代码" "! grep -r 'console.log\|debugger' src/"

# 7. Git 状态
check "Git 干净" "[ -z \"\$(git status --porcelain)\" ]"

# 总结
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "通过: ${GREEN}$PASSED${NC}"
echo -e "失败: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ 所有检查通过，可以提交！${NC}"
  exit 0
else
  echo -e "${RED}❌ 有 $FAILED 项检查失败，请修复后重试${NC}"
  exit 1
fi
```

## 总结

完成前验证法确保：
- ✅ 功能完整
- ✅ 测试充分
- ✅ 质量合格
- ✅ 文档完整
- ✅ 可以交付

**不要跳过验证，质量第一。**
