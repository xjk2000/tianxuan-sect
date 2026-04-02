# 命令安全判断指南

## 概述

在使用 `run_command` 工具执行命令时，必须正确设置 `SafeToAutoRun` 参数，避免：
- ❌ 简单只读命令频繁要求用户确认（影响效率）
- ❌ 危险命令自动执行（破坏数据安全）

## 核心原则

**`SafeToAutoRun: true` 的判断标准：命令是否有破坏性副作用**

- ✅ **安全命令**：只读、无副作用、不修改文件系统、不发起网络请求
- ❌ **危险命令**：写入文件、删除数据、安装依赖、修改配置、发起外部请求

---

## 安全命令清单（SafeToAutoRun: true）

### 文件系统只读操作

```bash
# ✅ 列出目录内容
ls -la 天玄宗/宗门任务榜/
find . -name "*.md" -type f
tree -L 2

# ✅ 查看文件内容
cat package.json
head -n 20 README.md
tail -f logs/app.log

# ✅ 文本搜索
grep -r "import" src/
rg "TODO" --type java
ag "function" .

# ✅ 文件统计
wc -l src/**/*.ts
du -sh node_modules/
stat pom.xml

# ✅ 检查文件存在性
[ -f "package.json" ] && echo "存在" || echo "不存在"
test -d "天玄宗" && echo "目录存在"
```

### 进程和系统信息查询

```bash
# ✅ 查看进程
ps aux | grep java
pgrep -f "spring-boot"
lsof -i :8080

# ✅ 系统信息
uname -a
whoami
pwd
env | grep NODE
```

### 版本和工具检查

```bash
# ✅ 检查工具版本
node --version
npm --version
mvn --version
java -version
git --version
python --version

# ✅ 检查依赖状态（只读）
npm list --depth=0
mvn dependency:tree | head -50
pip list
```

### Git 只读操作

```bash
# ✅ 查看状态
git status
git log --oneline -10
git diff
git branch -a
git remote -v
git show HEAD

# ✅ 查看历史
git log --graph --oneline --all -20
git blame src/main.ts
```

### 数据库只读查询（需确认连接信息安全）

```bash
# ✅ 只读查询（前提：连接信息已配置，且查询无副作用）
mysql -e "SELECT COUNT(*) FROM users;" mydb
psql -c "SELECT version();"
```

---

## 危险命令清单（SafeToAutoRun: false）

### 文件系统写入/删除

```bash
# ❌ 创建/修改文件
echo "content" > file.txt
touch new-file.md
mkdir new-dir
cp src dest
mv old new

# ❌ 删除操作
rm -rf node_modules/
rm file.txt
rmdir old-dir/
```

### 依赖安装/更新

```bash
# ❌ 安装依赖
npm install
npm install express
pnpm add lodash
mvn clean install
pip install requests
cargo build

# ❌ 更新依赖
npm update
mvn versions:use-latest-versions
pip install --upgrade pip
```

### 构建和编译

```bash
# ❌ 构建项目
npm run build
mvn package
gradle build
cargo build --release
make
```

### 启动服务/进程

```bash
# ❌ 启动服务
npm run dev
mvn spring-boot:run
java -jar app.jar
python manage.py runserver
docker-compose up -d
```

### Git 写入操作

```bash
# ❌ 修改仓库状态
git add .
git commit -m "message"
git push
git pull
git merge
git rebase
git reset --hard
git clean -fd
```

### 数据库写入操作

```bash
# ❌ 修改数据
mysql -e "DELETE FROM users WHERE id=1;" mydb
psql -c "DROP TABLE old_table;"
```

### 网络请求

```bash
# ❌ 外部请求
curl -X POST https://api.example.com/data
wget https://example.com/file.zip
ssh user@remote "command"
scp file.txt user@remote:/path/
```

### 系统配置修改

```bash
# ❌ 修改系统配置
sudo apt install package
brew install tool
chmod +x script.sh
chown user:group file
export PATH=$PATH:/new/path
```

---

## 边界情况判断

### 1. 组合命令

```bash
# ✅ 所有子命令都安全 → SafeToAutoRun: true
ls -la && cat package.json && grep "name" pom.xml

# ❌ 任一子命令危险 → SafeToAutoRun: false
ls -la && npm install  # 包含 npm install，必须 false
```

### 2. 管道命令

```bash
# ✅ 只读管道 → SafeToAutoRun: true
cat file.txt | grep "error" | wc -l
ps aux | grep java | awk '{print $2}'

# ❌ 管道包含写入 → SafeToAutoRun: false
cat data.txt | sort > sorted.txt  # 写入文件，必须 false
```

### 3. 条件执行

```bash
# ✅ 条件只读 → SafeToAutoRun: true
[ -f "package.json" ] && cat package.json || echo "不存在"

# ❌ 条件包含写入 → SafeToAutoRun: false
[ ! -d "dist" ] && mkdir dist  # 创建目录，必须 false
```

### 4. 测试/验证命令

```bash
# ❌ 运行测试（可能修改测试数据库、生成报告文件）
npm test
mvn test
pytest
cargo test

# 原则：测试命令虽然"看起来只读"，但可能有副作用（生成覆盖率报告、修改测试数据库），
# 除非明确知道测试无副作用，否则默认 SafeToAutoRun: false
```

### 5. 只读但敏感的命令

```bash
# ⚠️ 虽然只读，但可能暴露敏感信息 → 建议 SafeToAutoRun: false
cat ~/.ssh/id_rsa
env | grep PASSWORD
cat .env

# 原则：涉及密钥、密码、token 的命令，即使只读也建议用户确认
```

---

## 实战示例

### ✅ 正确示例：只读命令自动运行

```typescript
// 检查项目结构
await runCommand({
  CommandLine: "ls -la 天玄宗/宗门任务榜/",
  Cwd: projectRoot,
  SafeToAutoRun: true,  // ✅ 只读，自动运行
  Blocking: true
});

// 查看 package.json
await runCommand({
  CommandLine: "cat package.json | grep '\"name\"'",
  Cwd: projectRoot,
  SafeToAutoRun: true,  // ✅ 只读管道，自动运行
  Blocking: true
});

// 检查 Java 进程
await runCommand({
  CommandLine: "ps aux | grep java",
  SafeToAutoRun: true,  // ✅ 只读，自动运行
  Blocking: true
});
```

### ❌ 错误示例：危险命令必须用户确认

```typescript
// 安装依赖
await runCommand({
  CommandLine: "npm install",
  Cwd: projectRoot,
  SafeToAutoRun: false,  // ✅ 正确：写入 node_modules，需确认
  Blocking: true
});

// 删除文件
await runCommand({
  CommandLine: "rm -rf dist/",
  Cwd: projectRoot,
  SafeToAutoRun: false,  // ✅ 正确：删除操作，需确认
  Blocking: true
});

// 启动服务
await runCommand({
  CommandLine: "npm run dev",
  Cwd: projectRoot,
  SafeToAutoRun: false,  // ✅ 正确：启动进程，需确认
  Blocking: false,
  WaitMsBeforeAsync: 3000
});
```

---

## 快速决策树

```
命令是否修改文件系统？
├─ 是 → SafeToAutoRun: false
└─ 否 → 命令是否安装/更新依赖？
    ├─ 是 → SafeToAutoRun: false
    └─ 否 → 命令是否启动服务/进程？
        ├─ 是 → SafeToAutoRun: false
        └─ 否 → 命令是否发起网络请求？
            ├─ 是 → SafeToAutoRun: false
            └─ 否 → 命令是否涉及敏感信息？
                ├─ 是 → SafeToAutoRun: false（建议）
                └─ 否 → SafeToAutoRun: true ✅
```

---

## 常见误区

### ❌ 误区1：认为"快速命令"就是安全命令

```bash
# ❌ 错误：虽然执行快，但有副作用
rm temp.txt  # SafeToAutoRun: false（删除文件）
```

### ❌ 误区2：认为"常用命令"就可以自动运行

```bash
# ❌ 错误：npm install 虽然常用，但会修改 node_modules
npm install  # SafeToAutoRun: false
```

### ❌ 误区3：忽略管道/重定向的副作用

```bash
# ❌ 错误：重定向写入文件
cat data.txt > output.txt  # SafeToAutoRun: false（写入文件）
```

---

## 总结

**核心判断标准：命令是否有副作用**

- ✅ **SafeToAutoRun: true**：只读、无副作用、不修改任何状态
- ❌ **SafeToAutoRun: false**：写入、删除、安装、启动、网络请求、敏感信息

**遵循原则：宁可保守，不可冒进**

- 不确定时，默认 `SafeToAutoRun: false`
- 只有 100% 确定安全时，才设置 `SafeToAutoRun: true`
