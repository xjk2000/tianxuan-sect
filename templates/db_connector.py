#!/usr/bin/env python3
"""
数据库连接工具
由宗主在灵脉勘查时根据项目实际情况配置
"""

import argparse
import sys
import os
from typing import Optional, List, Dict, Any

# 根据项目实际数据库类型，取消注释对应的导入
# import pymysql  # MySQL
# import psycopg2  # PostgreSQL
# import pymongo  # MongoDB
# import redis  # Redis


class DatabaseConnector:
    """数据库连接器基类"""
    
    def __init__(self):
        self.connection = None
        self.cursor = None
    
    def connect(self):
        """建立数据库连接"""
        raise NotImplementedError("子类必须实现 connect 方法")
    
    def disconnect(self):
        """关闭数据库连接"""
        raise NotImplementedError("子类必须实现 disconnect 方法")
    
    def execute_query(self, query: str, params: Optional[tuple] = None) -> List[Dict[str, Any]]:
        """执行查询"""
        raise NotImplementedError("子类必须实现 execute_query 方法")
    
    def execute_update(self, query: str, params: Optional[tuple] = None) -> int:
        """执行更新操作"""
        raise NotImplementedError("子类必须实现 execute_update 方法")


class MySQLConnector(DatabaseConnector):
    """MySQL 连接器"""
    
    def __init__(self, host: str, port: int, database: str, user: str, password: str):
        super().__init__()
        self.host = host
        self.port = port
        self.database = database
        self.user = user
        self.password = password
    
    def connect(self):
        """建立 MySQL 连接"""
        try:
            import pymysql
            self.connection = pymysql.connect(
                host=self.host,
                port=self.port,
                database=self.database,
                user=self.user,
                password=self.password,
                charset='utf8mb4',
                cursorclass=pymysql.cursors.DictCursor
            )
            self.cursor = self.connection.cursor()
            print(f"✅ 成功连接到 MySQL: {self.host}:{self.port}/{self.database}")
        except Exception as e:
            print(f"❌ MySQL 连接失败: {e}")
            sys.exit(1)
    
    def disconnect(self):
        """关闭 MySQL 连接"""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
            print("✅ MySQL 连接已关闭")
    
    def execute_query(self, query: str, params: Optional[tuple] = None) -> List[Dict[str, Any]]:
        """执行 MySQL 查询"""
        try:
            self.cursor.execute(query, params)
            results = self.cursor.fetchall()
            print(f"✅ 查询成功，返回 {len(results)} 条记录")
            return results
        except Exception as e:
            print(f"❌ 查询失败: {e}")
            return []
    
    def execute_update(self, query: str, params: Optional[tuple] = None) -> int:
        """执行 MySQL 更新操作"""
        try:
            affected_rows = self.cursor.execute(query, params)
            self.connection.commit()
            print(f"✅ 更新成功，影响 {affected_rows} 行")
            return affected_rows
        except Exception as e:
            self.connection.rollback()
            print(f"❌ 更新失败: {e}")
            return 0


class PostgreSQLConnector(DatabaseConnector):
    """PostgreSQL 连接器"""
    
    def __init__(self, host: str, port: int, database: str, user: str, password: str):
        super().__init__()
        self.host = host
        self.port = port
        self.database = database
        self.user = user
        self.password = password
    
    def connect(self):
        """建立 PostgreSQL 连接"""
        try:
            import psycopg2
            import psycopg2.extras
            self.connection = psycopg2.connect(
                host=self.host,
                port=self.port,
                database=self.database,
                user=self.user,
                password=self.password
            )
            self.cursor = self.connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            print(f"✅ 成功连接到 PostgreSQL: {self.host}:{self.port}/{self.database}")
        except Exception as e:
            print(f"❌ PostgreSQL 连接失败: {e}")
            sys.exit(1)
    
    def disconnect(self):
        """关闭 PostgreSQL 连接"""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
            print("✅ PostgreSQL 连接已关闭")
    
    def execute_query(self, query: str, params: Optional[tuple] = None) -> List[Dict[str, Any]]:
        """执行 PostgreSQL 查询"""
        try:
            self.cursor.execute(query, params)
            results = self.cursor.fetchall()
            print(f"✅ 查询成功，返回 {len(results)} 条记录")
            return [dict(row) for row in results]
        except Exception as e:
            print(f"❌ 查询失败: {e}")
            return []
    
    def execute_update(self, query: str, params: Optional[tuple] = None) -> int:
        """执行 PostgreSQL 更新操作"""
        try:
            self.cursor.execute(query, params)
            affected_rows = self.cursor.rowcount
            self.connection.commit()
            print(f"✅ 更新成功，影响 {affected_rows} 行")
            return affected_rows
        except Exception as e:
            self.connection.rollback()
            print(f"❌ 更新失败: {e}")
            return 0


def load_config(config_file: str = 'db_config.json') -> Dict[str, Any]:
    """从 JSON 配置文件加载数据库配置"""
    # 查找配置文件
    config_paths = [
        config_file,  # 当前目录
        os.path.join(os.path.dirname(__file__), config_file),  # 工具目录
        os.path.join(os.path.dirname(__file__), '..', '..', '宗门流程规范', config_file),  # 宗门流程规范目录
    ]
    
    config_path = None
    for path in config_paths:
        if os.path.exists(path):
            config_path = path
            break
    
    if not config_path:
        print("❌ 错误: 找不到数据库配置文件")
        print(f"请在以下位置之一创建 {config_file}:")
        for path in config_paths:
            print(f"  - {os.path.abspath(path)}")
        print("\n配置文件格式示例:")
        print("""{
  "type": "mysql",
  "host": "localhost",
  "port": 3306,
  "database": "your_database",
  "user": "your_user",
  "password": "your_password"
}""")
        print("\n或在 天玄宗/宗门流程规范/丹堂规范.md 中查看配置说明")
        sys.exit(1)
    
    # 读取配置文件
    try:
        import json
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        # 设置默认值
        config.setdefault('type', 'mysql')
        config.setdefault('host', 'localhost')
        config.setdefault('port', 3306)
        
        # 检查必需配置
        if not config.get('database') or not config.get('user'):
            print("❌ 错误: 配置文件缺少必需字段")
            print("必需字段: database, user")
            print("可选字段: type, host, port, password")
            sys.exit(1)
        
        print(f"✅ 已加载配置文件: {config_path}")
        return config
        
    except json.JSONDecodeError as e:
        print(f"❌ 配置文件格式错误: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ 读取配置文件失败: {e}")
        sys.exit(1)


def create_connector(config: Dict[str, Any]) -> DatabaseConnector:
    """根据配置创建数据库连接器"""
    db_type = config['type'].lower()
    
    if db_type == 'mysql':
        return MySQLConnector(
            host=config['host'],
            port=config['port'],
            database=config['database'],
            user=config['user'],
            password=config['password']
        )
    elif db_type == 'postgresql':
        return PostgreSQLConnector(
            host=config['host'],
            port=config['port'],
            database=config['database'],
            user=config['user'],
            password=config['password']
        )
    else:
        print(f"❌ 不支持的数据库类型: {db_type}")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description='数据库连接工具')
    parser.add_argument('--query', '-q', help='执行 SQL 查询')
    parser.add_argument('--file', '-f', help='执行 SQL 文件')
    parser.add_argument('--output', '-o', help='输出结果到文件（CSV 格式）')
    parser.add_argument('--limit', '-l', type=int, default=100, help='查询结果限制（默认 100）')
    parser.add_argument('--config', '-c', default='db_config.json', help='配置文件路径（默认 db_config.json）')
    
    args = parser.parse_args()
    
    if not args.query and not args.file:
        parser.print_help()
        sys.exit(1)
    
    # 加载配置
    config = load_config(args.config)
    
    # 创建连接器
    connector = create_connector(config)
    
    try:
        # 建立连接
        connector.connect()
        
        # 执行查询
        if args.query:
            results = connector.execute_query(args.query)
            
            # 显示结果
            if results:
                print(f"\n查询结果（显示前 {min(len(results), args.limit)} 条）:")
                print("-" * 80)
                for i, row in enumerate(results[:args.limit], 1):
                    print(f"{i}. {row}")
                
                if len(results) > args.limit:
                    print(f"\n... 还有 {len(results) - args.limit} 条记录未显示")
                
                # 导出到文件
                if args.output:
                    import csv
                    with open(args.output, 'w', newline='', encoding='utf-8') as f:
                        if results:
                            writer = csv.DictWriter(f, fieldnames=results[0].keys())
                            writer.writeheader()
                            writer.writerows(results)
                    print(f"\n✅ 结果已导出到: {args.output}")
        
        elif args.file:
            # 读取 SQL 文件
            with open(args.file, 'r', encoding='utf-8') as f:
                sql_content = f.read()
            
            # 执行 SQL
            results = connector.execute_query(sql_content)
            print(f"✅ SQL 文件执行完成")
    
    finally:
        # 关闭连接
        connector.disconnect()


if __name__ == '__main__':
    main()
