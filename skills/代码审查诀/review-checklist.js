#!/usr/bin/env node
/**
 * 代码审查清单自动检查工具
 * 用法: node review-checklist.js <文件路径>
 */

const fs = require('fs');
const path = require('path');

const filePath = process.argv[2];

if (!filePath) {
  console.error('❌ 请提供文件路径');
  console.error('用法: node review-checklist.js <文件路径>');
  process.exit(1);
}

if (!fs.existsSync(filePath)) {
  console.error(`❌ 文件不存在: ${filePath}`);
  process.exit(1);
}

const content = fs.readFileSync(filePath, 'utf-8');
const lines = content.split('\n');

console.log('🔍 代码审查清单检查');
console.log(`文件: ${filePath}`);
console.log(`行数: ${lines.length}`);
console.log('');

let issuesFound = 0;
const issues = [];

// 1. 检查命名规范
console.log('1️⃣  命名规范检查...');
const badVarNames = content.match(/\b(a|b|c|x|y|z|temp|tmp|data|info|obj)\b/g);
if (badVarNames && badVarNames.length > 5) {
  issues.push({
    type: 'naming',
    message: `发现 ${badVarNames.length} 个可能的不清晰变量名`,
    severity: 'warning'
  });
  console.log(`   ⚠️  发现 ${badVarNames.length} 个可能的不清晰变量名`);
  issuesFound++;
} else {
  console.log('   ✅ 命名规范检查通过');
}
console.log('');

// 2. 检查函数长度
console.log('2️⃣  函数长度检查...');
const functionMatches = content.matchAll(/function\s+\w+\s*\([^)]*\)\s*{/g);
let longFunctions = 0;

for (const match of functionMatches) {
  const startIndex = match.index;
  let braceCount = 1;
  let endIndex = startIndex + match[0].length;
  
  while (braceCount > 0 && endIndex < content.length) {
    if (content[endIndex] === '{') braceCount++;
    if (content[endIndex] === '}') braceCount--;
    endIndex++;
  }
  
  const functionContent = content.substring(startIndex, endIndex);
  const functionLines = functionContent.split('\n').length;
  
  if (functionLines > 50) {
    longFunctions++;
  }
}

if (longFunctions > 0) {
  issues.push({
    type: 'function-length',
    message: `发现 ${longFunctions} 个超过 50 行的函数`,
    severity: 'warning'
  });
  console.log(`   ⚠️  发现 ${longFunctions} 个超过 50 行的函数`);
  issuesFound++;
} else {
  console.log('   ✅ 函数长度检查通过');
}
console.log('');

// 3. 检查注释
console.log('3️⃣  注释检查...');
const commentLines = content.match(/\/\/.+|\/\*[\s\S]*?\*\//g);
const commentRatio = commentLines ? commentLines.length / lines.length : 0;

if (commentRatio < 0.1) {
  issues.push({
    type: 'comments',
    message: '注释比例较低 (< 10%)',
    severity: 'info'
  });
  console.log(`   ℹ️  注释比例: ${(commentRatio * 100).toFixed(1)}% (建议 > 10%)`);
} else {
  console.log(`   ✅ 注释比例: ${(commentRatio * 100).toFixed(1)}%`);
}
console.log('');

// 4. 检查错误处理
console.log('4️⃣  错误处理检查...');
const tryBlocks = (content.match(/try\s*{/g) || []).length;
const catchBlocks = (content.match(/catch\s*\(/g) || []).length;
const emptyCatch = (content.match(/catch\s*\([^)]*\)\s*{\s*}/g) || []).length;

if (emptyCatch > 0) {
  issues.push({
    type: 'error-handling',
    message: `发现 ${emptyCatch} 个空的 catch 块`,
    severity: 'error'
  });
  console.log(`   ❌ 发现 ${emptyCatch} 个空的 catch 块`);
  issuesFound++;
} else if (tryBlocks === catchBlocks) {
  console.log(`   ✅ 错误处理检查通过 (${tryBlocks} 个 try-catch)`);
} else {
  console.log(`   ⚠️  try/catch 数量不匹配`);
}
console.log('');

// 5. 检查安全问题
console.log('5️⃣  安全检查...');
const securityIssues = [];

// SQL 注入风险
if (content.includes('SELECT') && content.includes('+')) {
  securityIssues.push('可能存在 SQL 注入风险（字符串拼接）');
}

// eval 使用
if (content.includes('eval(')) {
  securityIssues.push('使用了 eval()，存在安全风险');
}

// innerHTML 使用
if (content.includes('innerHTML')) {
  securityIssues.push('使用了 innerHTML，可能存在 XSS 风险');
}

if (securityIssues.length > 0) {
  securityIssues.forEach(issue => {
    issues.push({
      type: 'security',
      message: issue,
      severity: 'error'
    });
    console.log(`   ❌ ${issue}`);
  });
  issuesFound++;
} else {
  console.log('   ✅ 未发现明显的安全问题');
}
console.log('');

// 6. 检查性能问题
console.log('6️⃣  性能检查...');
const perfIssues = [];

// 循环中的函数定义
if (content.match(/for\s*\([^)]*\)\s*{[^}]*function/)) {
  perfIssues.push('在循环中定义函数');
}

// 多次 DOM 查询
const domQueries = (content.match(/document\.querySelector|document\.getElementById/g) || []).length;
if (domQueries > 10) {
  perfIssues.push(`频繁的 DOM 查询 (${domQueries} 次)`);
}

if (perfIssues.length > 0) {
  perfIssues.forEach(issue => {
    issues.push({
      type: 'performance',
      message: issue,
      severity: 'warning'
    });
    console.log(`   ⚠️  ${issue}`);
  });
} else {
  console.log('   ✅ 未发现明显的性能问题');
}
console.log('');

// 总结
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('');

if (issues.length === 0) {
  console.log('✅ 代码审查通过！');
  process.exit(0);
} else {
  console.log(`发现 ${issues.length} 个问题:`);
  console.log('');
  
  const errors = issues.filter(i => i.severity === 'error');
  const warnings = issues.filter(i => i.severity === 'warning');
  const infos = issues.filter(i => i.severity === 'info');
  
  if (errors.length > 0) {
    console.log(`❌ 错误 (${errors.length}):`);
    errors.forEach(e => console.log(`   - ${e.message}`));
    console.log('');
  }
  
  if (warnings.length > 0) {
    console.log(`⚠️  警告 (${warnings.length}):`);
    warnings.forEach(w => console.log(`   - ${w.message}`));
    console.log('');
  }
  
  if (infos.length > 0) {
    console.log(`ℹ️  建议 (${infos.length}):`);
    infos.forEach(i => console.log(`   - ${i.message}`));
    console.log('');
  }
  
  process.exit(errors.length > 0 ? 1 : 0);
}
