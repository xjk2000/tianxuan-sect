#!/usr/bin/env bash
# 分析应用日志，提取错误和警告
# 用法: ./analyze-logs.sh [日志文件路径]

LOG_FILE=${1:-"app.log"}

if [ ! -f "$LOG_FILE" ]; then
  echo "❌ 日志文件不存在: $LOG_FILE"
  echo ""
  echo "用法: $0 [日志文件路径]"
  echo "示例: $0 /var/log/app.log"
  echo "      $0 logs/error.log"
  exit 1
fi

echo "📊 分析日志: $LOG_FILE"
echo "文件大小: $(du -h "$LOG_FILE" | cut -f1)"
echo ""

# 统计错误数量
ERROR_COUNT=$(grep -i "error" "$LOG_FILE" 2>/dev/null | wc -l | tr -d ' ')
echo "❌ 错误数量: $ERROR_COUNT"

# 统计警告数量
WARN_COUNT=$(grep -i "warn" "$LOG_FILE" 2>/dev/null | wc -l | tr -d ' ')
echo "⚠️  警告数量: $WARN_COUNT"

# 统计信息数量
INFO_COUNT=$(grep -i "info" "$LOG_FILE" 2>/dev/null | wc -l | tr -d ' ')
echo "ℹ️  信息数量: $INFO_COUNT"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 最近的错误
if [ "$ERROR_COUNT" -gt 0 ]; then
  echo "🔴 最近 10 条错误:"
  echo ""
  grep -i "error" "$LOG_FILE" | tail -n 10
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi

# 错误类型分布
if [ "$ERROR_COUNT" -gt 0 ]; then
  echo "📈 错误类型分布 (Top 10):"
  echo ""
  grep -i "error" "$LOG_FILE" | \
    sed -E 's/.*Error: ([^:]+).*/\1/' | \
    sed -E 's/.*error[: ]+([A-Za-z]+).*/\1/' | \
    sort | uniq -c | sort -rn | head -n 10 | \
    awk '{printf "  %5d  %s\n", $1, substr($0, index($0,$2))}'
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi

# 时间分布（如果日志包含时间戳）
echo "⏰ 错误时间分布 (按小时):"
echo ""
grep -i "error" "$LOG_FILE" | \
  grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]{2}' | \
  cut -d'T' -f2 | cut -d' ' -f2 | cut -d':' -f1 | \
  sort | uniq -c | sort -rn | head -n 10 | \
  awk '{printf "  %02d:00  ", $2; for(i=0;i<$1/10;i++) printf "█"; printf " (%d)\n", $1}' || \
  echo "  (无法解析时间戳)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 搜索常见问题
echo "🔍 常见问题检测:"
echo ""

# 数据库连接问题
DB_ERRORS=$(grep -i "database\|connection\|ECONNREFUSED" "$LOG_FILE" 2>/dev/null | wc -l | tr -d ' ')
if [ "$DB_ERRORS" -gt 0 ]; then
  echo "  ⚠️  数据库连接问题: $DB_ERRORS 次"
fi

# 内存问题
MEM_ERRORS=$(grep -i "out of memory\|heap\|OOM" "$LOG_FILE" 2>/dev/null | wc -l | tr -d ' ')
if [ "$MEM_ERRORS" -gt 0 ]; then
  echo "  ⚠️  内存问题: $MEM_ERRORS 次"
fi

# 超时问题
TIMEOUT_ERRORS=$(grep -i "timeout\|ETIMEDOUT" "$LOG_FILE" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TIMEOUT_ERRORS" -gt 0 ]; then
  echo "  ⚠️  超时问题: $TIMEOUT_ERRORS 次"
fi

# 权限问题
PERM_ERRORS=$(grep -i "permission denied\|EACCES" "$LOG_FILE" 2>/dev/null | wc -l | tr -d ' ')
if [ "$PERM_ERRORS" -gt 0 ]; then
  echo "  ⚠️  权限问题: $PERM_ERRORS 次"
fi

# 空指针/未定义
NULL_ERRORS=$(grep -i "null\|undefined\|NullPointerException" "$LOG_FILE" 2>/dev/null | wc -l | tr -d ' ')
if [ "$NULL_ERRORS" -gt 0 ]; then
  echo "  ⚠️  空指针/未定义: $NULL_ERRORS 次"
fi

echo ""
echo "✅ 分析完成"
