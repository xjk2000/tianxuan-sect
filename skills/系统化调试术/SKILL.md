---
name: 系统化调试术
description: 系统化调试技能 - 诊断根因、打回修复、3次失败质疑架构
user-invocable: false
---

# Systematic Debugging (系统化调试)

## 技能说明

为执法堂提供系统化的调试流程，快速定位和修复问题。

## 实用工具脚本

本 skill 包含以下可执行脚本：

- **[find-polluter.sh](find-polluter.sh)** - 查找创建不需要文件的测试
- **[analyze-logs.sh](analyze-logs.sh)** - 分析日志文件，提取错误和警告
- **[check-db-state.sh](check-db-state.sh)** - 检查数据库状态（支持 PostgreSQL/MySQL/MongoDB）

详细用法请查看 [debugging-scripts.md](debugging-scripts.md)。

## 核心原则

**先诊断再修复** - 找到根本原因，而不是治标不治本。

## 执行流程

### Phase 1: 根因诊断

#### 1.1 收集证据

收集所有相关信息：

```bash
# 错误日志
tail -n 100 /var/log/app.log

# 堆栈跟踪
cat error.log

# 测试数据
cat test-data.json

# 环境信息
env | grep -E "DATABASE|API|PORT"
```

#### 1.2 定位责任堂

根据错误类型判断责任堂：

| 错误类型 | 责任堂 | 示例 |
|----------|--------|------|
| 后端接口错误 | 阵堂 | NullPointerException, SQLException |
| 前端组件错误 | 器堂 | TypeError, ReferenceError |
| 数据问题 | 丹堂 | 数据不一致、缺失 |
| 架构设计问题 | 宗主 | 技术选型不当、设计缺陷 |

#### 1.3 分析根因

深入分析失败原因：

**代码逻辑错误**:
```
问题: 用户注册失败
证据: NullPointerException at UserService.java:45
根因: userId 未校验就使用
责任: 阵堂
```

**配置错误**:
```
问题: 数据库连接失败
证据: Connection refused: localhost:3306
根因: 数据库端口配置错误
责任: 阵堂
```

**环境问题**:
```
问题: 文件写入失败
证据: Permission denied: /var/log/app.log
根因: 应用无写入权限
责任: 环境配置（非代码问题）
```

**架构设计缺陷**:
```
问题: 性能测试失败，响应时间 > 10s
证据: 数据库查询 N+1 问题
根因: 架构设计未考虑性能优化
责任: 宗主（需要重新设计）
```

### Phase 2: 生成诊断报告

```bash
# 获取当前诊断报告数量
REPORT_NUM=$(ls 天玄宗/宗门任务榜/{taskId}/执法堂-诊断报告-*.md 2>/dev/null | wc -l)
REPORT_NUM=$((REPORT_NUM + 1))

cat > 天玄宗/宗门任务榜/{taskId}/执法堂-诊断报告-$(printf "%03d" $REPORT_NUM).md <<EOF
# 诊断报告 #$REPORT_NUM

**诊断时间**: $(date +"%Y-%m-%d %H:%M")
**诊断人**: @执法堂长老

## 失败项

### 失败项1: 用户注册失败
- 测试阶段: 功能符合性测试
- 失败描述: 调用注册接口返回 500 错误
- 预期结果: 返回 200 和 userId
- 实际结果: 返回 500 错误

## 根因分析

### 根因: userId 未校验就使用

**责任堂**: 阵堂

**问题类型**: 代码逻辑错误

**详细分析**:
1. UserService.createUser() 方法中，userId 参数未校验
2. 当 userId 为 null 时，直接调用 userId.toString() 导致 NullPointerException
3. 异常未捕获，导致返回 500 错误

**证据**:

\`\`\`
java.lang.NullPointerException: Cannot invoke "String.toString()" because "userId" is null
    at com.example.service.UserService.createUser(UserService.java:45)
    at com.example.controller.UserController.register(UserController.java:30)
\`\`\`

## 修复建议

1. 在 UserService.createUser() 方法开头添加参数校验：
   \`\`\`java
   if (StringUtils.isBlank(userId)) {
       throw new IllegalArgumentException("用户ID不能为空");
   }
   \`\`\`

2. 添加异常处理，返回 400 错误而非 500：
   \`\`\`java
   try {
       // 业务逻辑
   } catch (IllegalArgumentException e) {
       return Result.error(400, e.getMessage());
   }
   \`\`\`

3. 添加单元测试，覆盖 userId 为 null 的场景

## 打回修复

@阵堂长老

请根据诊断报告修复以下问题：
1. UserService.createUser() 方法添加 userId 参数校验
2. 添加异常处理，返回 400 错误
3. 添加单元测试

修复后请通知执法堂重新测试。
EOF
```

### Phase 3: 打回修复

```
@阵堂长老

**诊断报告**: /天玄宗/宗门任务榜/{taskId}/执法堂-诊断报告-001.md

请根据诊断报告修复问题，修复后通知执法堂重新测试。
```

### Phase 4: 失败计数与质疑架构

#### 4.1 更新失败计数

```bash
# 读取当前失败次数
FAILURE_COUNT=$(jq -r '.failureCount.阵堂' 天玄宗/宗门任务榜/{taskId}/.task-status.json)

# 增加失败次数
FAILURE_COUNT=$((FAILURE_COUNT + 1))

# 更新状态文件
jq ".failureCount.阵堂 = $FAILURE_COUNT" \
  天玄宗/宗门任务榜/{taskId}/.task-status.json > tmp.json
mv tmp.json 天玄宗/宗门任务榜/{taskId}/.task-status.json
```

#### 4.2 检查是否达到阈值

```bash
if [ $FAILURE_COUNT -ge 3 ]; then
  echo "⚠️ 阵堂已失败 3 次，通知宗主质疑架构"
fi
```

#### 4.3 通知宗主质疑架构

```
@宗主

⚠️ **架构质疑警报**

阵堂在任务 {taskId} 中已失败 3 次，可能存在架构设计问题。

**失败历史**:
1. 诊断报告-001: userId 未校验导致 NullPointerException
2. 诊断报告-002: 数据库事务未正确配置
3. 诊断报告-003: 异常处理不完整

**共性问题**:
- 参数校验不完整
- 异常处理不规范
- 缺少单元测试

**建议**:
1. 重新评估任务拆分方式，是否任务定义不够清晰
2. 补充任务文件中的参数校验规范
3. 补充任务文件中的异常处理规范
4. 要求阵堂在 Self-Review 中增加单元测试检查

**是否需要调整任务定义或架构设计？**
```

## 诊断技巧

### 1. 日志分析

```bash
# 查找错误日志
grep -i "error\|exception" /var/log/app.log

# 查找特定时间段的日志
sed -n '/2026-03-28 14:00/,/2026-03-28 15:00/p' /var/log/app.log

# 统计错误类型
grep -i "exception" /var/log/app.log | awk '{print $NF}' | sort | uniq -c
```

### 2. 堆栈跟踪分析

```
关注:
1. 异常类型 (NullPointerException, SQLException, etc.)
2. 异常位置 (文件名:行号)
3. 调用链 (从哪里调用的)
```

### 3. 数据验证

```bash
# 验证数据库数据
mysql -u root -p -e "SELECT * FROM user WHERE id = 'xxx';"

# 验证文件内容
cat /path/to/config.json | jq .

# 验证环境变量
env | grep DATABASE
```

### 4. 复现问题

```bash
# 使用相同的测试数据复现
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"userId":null}'
```

## 3次失败原则

### 为什么是3次？

1. **第1次失败**: 可能是疏忽，给机会修复
2. **第2次失败**: 可能是理解不够，再给一次机会
3. **第3次失败**: 可能是架构问题，需要宗主介入

### 质疑架构的场景

- **任务定义不清晰**: 任务文件缺少关键信息
- **技术选型不当**: 技术栈不适合需求
- **设计缺陷**: 架构设计存在根本性问题
- **依赖问题**: 依赖关系处理不当

## 好处

1. **找到根因** - 不是治标不治本
2. **避免重复** - 记录诊断过程
3. **及时止损** - 3次失败质疑架构
4. **持续改进** - 从失败中学习

## 注意事项

1. **不要猜测** - 基于证据诊断
2. **不要责备** - 专注于问题本身
3. **不要拖延** - 及时诊断和修复
4. **不要忽视** - 3次失败必须通知宗主
