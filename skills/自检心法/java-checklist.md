# Java 自检清单详细参考

本文档提供 Java 项目的详细自检清单和示例。

## 参数校验

### 使用 Apache Commons Lang

```java
import org.apache.commons.lang3.StringUtils;
import java.util.Objects;

public class UserService {
    
    public String createUser(String username, String email, String password) {
        // 字符串校验
        if (StringUtils.isBlank(username)) {
            throw new IllegalArgumentException("用户名不能为空");
        }
        
        if (StringUtils.length(username) < 3 || StringUtils.length(username) > 50) {
            throw new IllegalArgumentException("用户名长度必须在 3-50 之间");
        }
        
        // 对象校验
        Objects.requireNonNull(email, "邮箱不能为空");
        
        // 邮箱格式校验
        if (!isValidEmail(email)) {
            throw new IllegalArgumentException("邮箱格式不正确");
        }
        
        // 密码强度校验
        if (StringUtils.length(password) < 8) {
            throw new IllegalArgumentException("密码长度至少 8 字符");
        }
        
        // 业务逻辑...
    }
}
```

### 常用校验工具类

```java
// 字符串判空
StringUtils.isBlank(str)      // null, "", "  " 都返回 true
StringUtils.isEmpty(str)      // null, "" 返回 true
StringUtils.isNotBlank(str)
StringUtils.isNotEmpty(str)

// 对象判空
Objects.requireNonNull(obj)                    // 抛出 NPE
Objects.requireNonNull(obj, "错误消息")        // 带消息的 NPE
Objects.isNull(obj)                            // 判断
Objects.nonNull(obj)                           // 判断

// 集合判空
CollectionUtils.isEmpty(collection)
CollectionUtils.isNotEmpty(collection)

// 数字校验
NumberUtils.isCreatable("123")                 // 是否是数字
NumberUtils.toInt("123", 0)                    // 转换，失败返回默认值
```

## 异常处理

### 分层异常处理

```java
// Controller 层
@RestController
public class UserController {
    
    @PostMapping("/users")
    public Result<String> createUser(@RequestBody UserDTO dto) {
        try {
            String userId = userService.createUser(dto);
            return Result.success(userId);
        } catch (IllegalArgumentException e) {
            // 参数错误 - 400
            return Result.error(400, e.getMessage());
        } catch (DuplicateUserException e) {
            // 业务错误 - 400
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            // 系统错误 - 500
            log.error("创建用户失败", e);
            return Result.error(500, "系统异常，请稍后重试");
        }
    }
}

// Service 层
@Service
public class UserService {
    
    public String createUser(UserDTO dto) {
        // 参数校验 - 抛出 IllegalArgumentException
        validateUser(dto);
        
        // 业务校验 - 抛出业务异常
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new DuplicateUserException("用户名已存在");
        }
        
        try {
            // 数据库操作
            return userRepository.save(user);
        } catch (DataAccessException e) {
            // 数据库异常 - 记录日志并抛出
            log.error("保存用户失败", e);
            throw new SystemException("保存用户失败", e);
        }
    }
}
```

### 自定义异常

```java
// 业务异常基类
public class BusinessException extends RuntimeException {
    private final int code;
    
    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }
    
    public int getCode() {
        return code;
    }
}

// 具体业务异常
public class DuplicateUserException extends BusinessException {
    public DuplicateUserException(String message) {
        super(40001, message);
    }
}

public class UserNotFoundException extends BusinessException {
    public UserNotFoundException(String message) {
        super(40004, message);
    }
}
```

## 事务管理

### 正确使用 @Transactional

```java
@Service
public class UserService {
    
    // ✅ 正确：指定 rollbackFor
    @Transactional(rollbackFor = Exception.class)
    public void createUser(UserDTO dto) {
        // 保存用户
        userRepository.save(user);
        
        // 发送欢迎邮件（可能失败）
        emailService.sendWelcomeEmail(user.getEmail());
        
        // 如果邮件发送失败，整个事务回滚
    }
    
    // ✅ 正确：只读事务
    @Transactional(readOnly = true)
    public User getUser(String userId) {
        return userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException("用户不存在"));
    }
    
    // ❌ 错误：没有指定 rollbackFor
    @Transactional
    public void updateUser(UserDTO dto) {
        // 默认只回滚 RuntimeException
        // 如果抛出 Exception，事务不会回滚！
    }
}
```

### 事务传播行为

```java
// REQUIRED（默认）- 如果有事务就加入，没有就新建
@Transactional(propagation = Propagation.REQUIRED)
public void method1() { }

// REQUIRES_NEW - 总是新建事务，挂起当前事务
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void method2() { }

// NESTED - 嵌套事务，可以独立回滚
@Transactional(propagation = Propagation.NESTED)
public void method3() { }
```

## 日志记录

### 使用 SLF4J + Logback

```java
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class UserService {
    
    public String createUser(UserDTO dto) {
        // ✅ 正确：使用占位符
        log.info("开始创建用户: username={}", dto.getUsername());
        
        try {
            String userId = userRepository.save(user);
            
            // ✅ 正确：记录关键操作
            log.info("用户创建成功: userId={}, username={}", 
                userId, dto.getUsername());
            
            return userId;
            
        } catch (Exception e) {
            // ✅ 正确：记录异常堆栈
            log.error("创建用户失败: username={}", dto.getUsername(), e);
            throw e;
        }
    }
    
    // ❌ 错误示例
    public void badLogging(String username) {
        // ❌ 字符串拼接（性能差）
        log.info("用户名: " + username);
        
        // ❌ 记录敏感信息
        log.info("密码: {}", password);
        
        // ❌ 只记录异常消息，没有堆栈
        log.error("错误: " + e.getMessage());
    }
}
```

### 日志级别使用

```java
// TRACE - 最详细的信息
log.trace("进入方法: createUser, 参数: {}", dto);

// DEBUG - 调试信息
log.debug("查询用户: username={}", username);

// INFO - 重要的业务流程
log.info("用户登录成功: userId={}", userId);

// WARN - 警告信息（不影响功能）
log.warn("用户尝试使用弱密码: userId={}", userId);

// ERROR - 错误信息
log.error("数据库连接失败", e);
```

## 魔法值提取

### 提取为常量

```java
// ❌ 错误：硬编码魔法值
public class UserService {
    public void validatePassword(String password) {
        if (password.length() < 8) {  // 魔法值 8
            throw new IllegalArgumentException("密码太短");
        }
    }
}

// ✅ 正确：提取为常量
public class UserService {
    private static final int MIN_PASSWORD_LENGTH = 8;
    private static final int MAX_PASSWORD_LENGTH = 20;
    
    public void validatePassword(String password) {
        if (password.length() < MIN_PASSWORD_LENGTH) {
            throw new IllegalArgumentException(
                "密码长度至少 " + MIN_PASSWORD_LENGTH + " 字符");
        }
        
        if (password.length() > MAX_PASSWORD_LENGTH) {
            throw new IllegalArgumentException(
                "密码长度不能超过 " + MAX_PASSWORD_LENGTH + " 字符");
        }
    }
}
```

### 使用枚举

```java
// ✅ 正确：使用枚举管理状态
public enum UserStatus {
    ACTIVE(1, "激活"),
    INACTIVE(0, "未激活"),
    BANNED(-1, "已封禁");
    
    private final int code;
    private final String desc;
    
    UserStatus(int code, String desc) {
        this.code = code;
        this.desc = desc;
    }
    
    public int getCode() {
        return code;
    }
    
    public String getDesc() {
        return desc;
    }
}
```

## 代码规范

### 阿里巴巴 Java 开发手册

```java
// ✅ 正确的命名
public class UserService { }              // 类名：大驼峰
public void createUser() { }              // 方法名：小驼峰
private String userName;                  // 变量名：小驼峰
private static final int MAX_SIZE = 100;  // 常量：全大写下划线

// ✅ 正确的注释
/**
 * 创建用户
 * 
 * @param dto 用户信息
 * @return 用户ID
 * @throws IllegalArgumentException 参数不合法
 * @throws DuplicateUserException 用户已存在
 */
public String createUser(UserDTO dto) { }

// ✅ 正确的异常处理
try {
    // 业务逻辑
} catch (SpecificException e) {
    // 处理特定异常
    log.error("特定错误", e);
} catch (Exception e) {
    // 处理通用异常
    log.error("未知错误", e);
    throw new SystemException("系统异常", e);
}
```

## 自检清单总结

在提交代码前，逐项检查：

- [ ] 所有入参都有校验（使用 StringUtils、Objects 等工具类）
- [ ] 所有异常都有处理（try-catch 或声明 throws）
- [ ] 事务注解正确（指定 rollbackFor）
- [ ] 日志记录完整（关键操作、异常都有日志）
- [ ] 魔法值已提取（常量或枚举）
- [ ] 代码符合阿里巴巴规范
- [ ] 没有 TODO/FIXME
- [ ] 没有调试代码（System.out.println）
- [ ] 没有注释掉的代码
