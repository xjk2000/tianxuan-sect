#!/usr/bin/env bash
# 检查数据库状态
# 支持: PostgreSQL, MySQL, MongoDB
# 用法: ./check-db-state.sh [数据库类型]

DB_TYPE=${1:-"auto"}

echo "🔍 检查数据库状态"
echo ""

# 自动检测数据库类型
if [ "$DB_TYPE" = "auto" ]; then
  if command -v psql &> /dev/null && [ -n "$DATABASE_URL" ]; then
    DB_TYPE="postgres"
  elif command -v mysql &> /dev/null; then
    DB_TYPE="mysql"
  elif command -v mongo &> /dev/null; then
    DB_TYPE="mongo"
  else
    echo "❌ 无法自动检测数据库类型"
    echo ""
    echo "用法: $0 [postgres|mysql|mongo]"
    exit 1
  fi
fi

echo "数据库类型: $DB_TYPE"
echo ""

case "$DB_TYPE" in
  postgres|postgresql)
    DB_URL=${DATABASE_URL:-"postgresql://localhost:5432/mydb"}
    echo "连接: $DB_URL"
    echo ""
    
    # 检查连接
    echo "1️⃣  检查连接..."
    if psql "$DB_URL" -c "SELECT version();" > /dev/null 2>&1; then
      echo "   ✅ 数据库连接正常"
      VERSION=$(psql "$DB_URL" -t -c "SELECT version();" | head -n1 | xargs)
      echo "   版本: $VERSION"
    else
      echo "   ❌ 数据库连接失败"
      exit 1
    fi
    echo ""
    
    # 检查表数量
    echo "2️⃣  检查表..."
    TABLE_COUNT=$(psql "$DB_URL" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | xargs)
    echo "   表数量: $TABLE_COUNT"
    echo ""
    
    # 检查数据量
    echo "3️⃣  数据量统计 (Top 10):"
    psql "$DB_URL" -c "
      SELECT 
        schemaname,
        tablename,
        n_live_tup as row_count
      FROM pg_stat_user_tables
      ORDER BY n_live_tup DESC
      LIMIT 10;
    "
    echo ""
    
    # 检查慢查询
    echo "4️⃣  慢查询 (平均时间 > 1s):"
    psql "$DB_URL" -c "
      SELECT 
        LEFT(query, 60) as query,
        calls,
        ROUND(total_exec_time::numeric, 2) as total_ms,
        ROUND(mean_exec_time::numeric, 2) as mean_ms
      FROM pg_stat_statements
      WHERE mean_exec_time > 1000
      ORDER BY mean_exec_time DESC
      LIMIT 5;
    " 2>/dev/null || echo "   (pg_stat_statements 未启用)"
    ;;
    
  mysql)
    echo "连接: MySQL"
    echo ""
    
    # 检查连接
    echo "1️⃣  检查连接..."
    if mysql -e "SELECT VERSION();" > /dev/null 2>&1; then
      echo "   ✅ 数据库连接正常"
      VERSION=$(mysql -s -N -e "SELECT VERSION();")
      echo "   版本: $VERSION"
    else
      echo "   ❌ 数据库连接失败"
      exit 1
    fi
    echo ""
    
    # 检查数据库
    echo "2️⃣  数据库列表:"
    mysql -e "SHOW DATABASES;"
    echo ""
    
    # 检查表数量
    echo "3️⃣  表统计:"
    mysql -e "
      SELECT 
        table_schema,
        COUNT(*) as table_count,
        SUM(table_rows) as total_rows
      FROM information_schema.tables
      WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
      GROUP BY table_schema;
    "
    echo ""
    
    # 检查慢查询
    echo "4️⃣  慢查询日志状态:"
    mysql -e "SHOW VARIABLES LIKE 'slow_query%';"
    ;;
    
  mongo|mongodb)
    echo "连接: MongoDB"
    echo ""
    
    # 检查连接
    echo "1️⃣  检查连接..."
    if mongo --eval "db.version()" > /dev/null 2>&1; then
      echo "   ✅ 数据库连接正常"
      VERSION=$(mongo --quiet --eval "db.version()")
      echo "   版本: $VERSION"
    else
      echo "   ❌ 数据库连接失败"
      exit 1
    fi
    echo ""
    
    # 检查数据库
    echo "2️⃣  数据库列表:"
    mongo --quiet --eval "db.adminCommand('listDatabases').databases.forEach(function(d) { print(d.name + ' - ' + (d.sizeOnDisk/1024/1024).toFixed(2) + ' MB'); })"
    echo ""
    
    # 检查集合
    echo "3️⃣  集合统计 (当前数据库):"
    mongo --quiet --eval "db.getCollectionNames().forEach(function(c) { var stats = db[c].stats(); print(c + ': ' + stats.count + ' documents, ' + (stats.size/1024/1024).toFixed(2) + ' MB'); })"
    ;;
    
  *)
    echo "❌ 不支持的数据库类型: $DB_TYPE"
    echo ""
    echo "支持的类型: postgres, mysql, mongo"
    exit 1
    ;;
esac

echo ""
echo "✅ 检查完成"
