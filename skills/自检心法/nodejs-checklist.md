# Node.js/TypeScript 自检清单详细参考

本文档提供 Node.js/TypeScript 项目的详细自检清单和示例。

## 参数校验

### 使用 Joi 或 Zod

```typescript
import Joi from 'joi';

// 定义校验规则
const userSchema = Joi.object({
  username: Joi.string()
    .min(3)
    .max(50)
    .required()
    .messages({
      'string.empty': '用户名不能为空',
      'string.min': '用户名长度至少 3 字符',
      'string.max': '用户名长度不能超过 50 字符',
    }),
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': '邮箱格式不正确',
    }),
  password: Joi.string()
    .min(8)
    .required()
    .messages({
      'string.min': '密码长度至少 8 字符',
    }),
});

// 使用校验
export async function createUser(data: unknown) {
  // 校验参数
  const { error, value } = userSchema.validate(data);
  
  if (error) {
    throw new ValidationError(error.details[0].message);
  }
  
  // 使用校验后的数据
  const { username, email, password } = value;
  
  // 业务逻辑...
}
```

### 使用 Zod（TypeScript 优先）

```typescript
import { z } from 'zod';

// 定义 schema
const userSchema = z.object({
  username: z.string().min(3).max(50),
  email: z.string().email(),
  password: z.string().min(8),
});

// 自动推导类型
type User = z.infer<typeof userSchema>;

// 使用校验
export async function createUser(data: unknown): Promise<string> {
  // 校验并解析
  const user = userSchema.parse(data);
  
  // TypeScript 知道 user 的类型
  console.log(user.username); // ✅ 类型安全
  
  // 业务逻辑...
}
```

## 异常处理

### 自定义错误类

```typescript
// 基础错误类
export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
    Error.captureStackTrace(this, this.constructor);
  }
}

// 具体错误类
export class ValidationError extends AppError {
  constructor(message: string) {
    super(400, message);
  }
}

export class NotFoundError extends AppError {
  constructor(message: string) {
    super(404, message);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string) {
    super(401, message);
  }
}
```

### Express 错误处理中间件

```typescript
import { Request, Response, NextFunction } from 'express';

// 错误处理中间件
export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  // 记录错误
  console.error('Error:', err);
  
  // 已知的业务错误
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      status: 'error',
      message: err.message,
    });
  }
  
  // 未知错误
  return res.status(500).json({
    status: 'error',
    message: '服务器内部错误',
  });
}

// 使用
app.use(errorHandler);
```

### Async 错误处理

```typescript
// 包装 async 函数
export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

// 使用
app.post('/users', asyncHandler(async (req, res) => {
  const user = await createUser(req.body);
  res.json({ user });
  // 如果抛出异常，会自动被 errorHandler 捕获
}));
```

## TypeScript 类型安全

### 严格的类型定义

```typescript
// ✅ 正确：明确的类型定义
interface User {
  id: string;
  username: string;
  email: string;
  createdAt: Date;
}

interface CreateUserDTO {
  username: string;
  email: string;
  password: string;
}

// ✅ 正确：函数签名明确
export async function createUser(
  dto: CreateUserDTO
): Promise<User> {
  // 实现
}

// ❌ 错误：使用 any
export async function createUser(dto: any): Promise<any> {
  // 失去类型安全
}
```

### 使用类型守卫

```typescript
// 类型守卫函数
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'username' in obj &&
    'email' in obj
  );
}

// 使用
function processUser(data: unknown) {
  if (isUser(data)) {
    // TypeScript 知道 data 是 User 类型
    console.log(data.username);
  } else {
    throw new ValidationError('Invalid user data');
  }
}
```

## 异步操作

### Promise 错误处理

```typescript
// ✅ 正确：使用 try-catch
export async function createUser(dto: CreateUserDTO): Promise<User> {
  try {
    const user = await userRepository.save(dto);
    await emailService.sendWelcomeEmail(user.email);
    return user;
  } catch (error) {
    console.error('Failed to create user:', error);
    throw new AppError(500, 'Failed to create user');
  }
}

// ✅ 正确：使用 .catch()
export function createUser(dto: CreateUserDTO): Promise<User> {
  return userRepository.save(dto)
    .then(user => emailService.sendWelcomeEmail(user.email))
    .catch(error => {
      console.error('Failed to create user:', error);
      throw new AppError(500, 'Failed to create user');
    });
}
```

### 并发控制

```typescript
// ✅ 正确：并行执行
export async function getUserData(userId: string) {
  const [user, posts, comments] = await Promise.all([
    getUserById(userId),
    getPostsByUserId(userId),
    getCommentsByUserId(userId),
  ]);
  
  return { user, posts, comments };
}

// ❌ 错误：串行执行（慢）
export async function getUserData(userId: string) {
  const user = await getUserById(userId);
  const posts = await getPostsByUserId(userId);
  const comments = await getCommentsByUserId(userId);
  
  return { user, posts, comments };
}
```

## 日志记录

### 使用 Winston

```typescript
import winston from 'winston';

// 配置日志
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

// 开发环境添加控制台输出
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
  }));
}

// 使用
export async function createUser(dto: CreateUserDTO) {
  logger.info('Creating user', { username: dto.username });
  
  try {
    const user = await userRepository.save(dto);
    logger.info('User created successfully', { userId: user.id });
    return user;
  } catch (error) {
    logger.error('Failed to create user', {
      username: dto.username,
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });
    throw error;
  }
}
```

## 环境变量管理

### 使用 dotenv + 类型安全

```typescript
import dotenv from 'dotenv';
import { z } from 'zod';

// 加载 .env 文件
dotenv.config();

// 定义环境变量 schema
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  PORT: z.string().transform(Number),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  LOG_LEVEL: z.enum(['error', 'warn', 'info', 'debug']).default('info'),
});

// 验证并导出
export const env = envSchema.parse(process.env);

// 使用
console.log(`Server running on port ${env.PORT}`);
```

## 数据库操作

### 使用 Prisma（类型安全）

```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// ✅ 正确：类型安全的查询
export async function createUser(dto: CreateUserDTO) {
  const user = await prisma.user.create({
    data: {
      username: dto.username,
      email: dto.email,
      passwordHash: await hashPassword(dto.password),
    },
  });
  
  return user;
}

// ✅ 正确：事务
export async function transferMoney(
  fromId: string,
  toId: string,
  amount: number
) {
  await prisma.$transaction(async (tx) => {
    await tx.account.update({
      where: { userId: fromId },
      data: { balance: { decrement: amount } },
    });
    
    await tx.account.update({
      where: { userId: toId },
      data: { balance: { increment: amount } },
    });
  });
}
```

## 测试

### 使用 Jest + Supertest

```typescript
import request from 'supertest';
import app from '../app';

describe('POST /users', () => {
  it('should create a new user', async () => {
    const response = await request(app)
      .post('/users')
      .send({
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
      })
      .expect(201);
    
    expect(response.body).toHaveProperty('id');
    expect(response.body.username).toBe('testuser');
  });
  
  it('should return 400 for invalid email', async () => {
    const response = await request(app)
      .post('/users')
      .send({
        username: 'testuser',
        email: 'invalid-email',
        password: 'password123',
      })
      .expect(400);
    
    expect(response.body.message).toContain('邮箱格式不正确');
  });
});
```

## 自检清单总结

- [ ] 所有入参都有校验（使用 Joi/Zod）
- [ ] 所有异步操作都有错误处理（try-catch 或 .catch()）
- [ ] 使用 TypeScript 严格模式，没有 any
- [ ] 环境变量有类型校验
- [ ] 日志记录完整（使用 Winston）
- [ ] 敏感信息不记录（密码、token）
- [ ] 数据库操作有事务保护
- [ ] 没有 console.log（使用 logger）
- [ ] 没有 TODO/FIXME
- [ ] 有单元测试覆盖
