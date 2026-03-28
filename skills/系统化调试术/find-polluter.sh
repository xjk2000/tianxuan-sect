#!/usr/bin/env bash
# 查找哪个测试创建了不需要的文件或状态
# 用法: ./find-polluter.sh <要检查的文件> <测试模式>
# 示例: ./find-polluter.sh '.git' 'src/**/*.test.ts'

set -e

if [ $# -ne 2 ]; then
  echo "用法: $0 <要检查的文件> <测试模式>"
  echo "示例: $0 '.git' 'src/**/*.test.ts'"
  echo "      $0 'temp.txt' 'test/**/*.test.js'"
  exit 1
fi

POLLUTION_CHECK="$1"
TEST_PATTERN="$2"

echo "🔍 查找创建以下内容的测试: $POLLUTION_CHECK"
echo "测试模式: $TEST_PATTERN"
echo ""

# 获取测试文件列表
TEST_FILES=$(find . -path "$TEST_PATTERN" 2>/dev/null | sort)

if [ -z "$TEST_FILES" ]; then
  echo "❌ 未找到匹配的测试文件"
  exit 1
fi

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

  # 运行测试（根据项目类型调整命令）
  if [ -f "package.json" ]; then
    npm test "$TEST_FILE" > /dev/null 2>&1 || true
  elif [ -f "pom.xml" ]; then
    mvn test -Dtest="$TEST_FILE" > /dev/null 2>&1 || true
  elif [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
    pytest "$TEST_FILE" > /dev/null 2>&1 || true
  else
    echo "⚠️  无法识别项目类型，跳过测试"
    continue
  fi

  # 检查污染是否出现
  if [ -e "$POLLUTION_CHECK" ]; then
    echo ""
    echo "🎯 找到污染者！"
    echo "   测试: $TEST_FILE"
    echo "   创建了: $POLLUTION_CHECK"
    echo ""
    echo "污染详情:"
    ls -la "$POLLUTION_CHECK" 2>/dev/null || echo "   (文件已被删除或不可访问)"
    echo ""
    echo "调查方法:"
    if [ -f "package.json" ]; then
      echo "  npm test $TEST_FILE    # 只运行这个测试"
    elif [ -f "pom.xml" ]; then
      echo "  mvn test -Dtest=$TEST_FILE"
    elif [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
      echo "  pytest $TEST_FILE"
    fi
    echo "  cat $TEST_FILE         # 查看测试代码"
    exit 1
  fi
done

echo ""
echo "✅ 未找到污染者 - 所有测试都是干净的！"
exit 0
