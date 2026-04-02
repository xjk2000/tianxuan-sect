---
name: 命令安全检查术
description: 自动判断命令是否安全，返回 SafeToAutoRun 建议值
---

# 命令安全检查术

## 技能定位

在执行任何 `run_command` 之前，**必须先调用此技能**进行安全判断，获取 `SafeToAutoRun` 的正确值。

## 使用场景

**所有需要执行命令的 Agent（宗主、阵堂、器堂、丹堂、执法堂、藏经阁、杂役弟子）在调用 `run_command` 前必须先调用此技能。**

## 核心判断逻辑

### 快速决策树

```
命令是否修改文件系统（写入/删除/创建）？
├─ 是 → SafeToAutoRun: false
└─ 否 → 命令是否安装/更新依赖？
    ├─ 是 → SafeToAutoRun: false
    └─ 否 → 命令是否启动服务/进程？
        ├─ 是 → SafeToAutoRun: false
        └─ 否 → 命令是否发起网络请求（curl/wget/ssh/scp）？
            ├─ 是 → SafeToAutoRun: false
            └─ 否 → 命令是否涉及敏感信息（密钥/密码/token）？
                ├─ 是 → SafeToAutoRun: false（建议）
                └─ 否 → SafeToAutoRun: true ✅
```

### 安全命令模式（SafeToAutoRun: true）

**文件系统只读**：
```bash
ls, cat, head, tail, less, more, find, tree, stat, file, wc, du
grep, rg, ag, ack
[ -f file ], [ -d dir ], test -e
```

**进程和系统查询**：
```bash
ps, pgrep, lsof, netstat, ss
whoami, pwd, uname, env, printenv
top, htop, free, df
```

**版本检查**：
```bash
node --version, npm --version, java -version, mvn --version
python --version, pip --version, go version, cargo --version
git --version, docker --version
```

**Git 只读操作**：
```bash
git status, git log, git diff, git show, git branch, git remote
git blame, git reflog
```

**依赖查询（只读）**：
```bash
npm list, pip list, mvn dependency:tree
cargo tree, go list
```

**数据库只读查询**（前提：连接信息安全）：
```sql
SELECT, SHOW, DESCRIBE, EXPLAIN
```

### 危险命令模式（SafeToAutoRun: false）

**文件系统写入**：
```bash
echo > file, touch, mkdir, cp, mv, rm, rmdir
chmod, chown, ln
```

**依赖安装/更新**：
```bash
npm install, npm update, npm ci
pip install, pip install --upgrade
mvn install, mvn clean install
cargo build, cargo install
apt install, brew install, yum install
```

**构建编译**：
```bash
npm run build, npm run compile
mvn package, mvn compile
gradle build, make, cmake
cargo build, go build
```

**启动服务**：
```bash
npm run dev, npm start
mvn spring-boot:run, java -jar
python manage.py runserver
docker-compose up, docker run
```

**Git 写入操作**：
```bash
git add, git commit, git push, git pull
git merge, git rebase, git reset, git clean
git checkout, git switch, git stash
```

**数据库写入**：
```sql
INSERT, UPDATE, DELETE, DROP, CREATE, ALTER
TRUNCATE, GRANT, REVOKE
```

**网络请求**：
```bash
curl -X POST, wget, ssh, scp, rsync
```

**测试命令**（可能有副作用）：
```bash
npm test, mvn test, pytest, cargo test
npm run e2e, npm run integration
```

### 边界情况处理

**1. 管道命令**
```bash
# ✅ 所有子命令都安全 → true
cat file.txt | grep "error" | wc -l

# ❌ 任一子命令危险 → false
cat data.txt | sort > output.txt  # 写入文件
ls -la && npm install              # 包含 npm install
```

**2. 条件执行**
```bash
# ✅ 条件只读 → true
[ -f "package.json" ] && cat package.json

# ❌ 条件包含写入 → false
[ ! -d "dist" ] && mkdir dist
```

**3. 重定向**
```bash
# ❌ 任何重定向写入 → false
command > file.txt
command >> file.txt
command 2> error.log
```

## 使用方法

### 标准调用流程

```markdown
# 步骤1：调用命令安全检查术
@命令安全检查术 判断以下命令是否安全：
```bash
ls -la 天玄宗/宗门任务榜/
```

# 步骤2：根据返回结果设置 SafeToAutoRun
命令安全检查术: 该命令为只读操作（ls），SafeToAutoRun: true

# 步骤3：执行命令
await runCommand({
  CommandLine: "ls -la 天玄宗/宗门任务榜/",
  SafeToAutoRun: true,  // 使用检查术返回的值
  Blocking: true
});
```

### 批量检查

```markdown
@命令安全检查术 判断以下命令列表的安全性：
1. `cat package.json`
2. `npm install`
3. `git status`
4. `mvn clean package`

命令安全检查术:
1. cat package.json → SafeToAutoRun: true（只读）
2. npm install → SafeToAutoRun: false（安装依赖）
3. git status → SafeToAutoRun: true（只读）
4. mvn clean package → SafeToAutoRun: false（构建打包）
```

## 输出格式

### 单个命令判断

```
命令: `ls -la`
判断: 只读操作（列出目录）
SafeToAutoRun: true
理由: 不修改文件系统，无副作用
```

### 批量命令判断

```
1. `cat file.txt` → SafeToAutoRun: true（只读）
2. `npm install` → SafeToAutoRun: false（安装依赖）
3. `git status` → SafeToAutoRun: true（只读）
```

### 边界情况说明

```
命令: `npm test`
判断: 测试命令（可能有副作用）
SafeToAutoRun: false
理由: 测试可能生成覆盖率报告、修改测试数据库
建议: 需要用户确认
```

## 特殊规则

### 1. 不确定时默认保守

```
命令: `custom-script.sh`
判断: 未知脚本
SafeToAutoRun: false
理由: 无法确定脚本内容，默认需要用户确认
```

### 2. 敏感信息命令

```
命令: `cat ~/.ssh/id_rsa`
判断: 读取敏感文件
SafeToAutoRun: false（建议）
理由: 虽然只读，但涉及密钥，建议用户确认
```

### 3. 组合命令拆分判断

```
命令: `ls -la && cat package.json && npm install`
拆分判断:
- ls -la → true
- cat package.json → true
- npm install → false
综合判断: SafeToAutoRun: false（任一子命令危险则整体危险）
```

## 实战示例

### 示例1：后端开发场景

```markdown
阵堂长老: @命令安全检查术 判断以下命令：
1. `cat pom.xml`
2. `mvn dependency:tree | head -50`
3. `mvn clean install`
4. `ps aux | grep java`

命令安全检查术:
1. cat pom.xml → SafeToAutoRun: true（只读文件）
2. mvn dependency:tree | head -50 → SafeToAutoRun: true（只读查询）
3. mvn clean install → SafeToAutoRun: false（构建安装）
4. ps aux | grep java → SafeToAutoRun: true（只读进程查询）
```

### 示例2：前端开发场景

```markdown
器堂长老: @命令安全检查术 判断：
1. `npm list --depth=0`
2. `npm install lodash`
3. `npm run build`

命令安全检查术:
1. npm list --depth=0 → SafeToAutoRun: true（只读依赖列表）
2. npm install lodash → SafeToAutoRun: false（安装依赖）
3. npm run build → SafeToAutoRun: false（构建项目）
```

### 示例3：数据库查询场景

```markdown
丹堂长老: @命令安全检查术 判断：
1. `mysql -e "SELECT COUNT(*) FROM users;" mydb`
2. `mysql -e "DELETE FROM temp_table WHERE id < 100;" mydb`

命令安全检查术:
1. SELECT COUNT(*) → SafeToAutoRun: true（只读查询）
2. DELETE FROM → SafeToAutoRun: false（删除数据）
```

### 示例4：Git 操作场景

```markdown
执法堂长老: @命令安全检查术 判断：
1. `git status`
2. `git diff src/main.ts`
3. `git add .`
4. `git commit -m "fix bug"`

命令安全检查术:
1. git status → SafeToAutoRun: true（只读状态）
2. git diff src/main.ts → SafeToAutoRun: true（只读差异）
3. git add . → SafeToAutoRun: false（修改暂存区）
4. git commit -m "fix bug" → SafeToAutoRun: false（提交变更）
```

## 常见错误示例

### ❌ 错误1：未调用检查术直接猜测

```markdown
# 错误做法
阵堂长老: 我觉得 ls 命令应该是安全的，直接设置 SafeToAutoRun: true

# 正确做法
阵堂长老: @命令安全检查术 判断命令 `ls -la` 是否安全
命令安全检查术: SafeToAutoRun: true（只读）
阵堂长老: 收到，执行命令...
```

### ❌ 错误2：忽略管道中的危险命令

```markdown
# 错误判断
命令: `cat data.txt | sort > output.txt`
错误判断: cat 是只读，SafeToAutoRun: true

# 正确判断
命令: `cat data.txt | sort > output.txt`
正确判断: 包含重定向写入 > output.txt，SafeToAutoRun: false
```

### ❌ 错误3：认为测试命令是安全的

```markdown
# 错误判断
命令: `npm test`
错误判断: 只是运行测试，SafeToAutoRun: true

# 正确判断
命令: `npm test`
正确判断: 测试可能生成报告、修改测试数据库，SafeToAutoRun: false
```

## 总结

**核心原则：宁可保守，不可冒进**

- ✅ 100% 确定安全（只读、无副作用）→ `SafeToAutoRun: true`
- ❌ 任何不确定或可能有副作用 → `SafeToAutoRun: false`
- 🔍 所有 Agent 执行命令前**必须先调用此技能**进行判断
