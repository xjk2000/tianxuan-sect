# 调试工具脚本集合

本文档提供常用的调试脚本和工具。

## 查找测试污染者

当测试创建了不应该存在的文件或状态时使用。

### find-polluter.sh

```bash
#!/usr/bin/env bash
# 查找哪个测试创建了不需要的文件
# 用法: ./find-polluter.sh <要检查的文件> <测试模式>

set -e

if [ $# -ne 2 ]; then
  echo "用法: $0 <要检查的文件> <测试模式>"
  echo "示例: $0 '.git' 'src/**/*.test.ts'"
  exit 1
fi

POLLUTION_CHECK="$1"
TEST_PATTERN="$2"

echo "🔍 查找创建以下内容的测试: $POLLUTION_CHECK"
echo "测试模式: $TEST_PATTERN"
echo ""

# 获取测试文件列表
TEST_FILES=$(find . -path "$TEST_PATTERN" | sort)
TOTAL=$(echo "$TEST_FILES" | wc -l | tr -d ' ')

echo "找到 $TOTAL 个测试文件"
echo ""

COUNT=0
for TEST_FILE in $TEST_FILES; do
  COUNT=$((COUNT + 1))

  # 如果污染已存在则跳过
  if [ -e "$POLLUTION_CHECK" ]; then
    echo "⚠️  测试 $COUNT/$TOTAL 之前污染已存在"
    echo "   跳过: $TEST_FILE"
    continue
  fi

  echo "[$COUNT/$TOTAL] 测试: $TEST_FILE"

  # 运行测试
  npm test "$TEST_FILE" > /dev/null 2>&1 || true

  # 检查污染是否出现
  if [ -e "$POLLUTION_CHECK" ]; then
    echo ""
    echo "🎯 找到污染者！"
    echo "   测试: $TEST_FILE"
    echo "   创建了: $POLLUTION_CHECK"
    echo ""
    echo "污染详情:"
    ls -la "$POLLUTION_CHECK"
    echo ""
    echo "调查方法:"
    echo "  npm test $TEST_FILE    # 只运行这个测试"
    echo "  cat $TEST_FILE         # 查看测试代码"
    exit 1
  fi
done

echo ""
echo "✅ 未找到污染者 - 所有测试都是干净的！"
exit 0
```

## 日志分析脚本

### analyze-logs.sh

```bash
#!/usr/bin/env bash
# 分析应用日志，提取错误和警告

LOG_FILE=${1:-"app.log"}

if [ ! -f "$LOG_FILE" ]; then
  echo "❌ 日志文件不存在: $LOG_FILE"
  exit 1
fi

echo "📊 分析日志: $LOG_FILE"
echo ""

# 统计错误数量
ERROR_COUNT=$(grep -i "error" "$LOG_FILE" | wc -l | tr -d ' ')
echo "错误数量: $ERROR_COUNT"

# 统计警告数量
WARN_COUNT=$(grep -i "warn" "$LOG_FILE" | wc -l | tr -d ' ')
echo "警告数量: $WARN_COUNT"

echo ""
echo "最近的错误:"
grep -i "error" "$LOG_FILE" | tail -n 10

echo ""
echo "错误类型分布:"
grep -i "error" "$LOG_FILE" | \
  sed -E 's/.*Error: ([^:]+).*/\1/' | \
  sort | uniq -c | sort -rn | head -n 10
```

## 数据库查询脚本

### check-db-state.sh

```bash
#!/usr/bin/env bash
# 检查数据库状态

DB_URL=${DATABASE_URL:-"postgresql://localhost:5432/mydb"}

echo "🔍 检查数据库状态"
echo "数据库: $DB_URL"
echo ""

# 检查连接
echo "1. 检查连接..."
psql "$DB_URL" -c "SELECT version();" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "   ✅ 数据库连接正常"
else
  echo "   ❌ 数据库连接失败"
  exit 1
fi

# 检查表数量
echo "2. 检查表..."
TABLE_COUNT=$(psql "$DB_URL" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")
echo "   表数量: $TABLE_COUNT"

# 检查数据量
echo "3. 检查数据量..."
psql "$DB_URL" -c "
  SELECT 
    schemaname,
    tablename,
    n_live_tup as row_count
  FROM pg_stat_user_tables
  ORDER BY n_live_tup DESC
  LIMIT 10;
"

# 检查慢查询
echo "4. 检查慢查询..."
psql "$DB_URL" -c "
  SELECT 
    query,
    calls,
    total_time,
    mean_time
  FROM pg_stat_statements
  WHERE mean_time > 1000
  ORDER BY mean_time DESC
  LIMIT 5;
"
```

## 性能分析脚本

### profile-api.sh

```bash
#!/usr/bin/env bash
# 分析 API 性能

API_URL=${1:-"http://localhost:3000"}
ENDPOINT=${2:-"/api/users"}
REQUESTS=${3:-100}

echo "🚀 性能测试"
echo "URL: $API_URL$ENDPOINT"
echo "请求数: $REQUESTS"
echo ""

# 使用 ab (Apache Bench)
ab -n "$REQUESTS" -c 10 -g results.tsv "$API_URL$ENDPOINT"

# 分析结果
echo ""
echo "📊 结果分析:"

# 计算百分位数
awk -F'\t' 'NR>1 {print $5}' results.tsv | \
  sort -n | \
  awk '
    BEGIN { count=0; sum=0; }
    {
      times[count++] = $1;
      sum += $1;
    }
    END {
      print "平均响应时间:", sum/count, "ms";
      print "P50:", times[int(count*0.5)], "ms";
      print "P95:", times[int(count*0.95)], "ms";
      print "P99:", times[int(count*0.99)], "ms";
      print "最大:", times[count-1], "ms";
    }
  '

rm results.tsv
```

## 内存泄漏检测

### check-memory-leak.sh

```bash
#!/usr/bin/env bash
# 检测 Node.js 内存泄漏

PID=${1}

if [ -z "$PID" ]; then
  echo "用法: $0 <进程ID>"
  exit 1
fi

echo "🔍 监控进程内存: PID=$PID"
echo ""

# 每秒记录一次内存使用
for i in {1..60}; do
  MEMORY=$(ps -o rss= -p "$PID" | tr -d ' ')
  MEMORY_MB=$((MEMORY / 1024))
  echo "[$i/60] 内存使用: ${MEMORY_MB}MB"
  sleep 1
done

echo ""
echo "如果内存持续增长，可能存在内存泄漏"
echo "使用 node --inspect 和 Chrome DevTools 进一步分析"
```

## 使用示例

### 查找测试污染

```bash
# 查找创建 .git 目录的测试
./find-polluter.sh '.git' 'src/**/*.test.ts'

# 查找创建临时文件的测试
./find-polluter.sh 'temp.txt' 'test/**/*.test.js'
```

### 分析日志

```bash
# 分析默认日志文件
./analyze-logs.sh

# 分析指定日志文件
./analyze-logs.sh /var/log/app.log
```

### 检查数据库

```bash
# 使用默认数据库 URL
./check-db-state.sh

# 使用指定数据库
DATABASE_URL="postgresql://user:pass@host:5432/db" ./check-db-state.sh
```

### 性能测试

```bash
# 测试默认端点
./profile-api.sh

# 测试指定端点
./profile-api.sh http://localhost:3000 /api/users/123 1000
```

### 内存泄漏检测

```bash
# 找到进程 ID
ps aux | grep node

# 监控内存
./check-memory-leak.sh 12345
```

## 注意事项

1. **权限** - 某些脚本需要执行权限：`chmod +x *.sh`
2. **依赖** - 确保安装了必要的工具（ab, psql 等）
3. **环境变量** - 某些脚本依赖环境变量（DATABASE_URL 等）
4. **生产环境** - 在生产环境使用前先在测试环境验证
