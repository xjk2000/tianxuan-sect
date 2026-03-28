---
name: 任务计划编写术
description: 编写详细的任务计划 - 假设执行者对代码库零了解，提供完整的实现步骤
user-invocable: false
---

# 任务计划编写术 (Writing Plans)

## 技能说明

在有了规范或需求后，编写全面的实现计划。假设执行者对代码库零了解，需要详细的指导。

## 核心原则

**假设执行者是技术熟练但对项目一无所知的开发者。**

将复杂任务拆分为小步骤（每步 2-5 分钟），每步包含：
- 精确的文件路径
- 完整的代码
- 精确的命令和预期输出

## 使用时机

**在开始编码之前**：
- ✅ 有了设计规范
- ✅ 需要多步骤实现
- ✅ 需要协调多个文件
- ✅ 需要团队协作

**宣布开始**：
```
宗主: 我使用任务计划编写术创建实现计划。
```

## 计划文档结构

### 文档头部

```markdown
# [功能名称] 实现计划

**目标**: [一句话描述要构建什么]

**架构**: [2-3 句话说明实现方法]

**技术栈**: [关键技术/库]

**执行者**: [阵堂长老/器堂长老/...]

---
```

### 文件结构规划

在定义任务前，先规划文件结构：

```markdown
## 文件结构

### 新建文件
- `src/services/user.service.ts` - 用户服务层
- `src/controllers/user.controller.ts` - 用户控制器
- `tests/user.service.test.ts` - 用户服务测试

### 修改文件
- `src/app.ts:45-60` - 添加用户路由
- `src/database/schema.sql:120-130` - 添加用户表
```

**设计原则**：
- 每个文件有单一职责
- 边界清晰，接口明确
- 相关文件放在一起
- 遵循现有代码模式

## 任务粒度

**每个步骤是一个动作（2-5 分钟）**：

```markdown
- [ ] 写失败的测试
- [ ] 运行测试确认失败
- [ ] 实现最少代码使其通过
- [ ] 运行测试确认通过
- [ ] 提交代码
```

## 任务结构模板

````markdown
### 任务 1: 用户服务层

**文件**：
- 创建: `src/services/user.service.ts`
- 测试: `tests/user.service.test.ts`

#### 步骤 1: 写失败的测试

```typescript
// tests/user.service.test.ts
import { UserService } from '../src/services/user.service';

describe('UserService', () => {
  test('createUser() 应该创建新用户', async () => {
    const service = new UserService();
    const user = await service.createUser({
      email: 'test@example.com',
      password: 'password123'
    });
    
    expect(user.id).toBeDefined();
    expect(user.email).toBe('test@example.com');
  });
});
```

#### 步骤 2: 运行测试验证失败

```bash
npm test tests/user.service.test.ts
```

**预期输出**: 
```
FAIL: UserService is not defined
```

#### 步骤 3: 实现最少代码

```typescript
// src/services/user.service.ts
export class UserService {
  async createUser(data: { email: string; password: string }) {
    // 生成 ID
    const id = generateId();
    
    // 保存到数据库
    await db.users.insert({
      id,
      email: data.email,
      passwordHash: await hashPassword(data.password)
    });
    
    return { id, email: data.email };
  }
}
```

#### 步骤 4: 运行测试验证通过

```bash
npm test tests/user.service.test.ts
```

**预期输出**:
```
PASS: UserService.createUser() 应该创建新用户
```

#### 步骤 5: 提交

```bash
git add tests/user.service.test.ts src/services/user.service.ts
git commit -m "feat: 添加用户创建功能"
```
````

## No Placeholders 原则

**禁止的写法**：
- ❌ "TBD"、"TODO"、"稍后实现"
- ❌ "添加适当的错误处理"（不说明具体怎么处理）
- ❌ "为上述代码编写测试"（不提供实际测试代码）
- ❌ "类似任务 N"（必须重复完整代码）
- ❌ 只描述做什么，不展示怎么做
- ❌ 引用未定义的类型、函数或方法

**正确的写法**：
- ✅ 精确的文件路径
- ✅ 每步都有完整代码
- ✅ 精确的命令和预期输出
- ✅ 所有依赖都已定义

## 天玄宗集成

### 宗主使用

```
宗主: 用户确认了设计，我现在编写实现计划。

(使用任务计划编写术)

1. 创建计划文档
   路径: 天玄宗/宗门任务榜/计划/2024-03-28-用户管理系统.md

2. 规划文件结构
   - 后端: src/services/, src/controllers/
   - 前端: components/User/, pages/users/
   - 测试: tests/

3. 拆分任务
   - 任务 1: 用户服务层（阵堂）
   - 任务 2: 用户控制器（阵堂）
   - 任务 3: 用户界面（器堂）
   - 任务 4: 集成测试（执法堂）

4. 每个任务包含
   - 精确文件路径
   - 完整代码
   - 测试步骤
   - 提交命令

5. 保存计划

6. 分配任务给各堂
```

### 计划保存位置

```
天玄宗/
└── 宗门任务榜/
    └── 计划/
        └── YYYY-MM-DD-功能名称.md
```

## 自检清单

编写完计划后，自我审查：

### 1. 规范覆盖检查
- [ ] 每个需求都有对应任务
- [ ] 没有遗漏的功能

### 2. Placeholder 扫描
- [ ] 没有 "TBD"、"TODO"
- [ ] 没有 "添加适当的..."
- [ ] 所有代码步骤都有完整代码

### 3. 类型一致性
- [ ] 函数名在所有任务中一致
- [ ] 类型定义在所有任务中一致
- [ ] 方法签名在所有任务中一致

### 4. 依赖完整性
- [ ] 所有引用的类型都已定义
- [ ] 所有引用的函数都已实现
- [ ] 导入路径正确

## 执行交接

计划完成后，提供执行选项：

```
宗主: 计划已保存到 天玄宗/宗门任务榜/计划/2024-03-28-用户管理系统.md

执行方式：

1. 分配给各堂长老
   - 任务 1-2: @阵堂长老
   - 任务 3: @器堂长老
   - 任务 4: @执法堂长老

2. 宗主监督执行
   - 每个任务完成后审查
   - 确保质量符合标准
   - 协调各堂协作

选择哪种方式？
```

## 计划示例

### 简单功能计划

```markdown
# 用户登录功能实现计划

**目标**: 实现用户登录功能，包括邮箱密码验证和 JWT token 生成

**架构**: 使用 Express + JWT，密码使用 bcrypt 加密

**技术栈**: Express, bcrypt, jsonwebtoken, TypeScript

**执行者**: 阵堂长老

---

## 文件结构

### 新建文件
- `src/services/auth.service.ts` - 认证服务
- `src/controllers/auth.controller.ts` - 认证控制器
- `tests/auth.service.test.ts` - 认证服务测试

### 修改文件
- `src/app.ts:50-55` - 添加认证路由

---

### 任务 1: 认证服务层

**文件**:
- 创建: `src/services/auth.service.ts`
- 测试: `tests/auth.service.test.ts`

[详细步骤...]
```

## 遵循原则

- ✅ **DRY** - 不重复代码
- ✅ **YAGNI** - 只实现需要的功能
- ✅ **TDD** - 测试驱动开发
- ✅ **频繁提交** - 每个小步骤都提交

## 总结

好的计划应该：
- 详细到执行者不需要思考
- 每步都有完整代码
- 没有任何 placeholder
- 遵循 TDD 流程
- 可以直接执行
