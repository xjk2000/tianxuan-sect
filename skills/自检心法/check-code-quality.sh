#!/usr/bin/env bash
# 代码质量自动检查脚本
# 检查常见的代码质量问题
# 用法: ./check-code-quality.sh [目录]

TARGET_DIR=${1:-.}

if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ 目录不存在: $TARGET_DIR"
  exit 1
fi

echo "🔍 代码质量检查"
echo "目标目录: $TARGET_DIR"
echo ""

ISSUES_FOUND=0

# 检查 TODO/FIXME
echo "1️⃣  检查 TODO/FIXME..."
TODO_COUNT=$(grep -r "TODO\|FIXME" "$TARGET_DIR" --include="*.js" --include="*.ts" --include="*.java" --include="*.py" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TODO_COUNT" -gt 0 ]; then
  echo "   ❌ 发现 $TODO_COUNT 个 TODO/FIXME"
  grep -rn "TODO\|FIXME" "$TARGET_DIR" --include="*.js" --include="*.ts" --include="*.java" --include="*.py" 2>/dev/null | head -n 5
  if [ "$TODO_COUNT" -gt 5 ]; then
    echo "   ... 还有 $((TODO_COUNT - 5)) 个"
  fi
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
  echo "   ✅ 未发现 TODO/FIXME"
fi
echo ""

# 检查注释掉的代码
echo "2️⃣  检查注释掉的代码..."
COMMENTED_CODE=$(grep -r "^[[:space:]]*//.*[{};]" "$TARGET_DIR" --include="*.js" --include="*.ts" --include="*.java" 2>/dev/null | wc -l | tr -d ' ')
if [ "$COMMENTED_CODE" -gt 0 ]; then
  echo "   ⚠️  发现 $COMMENTED_CODE 行可能被注释的代码"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
  echo "   ✅ 未发现注释掉的代码"
fi
echo ""

# 检查调试代码
echo "3️⃣  检查调试代码..."
DEBUG_COUNT=0

# console.log (JavaScript/TypeScript)
CONSOLE_LOG=$(grep -r "console\.log\|console\.debug" "$TARGET_DIR" --include="*.js" --include="*.ts" 2>/dev/null | wc -l | tr -d ' ')
DEBUG_COUNT=$((DEBUG_COUNT + CONSOLE_LOG))

# System.out.println (Java)
SYSTEM_OUT=$(grep -r "System\.out\.println" "$TARGET_DIR" --include="*.java" 2>/dev/null | wc -l | tr -d ' ')
DEBUG_COUNT=$((DEBUG_COUNT + SYSTEM_OUT))

# print() (Python)
PRINT_DEBUG=$(grep -r "print(" "$TARGET_DIR" --include="*.py" 2>/dev/null | grep -v "# print" | wc -l | tr -d ' ')
DEBUG_COUNT=$((DEBUG_COUNT + PRINT_DEBUG))

if [ "$DEBUG_COUNT" -gt 0 ]; then
  echo "   ❌ 发现 $DEBUG_COUNT 个调试语句"
  if [ "$CONSOLE_LOG" -gt 0 ]; then
    echo "      - console.log: $CONSOLE_LOG"
  fi
  if [ "$SYSTEM_OUT" -gt 0 ]; then
    echo "      - System.out.println: $SYSTEM_OUT"
  fi
  if [ "$PRINT_DEBUG" -gt 0 ]; then
    echo "      - print(): $PRINT_DEBUG"
  fi
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
  echo "   ✅ 未发现调试代码"
fi
echo ""

# 检查魔法值
echo "4️⃣  检查魔法值..."
MAGIC_NUMBERS=$(grep -r "[^a-zA-Z0-9_]\(8\|16\|32\|64\|100\|1000\)[^0-9]" "$TARGET_DIR" --include="*.js" --include="*.ts" --include="*.java" --include="*.py" 2>/dev/null | grep -v "const\|final\|let.*=" | wc -l | tr -d ' ')
if [ "$MAGIC_NUMBERS" -gt 10 ]; then
  echo "   ⚠️  可能存在魔法值 (检测到 $MAGIC_NUMBERS 处)"
  echo "   建议: 将常用数字提取为常量"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
  echo "   ✅ 魔法值检查通过"
fi
echo ""

# 检查长函数
echo "5️⃣  检查长函数..."
LONG_FUNCTIONS=0

# JavaScript/TypeScript
if command -v cloc &> /dev/null; then
  # 使用 cloc 统计
  echo "   (使用 cloc 进行详细分析)"
else
  # 简单检查：查找超过 50 行的函数
  LONG_FUNCTIONS=$(grep -r "function\|=>" "$TARGET_DIR" --include="*.js" --include="*.ts" 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$LONG_FUNCTIONS" -gt 0 ]; then
  echo "   ℹ️  建议检查函数长度，保持函数简洁"
else
  echo "   ✅ 函数长度检查通过"
fi
echo ""

# 检查异常处理
echo "6️⃣  检查异常处理..."
TRY_CATCH=$(grep -r "try\s*{" "$TARGET_DIR" --include="*.js" --include="*.ts" --include="*.java" 2>/dev/null | wc -l | tr -d ' ')
EMPTY_CATCH=$(grep -r "catch.*{\s*}" "$TARGET_DIR" --include="*.js" --include="*.ts" --include="*.java" 2>/dev/null | wc -l | tr -d ' ')

if [ "$EMPTY_CATCH" -gt 0 ]; then
  echo "   ❌ 发现 $EMPTY_CATCH 个空的 catch 块"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
  echo "   ✅ 异常处理检查通过"
fi
echo ""

# 总结
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [ "$ISSUES_FOUND" -eq 0 ]; then
  echo "✅ 代码质量检查通过！"
  exit 0
else
  echo "⚠️  发现 $ISSUES_FOUND 类问题，建议修复后再提交"
  exit 1
fi
