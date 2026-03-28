---
name: task-status
description: 查看当前所有活跃任务的状态
disable-model-invocation: true
---

# 查看任务状态

## 命令说明

查看当前所有活跃任务的状态。

## 执行步骤

### 1. 检查天玄宗目录

```bash
if [ ! -d "天玄宗/宗门任务榜" ]; then
  echo "❌ 天玄宗未初始化，请先执行 /init-tianxuan"
  exit 1
fi
```

### 2. 扫描任务榜

```bash
TASKS=$(ls -1 天玄宗/宗门任务榜/ 2>/dev/null)

if [ -z "$TASKS" ]; then
  echo "📋 当前没有活跃任务"
  exit 0
fi
```

### 3. 读取并格式化输出

```bash
echo "📋 当前活跃任务:"
echo ""

for task_dir in 天玄宗/宗门任务榜/*/; do
  if [ ! -f "$task_dir/.task-status.json" ]; then
    continue
  fi
  
  # 读取任务状态
  TASK_ID=$(basename "$task_dir")
  STATUS_FILE="$task_dir/.task-status.json"
  
  # 提取关键信息（使用 jq 或手动解析）
  echo "## $TASK_ID"
  echo ""
  
  # 任务基本信息
  echo "**状态**: $(jq -r '.status' "$STATUS_FILE")"
  echo "**创建时间**: $(jq -r '.createdAt' "$STATUS_FILE")"
  echo "**分支**: $(jq -r '.branch' "$STATUS_FILE")"
  echo ""
  
  # 各堂进度
  echo "**进度**:"
  
  # 藏经阁
  ZJG_STATUS=$(jq -r '.tasks.藏经阁.status' "$STATUS_FILE")
  if [ "$ZJG_STATUS" = "completed" ]; then
    echo "- 藏经阁: ✅ 已完成"
  elif [ "$ZJG_STATUS" = "in_progress" ]; then
    echo "- 藏经阁: 🔄 进行中"
  elif [ "$ZJG_STATUS" = "failed" ]; then
    echo "- 藏经阁: ❌ 失败"
  else
    echo "- 藏经阁: ⏸️ 等待中"
  fi
  
  # 阵堂
  ZT_STATUS=$(jq -r '.tasks.阵堂.status' "$STATUS_FILE")
  ZT_BLOCKED=$(jq -r '.tasks.阵堂.blockedBy[]' "$STATUS_FILE" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
  if [ "$ZT_STATUS" = "completed" ]; then
    echo "- 阵堂: ✅ 已完成"
  elif [ "$ZT_STATUS" = "in_progress" ]; then
    echo "- 阵堂: 🔄 进行中"
  elif [ "$ZT_STATUS" = "failed" ]; then
    echo "- 阵堂: ❌ 失败"
  elif [ -n "$ZT_BLOCKED" ]; then
    echo "- 阵堂: ⏸️ 等待中 (阻塞: $ZT_BLOCKED)"
  else
    echo "- 阵堂: ⏸️ 等待中"
  fi
  
  # 器堂
  QT_STATUS=$(jq -r '.tasks.器堂.status' "$STATUS_FILE")
  QT_BLOCKED=$(jq -r '.tasks.器堂.blockedBy[]' "$STATUS_FILE" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
  if [ "$QT_STATUS" = "completed" ]; then
    echo "- 器堂: ✅ 已完成"
  elif [ "$QT_STATUS" = "in_progress" ]; then
    echo "- 器堂: 🔄 进行中"
  elif [ "$QT_STATUS" = "failed" ]; then
    echo "- 器堂: ❌ 失败"
  elif [ -n "$QT_BLOCKED" ]; then
    echo "- 器堂: ⏸️ 等待中 (阻塞: $QT_BLOCKED)"
  else
    echo "- 器堂: ⏸️ 等待中"
  fi
  
  # 执法堂
  ZFT_STATUS=$(jq -r '.tasks.执法堂.status' "$STATUS_FILE")
  ZFT_BLOCKED=$(jq -r '.tasks.执法堂.blockedBy[]' "$STATUS_FILE" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
  if [ "$ZFT_STATUS" = "completed" ]; then
    echo "- 执法堂: ✅ 已完成"
  elif [ "$ZFT_STATUS" = "in_progress" ]; then
    echo "- 执法堂: 🔄 进行中"
  elif [ "$ZFT_STATUS" = "failed" ]; then
    echo "- 执法堂: ❌ 失败"
  elif [ -n "$ZFT_BLOCKED" ]; then
    echo "- 执法堂: ⏸️ 等待中 (阻塞: $ZFT_BLOCKED)"
  else
    echo "- 执法堂: ⏸️ 等待中"
  fi
  
  echo ""
  echo "---"
  echo ""
done
```

## 输出示例

```
📋 当前活跃任务:

## 2026-03-28-user-system

**状态**: in_progress
**创建时间**: 2026-03-28T12:00:00Z
**分支**: task/2026-03-28-user-system

**进度**:
- 藏经阁: ✅ 已完成
- 阵堂: 🔄 进行中
- 器堂: ⏸️ 等待中 (阻塞: 阵堂)
- 执法堂: ⏸️ 等待中 (阻塞: 阵堂, 器堂)

---

## 2026-03-29-payment-integration

**状态**: in_progress
**创建时间**: 2026-03-29T09:00:00Z
**分支**: task/2026-03-29-payment-integration

**进度**:
- 藏经阁: 🔄 进行中
- 阵堂: ⏸️ 等待中 (阻塞: 藏经阁)
- 器堂: ⏸️ 等待中 (阻塞: 阵堂)
- 执法堂: ⏸️ 等待中 (阻塞: 阵堂, 器堂)

---
```

## 使用示例

```bash
# 查看当前任务状态
/task-status
```
