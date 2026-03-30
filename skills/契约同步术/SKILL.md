---
name: 契约同步术
description: 前后端契约同步技能 - 确保 API 契约、类型定义、设计意图的一致性
user-invocable: false
---

# 契约同步术 (Contract Synchronization)

## 技能说明

契约同步术是天玄宗前后端协作的核心技能，通过强制性的契约文件，确保阵堂（后端）和器堂（前端）之间的接口一致性和设计意图传递。

## 核心原则

**契约驱动开发 (Contract-Driven Development)**：
- ✅ 后端修改 API → 必须更新契约
- ✅ 前端调用 API → 必须先读契约
- ✅ 契约即文档，契约即测试
- ✅ 设计意图通过契约传递

## 契约中心目录结构

```
天玄宗/
├── 契约中心/
│   ├── API契约/
│   │   ├── api-spec.yaml           # OpenAPI 规范（主契约）
│   │   ├── types.ts                # TypeScript 类型定义（自动生成）
│   │   └── mock-data.json          # Mock 数据（测试用）
│   ├── 数据契约/
│   │   ├── database-schema.sql     # 数据库 Schema
│   │   ├── entity-dto-mapping.md   # Entity 到 DTO 的映射关系
│   │   └── data-dictionary.md      # 数据字典
│   ├── 设计意图/
│   │   ├── backend-decisions.md    # 后端设计决策日志
│   │   ├── frontend-decisions.md   # 前端设计决策日志
│   │   └── breaking-changes.md     # 破坏性变更记录
│   └── 测试契约/
│       ├── integration-tests.md    # 集成测试清单
│       └── e2e-scenarios.md        # 端到端测试场景
```

## 使用场景

### 场景 1: 阵堂长老（后端）使用

**何时使用**：完成后端 API 开发后

**执行步骤**：

1. **生成 OpenAPI 规范**

```yaml
# 天玄宗/契约中心/API契约/api-spec.yaml
openapi: 3.0.0
info:
  title: [模块名称] API
  version: 1.0.0
paths:
  /api/[资源]:
    post:
      summary: [操作描述]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                [字段名]:
                  type: [类型]
                  description: [描述]
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  code:
                    type: integer
                  data:
                    type: object
```

2. **生成 Mock 数据**

```json
{
  "[操作名]": {
    "request": {
      "[字段名]": "[示例值]"
    },
    "response": {
      "code": 200,
      "data": {
        "[字段名]": "[示例值]"
      }
    }
  }
}
```

3. **记录设计意图**

```markdown
## [时间] - [功能描述]

**变更内容**:
- [具体变更]

**设计意图**:
- [为什么这么设计]
- [考虑了什么因素]

**影响范围**:
- [对前端的影响]
- [对其他模块的影响]

**测试要求**:
- [必须测试的场景]
```

4. **生成 TypeScript 类型**（可选，通常由自动化脚本完成）

```bash
npx openapi-typescript 天玄宗/契约中心/API契约/api-spec.yaml -o 天玄宗/契约中心/API契约/types.ts
```

### 场景 2: 器堂长老（前端）使用

**何时使用**：开始前端开发前

**执行步骤**：

1. **读取 API 契约**

```bash
# 必须先读取契约
cat 天玄宗/契约中心/API契约/api-spec.yaml
```

2. **读取设计意图**

```bash
# 理解后端的设计决策
cat 天玄宗/契约中心/设计意图/backend-decisions.md
```

3. **检查破坏性变更**

```bash
# 查看是否有影响前端的变更
cat 天玄宗/契约中心/设计意图/breaking-changes.md
```

4. **使用生成的类型**

```typescript
// 导入契约类型
import type { [RequestType], [ResponseType] } from '@/contracts/types';

// 使用类型定义 API 调用
export async function [functionName](data: [RequestType]): Promise<[ResponseType]> {
  const response = await fetch('[endpoint]', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  return response.json();
}
```

5. **记录前端决策**

```markdown
## [时间] - [功能描述]

**实现内容**:
- [具体实现]

**设计决策**:
- [为什么这么实现]

**依赖契约**:
- API契约/api-spec.yaml: [具体接口]
- 类型定义: [使用的类型]

**测试覆盖**:
- [测试场景]
```

### 场景 3: 执法堂长老（测试）使用

**何时使用**：编写集成测试时

**执行步骤**：

1. **基于契约编写后端测试**

```java
@Test
@DisplayName("契约测试: [接口] - 符合 OpenAPI 规范")
void test[功能]_MatchesContract() throws Exception {
    // 从契约中读取 Mock 数据
    String mockRequest = readFile("天玄宗/契约中心/API契约/mock-data.json", "[操作].request");
    
    mockMvc.perform(post("[endpoint]")
            .contentType(MediaType.APPLICATION_JSON)
            .content(mockRequest))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.code").value(200))
            .andExpect(jsonPath("$.data.[字段]").exists());
}
```

2. **基于契约编写前端测试**

```typescript
import mockData from '@/contracts/mock-data.json';

test('[功能] 应该符合契约定义', async () => {
  const request = mockData.[操作].request;
  const expectedResponse = mockData.[操作].response;
  
  global.fetch = vi.fn().mockResolvedValue({
    json: async () => expectedResponse,
  });
  
  const result = await [functionName](request);
  
  expect(result.code).toBe(200);
  expect(result.data).toMatchObject(expectedResponse.data);
});
```

## 破坏性变更处理流程

### 步骤 1: 后端记录破坏性变更

```markdown
## [时间] - 破坏性变更

**接口**: [接口路径]

**变更内容**:
- [具体变更]

**原因**:
- [为什么要做这个变更]

**影响范围**:
- [对前端的影响]

**迁移指南**:
\`\`\`typescript
// 旧代码
[旧代码示例]

// 新代码
[新代码示例]
\`\`\`

**测试要求**:
- [前端必须更新的测试]
```

### 步骤 2: 前端感知并适配

器堂长老在启动时会自动检查破坏性变更，并根据迁移指南更新代码。

## 自动化检查

### 契约一致性检查

```bash
#!/bin/bash
# 检查契约是否与代码一致

# 1. 验证 OpenAPI 规范语法
npx @stoplight/spectral-cli lint 天玄宗/契约中心/API契约/api-spec.yaml

# 2. 生成 TypeScript 类型
npx openapi-typescript 天玄宗/契约中心/API契约/api-spec.yaml -o 天玄宗/契约中心/API契约/types.ts

# 3. 检查类型是否有变更
if git diff --quiet 天玄宗/契约中心/API契约/types.ts; then
  echo "✅ 契约类型无变更"
else
  echo "⚠️ 契约类型有变更"
  git diff 天玄宗/契约中心/API契约/types.ts
fi
```

## 最佳实践

1. **契约优先**: 后端修改 API 前，先更新契约
2. **类型安全**: 前端必须使用生成的类型，禁止手写类型
3. **意图传递**: 每次变更都要记录设计意图
4. **测试驱动**: 基于契约编写测试，测试即文档
5. **自动化**: 使用脚本自动生成类型和验证契约

## 常见问题

### Q: 为什么要用 OpenAPI 而不是直接看代码？

A: 因为 Agent 之间没有共享记忆，OpenAPI 是它们的"共享黑板"，通过文件持久化设计意图。

### Q: 如果后端忘记更新契约怎么办？

A: 前端测试会失败，执法堂会发现契约不一致，强制后端补充契约。

### Q: 契约文件太多，会不会很复杂？

A: 契约文件是结构化的，Agent 可以快速定位需要的信息，比在代码中搜索更高效。

## 收益

- ✅ **消除猜测**: 前后端通过契约明确接口定义
- ✅ **设计传递**: 通过设计意图日志传递上下文
- ✅ **类型安全**: 自动生成的类型确保一致性
- ✅ **快速反馈**: 测试失败立即暴露契约不一致
- ✅ **持久记忆**: 契约文件作为 Agent 的共享记忆
