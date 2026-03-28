---
name: 测试驱动开发法
description: TDD 技能 - 先写测试，看它失败，再写代码使其通过
user-invocable: false
---

# 测试驱动开发法 (Test-Driven Development)

## 技能说明

在实现任何功能或修复 bug 之前，先编写测试。遵循红-绿-重构循环。

## 核心原则

**如果你没有看到测试失败，你就不知道它是否测试了正确的东西。**

## 铁律

```
没有失败的测试，就不写生产代码
```

在写测试之前就写了代码？删除它，重新开始。

**没有例外**：
- ❌ 不要保留它作为"参考"
- ❌ 不要在写测试时"改编"它
- ❌ 不要看它
- ❌ 删除就是删除

从测试开始重新实现。没有例外。

## 何时使用

**始终使用**：
- ✅ 新功能
- ✅ Bug 修复
- ✅ 重构
- ✅ 行为变更

**例外（询问用户）**：
- ⚠️ 一次性原型
- ⚠️ 生成的代码
- ⚠️ 配置文件

想着"这次跳过 TDD"？停下来。那是在找借口。

## 红-绿-重构循环

### 阶段 1: 红（Red）

**写一个失败的测试**

```typescript
// ❌ 错误：先写实现
function add(a: number, b: number) {
  return a + b;
}

// ✅ 正确：先写测试
test('add() 应该返回两个数字的和', () => {
  expect(add(2, 3)).toBe(5);  // 测试会失败，因为 add 还不存在
});
```

**检查清单**：
- [ ] 测试描述了期望的行为
- [ ] 测试失败了（红色）
- [ ] 失败原因是正确的（不是语法错误）

### 阶段 2: 绿（Green）

**写最少的代码使测试通过**

```typescript
// ✅ 最简单的实现
function add(a: number, b: number) {
  return a + b;
}

// 测试现在通过了（绿色）
```

**检查清单**：
- [ ] 测试通过了（绿色）
- [ ] 只写了必要的代码
- [ ] 没有过度设计

### 阶段 3: 重构（Refactor）

**改进代码，保持测试通过**

```typescript
// 重构：添加类型安全
function add(a: number, b: number): number {
  if (!Number.isFinite(a) || !Number.isFinite(b)) {
    throw new Error('参数必须是有限数字');
  }
  return a + b;
}

// 添加更多测试
test('add() 应该拒绝无效输入', () => {
  expect(() => add(NaN, 1)).toThrow();
  expect(() => add(1, Infinity)).toThrow();
});
```

**检查清单**：
- [ ] 代码更清晰了
- [ ] 所有测试仍然通过
- [ ] 没有改变行为

## TDD 工作流程

```
1. 写一个失败的测试（红）
   ↓
2. 运行测试，确认它失败
   ↓
3. 写最少的代码使其通过（绿）
   ↓
4. 运行测试，确认它通过
   ↓
5. 重构代码（保持绿色）
   ↓
6. 回到步骤 1
```

## 常见错误

### ❌ 错误 1: 先写实现

```typescript
// ❌ 错误
function calculateDiscount(price: number, percent: number) {
  return price * (1 - percent / 100);
}

// 然后才写测试
test('calculateDiscount 应该计算折扣', () => {
  expect(calculateDiscount(100, 10)).toBe(90);
});
```

**为什么错误**：
- 你没有看到测试失败
- 不知道测试是否真的测试了功能
- 可能测试了错误的东西

### ❌ 错误 2: 一次写太多测试

```typescript
// ❌ 错误：一次写 10 个测试
test('case 1', () => { ... });
test('case 2', () => { ... });
test('case 3', () => { ... });
// ... 还有 7 个
```

**正确做法**：
- 一次只写一个测试
- 让它通过
- 再写下一个

### ❌ 错误 3: 测试实现细节

```typescript
// ❌ 错误：测试内部实现
test('应该调用 helper 函数', () => {
  const spy = jest.spyOn(obj, 'helperMethod');
  obj.doSomething();
  expect(spy).toHaveBeenCalled();
});

// ✅ 正确：测试行为
test('应该返回正确的结果', () => {
  expect(obj.doSomething()).toBe(expectedResult);
});
```

## 与天玄宗的集成

### 阵堂长老（后端）

```
阵堂长老: 我要实现用户登录功能。

(使用测试驱动开发法)

1. 先写测试
   test('login() 应该返回 JWT token', async () => {
     const result = await login('user@example.com', 'password123');
     expect(result.token).toBeDefined();
   });

2. 运行测试（失败）

3. 实现最简单的代码
   async function login(email, password) {
     // 验证用户
     // 生成 token
     return { token: 'xxx' };
   }

4. 测试通过

5. 重构
```

### 器堂长老（前端）

```
器堂长老: 我要实现登录表单组件。

(使用测试驱动开发法)

1. 先写测试
   test('LoginForm 应该提交正确的数据', () => {
     render(<LoginForm />);
     fireEvent.change(screen.getByLabelText('邮箱'), {
       target: { value: 'user@example.com' }
     });
     fireEvent.click(screen.getByText('登录'));
     expect(mockSubmit).toHaveBeenCalledWith({
       email: 'user@example.com'
     });
   });

2. 运行测试（失败）

3. 实现组件

4. 测试通过

5. 重构
```

### 执法堂长老（测试）

```
执法堂长老: 我验证阵堂的代码是否遵循 TDD。

检查：
- [ ] 每个功能都有测试
- [ ] 测试是先写的（检查 git 历史）
- [ ] 测试覆盖率 > 80%
- [ ] 测试测试行为，不是实现
```

## 自检清单

完成开发后，检查：

- [ ] **每个功能都有测试** - 没有未测试的代码
- [ ] **测试是先写的** - 遵循了 TDD 流程
- [ ] **测试通过** - 所有测试都是绿色
- [ ] **测试有意义** - 测试了行为，不是实现
- [ ] **代码简洁** - 没有过度设计
- [ ] **测试覆盖率高** - 至少 80%

## 参考资料

详见：
- [testing-anti-patterns.md](testing-anti-patterns.md) - 测试反模式
- [tdd-examples.md](tdd-examples.md) - TDD 示例

## 总结

**TDD 不是可选的，是必须的。**

- ✅ 先写测试
- ✅ 看它失败
- ✅ 写代码使其通过
- ✅ 重构
- ✅ 重复

没有捷径。
