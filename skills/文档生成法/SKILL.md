---
name: 文档生成法
description: 文档生成技能 - 自动生成和维护灵脉信息文档
user-invocable: false
---

# 文档生成法

## 技能说明

为天玄宗任务自动生成和维护高质量的灵脉信息文档。

## 核心原则

**文档即代码** - 文档和代码同步更新，保持一致性。

## 文档类型

### 1. API 文档

#### 后端 API 文档

**格式**: OpenAPI/Swagger

```yaml
openapi: 3.0.0
info:
  title: 用户管理 API
  version: 1.0.0
  description: 用户注册、登录、管理相关接口

paths:
  /api/users/register:
    post:
      summary: 用户注册
      description: 创建新用户账号
      tags:
        - 用户管理
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - username
                - email
                - password
              properties:
                username:
                  type: string
                  minLength: 3
                  maxLength: 50
                  description: 用户名
                email:
                  type: string
                  format: email
                  description: 邮箱地址
                password:
                  type: string
                  minLength: 8
                  description: 密码
      responses:
        '200':
          description: 注册成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  code:
                    type: integer
                    example: 200
                  message:
                    type: string
                    example: 注册成功
                  data:
                    type: object
                    properties:
                      userId:
                        type: string
                        example: "12345"
        '400':
          description: 参数错误
          content:
            application/json:
              schema:
                type: object
                properties:
                  code:
                    type: integer
                    example: 400
                  message:
                    type: string
                    example: 用户名不能为空
```

#### 前端组件文档

**格式**: JSDoc/TSDoc

```javascript
/**
 * 用户列表组件
 * 
 * @component
 * @example
 * ```jsx
 * <UserList 
 *   users={users} 
 *   onUserClick={handleUserClick}
 * />
 * ```
 */

/**
 * Props 定义
 * 
 * @typedef {Object} UserListProps
 * @property {User[]} users - 用户列表
 * @property {(user: User) => void} onUserClick - 用户点击回调
 * @property {boolean} [loading=false] - 加载状态
 */

/**
 * @param {UserListProps} props
 * @returns {JSX.Element}
 */
export function UserList({ users, onUserClick, loading = false }) {
  // ...
}
```

### 2. 代码注释

#### Java 注释规范

```java
/**
 * 用户服务类
 * 
 * 提供用户注册、登录、查询等功能
 * 
 * @author 阵堂长老
 * @version 1.0
 * @since 2026-03-28
 */
public class UserService {
    
    /**
     * 创建新用户
     * 
     * @param username 用户名，长度 3-50 字符
     * @param email 邮箱地址，必须是有效的邮箱格式
     * @param password 密码，长度至少 8 字符
     * @return 新创建的用户 ID
     * @throws IllegalArgumentException 如果参数不合法
     * @throws DuplicateUserException 如果用户名或邮箱已存在
     */
    public String createUser(String username, String email, String password) {
        // 实现
    }
}
```

#### JavaScript/TypeScript 注释规范

```typescript
/**
 * 创建新用户
 * 
 * @param {Object} userData - 用户数据
 * @param {string} userData.username - 用户名，长度 3-50 字符
 * @param {string} userData.email - 邮箱地址
 * @param {string} userData.password - 密码，长度至少 8 字符
 * @returns {Promise<string>} 新创建的用户 ID
 * @throws {ValidationError} 如果参数不合法
 * @throws {DuplicateError} 如果用户名或邮箱已存在
 * 
 * @example
 * ```javascript
 * const userId = await createUser({
 *   username: 'john',
 *   email: 'john@example.com',
 *   password: 'password123'
 * });
 * ```
 */
async function createUser(userData) {
  // 实现
}
```

### 3. README 文档

#### 项目 README 模板

```markdown
# 项目名称

简短的项目描述

## 功能特性

- ✨ 功能1
- ✨ 功能2
- ✨ 功能3

## 技术栈

- **后端**: Node.js + Express
- **前端**: React + TypeScript
- **数据库**: PostgreSQL
- **其他**: Redis, Docker

## 快速开始

### 前置要求

- Node.js >= 16
- PostgreSQL >= 13
- Redis >= 6

### 安装

\`\`\`bash
# 克隆项目
git clone https://github.com/user/project.git
cd project

# 安装依赖
npm install

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件

# 初始化数据库
npm run db:migrate

# 启动开发服务器
npm run dev
\`\`\`

### 使用

访问 http://localhost:3000

## API 文档

详见 [API 文档](./docs/API.md)

## 开发指南

### 目录结构

\`\`\`
src/
├── controllers/  # 控制器
├── models/       # 数据模型
├── routes/       # 路由
├── services/     # 业务逻辑
└── utils/        # 工具函数
\`\`\`

### 代码规范

- 使用 ESLint 进行代码检查
- 使用 Prettier 进行代码格式化
- 提交前运行 `npm run lint`

### 测试

\`\`\`bash
# 运行所有测试
npm test

# 运行测试并生成覆盖率报告
npm run test:coverage
\`\`\`

## 部署

\`\`\`bash
# 构建生产版本
npm run build

# 启动生产服务器
npm start
\`\`\`

## 贡献

欢迎贡献！请阅读 [贡献指南](CONTRIBUTING.md)

## 许可证

MIT License
```

### 4. 变更日志

#### CHANGELOG 模板

```markdown
# 变更日志

## [1.1.0] - 2026-03-28

### 新增
- ✨ 用户注册功能
- ✨ 用户登录功能
- ✨ 密码加密存储

### 变更
- 🔧 优化数据库查询性能
- 🔧 更新依赖版本

### 修复
- 🐛 修复用户名重复检查的 Bug
- 🐛 修复邮箱验证正则表达式

## [1.0.0] - 2026-03-20

### 新增
- ✨ 初始版本发布
- ✨ 基础项目结构
```

## 文档生成流程

### 1. 任务开始时

宗主在任务总览中定义文档要求：

```markdown
## 文档要求

### API 文档
- 所有接口必须有 OpenAPI 规范
- 包含请求/响应示例
- 说明错误码含义

### 代码注释
- 所有公共函数必须有 JSDoc/Javadoc
- 复杂逻辑必须有行内注释
- 类和模块必须有说明注释

### README
- 更新功能特性列表
- 更新使用说明
- 添加新的配置项说明
```

### 2. 开发过程中

各堂在开发时同步编写文档：

```javascript
// 阵堂开发时编写 API 文档和代码注释
/**
 * 用户注册接口
 * POST /api/users/register
 * ...
 */
router.post('/register', async (req, res) => {
  // ...
});
```

### 3. Self-Review 时检查

Self-Review 清单包含文档检查：

- [ ] 所有公共函数都有注释
- [ ] API 文档已更新
- [ ] README 已更新（如有新功能）
- [ ] 没有未处理的 TODO

### 4. 执法堂验证

执法堂在代码质量测试中验证文档：

```markdown
## 文档完整性测试

### API 文档
- ✅ 所有接口都有 OpenAPI 规范
- ✅ 包含请求/响应示例
- ✅ 错误码有说明

### 代码注释
- ✅ 公共函数有 JSDoc
- ✅ 复杂逻辑有注释
- ❌ UserService.validateEmail 缺少注释

### README
- ✅ 功能特性已更新
- ✅ 使用说明已更新
```

### 5. 归档时生成

宗主在归档时生成完整文档：

```bash
# 生成 API 文档
npm run docs:api

# 生成代码文档
npm run docs:code

# 更新 CHANGELOG
echo "## [1.1.0] - $(date +%Y-%m-%d)" >> CHANGELOG.md
```

## 文档工具

### API 文档生成

```bash
# Swagger/OpenAPI
npm install -D swagger-jsdoc swagger-ui-express

# 生成文档
npm run docs:api
```

### 代码文档生成

```bash
# JSDoc (JavaScript)
npm install -D jsdoc
jsdoc src/ -d docs/

# TypeDoc (TypeScript)
npm install -D typedoc
typedoc src/ --out docs/

# Javadoc (Java)
mvn javadoc:javadoc
```

### Markdown 文档

```bash
# 使用 Markdown 编写
# 使用 MkDocs 或 VuePress 生成网站

# MkDocs
pip install mkdocs
mkdocs serve

# VuePress
npm install -D vuepress
npm run docs:dev
```

## 最佳实践

### 1. 文档同步

- ✅ 代码修改时同步更新文档
- ✅ 使用自动化工具生成文档
- ❌ 不要等到最后才写文档

### 2. 文档质量

- ✅ 使用清晰的语言
- ✅ 提供代码示例
- ✅ 说明边界情况
- ❌ 不要假设读者的知识水平

### 3. 文档维护

- ✅ 定期审查文档准确性
- ✅ 删除过时的文档
- ✅ 保持文档结构清晰
- ❌ 不要保留冗余文档

## 注意事项

1. **文档即代码** - 文档也需要版本控制
2. **受众明确** - 明确文档的目标读者
3. **持续更新** - 文档需要持续维护
4. **工具辅助** - 使用工具自动生成文档
