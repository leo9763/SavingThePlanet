import FluentSQLite
import Vapor

/// A single entry of a Todo list.
final class Todo: SQLiteModel {
    /// The unique identifier for this `Todo`.
    var id: Int?

    /// A title describing what this `Todo` entails.
    var title: String
    
    /// A later adding property
    var date: Date?

    /// Creates a new `Todo`.
    init(id: Int? = nil, title: String, date: Date?=Date()) {
        self.id = id
        self.title = title
        self.date = date
    }
}

/// Allows `Todo` to be used as a dynamic migration.
/// Migration 可使模型的属性被动态识别（建立属性与数据表各字段的关联），不一定必须扩展Model类型
extension Todo: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
/// Content 可使模型编码或解码HTTP消息，即与XML、JSON等相互转换
extension Todo: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
/// 能直接读取请求中的参数，并与属性动态关联
extension Todo: Parameter { }

/// 自定义 Migration
struct CreateTodo: SQLiteMigration {
    
    /// 创建数据表
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Todo.self, on: conn) { builder in
            
            /// builder用于指定数据表的各字段
            builder.field(for: \.id, isIdentifier: true)//第二个参数为 是否主键
            builder.field(for: \.title)  //或直接指定类型 builder.field(for: \.title, type: .text)
        }
    }
    
    /// 还原数据表
    static func revert(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.delete(Todo.self, on: conn)
    }
}

/// 当要增加或删减数据表的字段时，选自定义这个Megration注册到Services去
struct EditDateProperty: SQLiteMigration {

    typealias Database = SQLiteDatabase

    //新增字段
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return Database.update(Todo.self, on: conn) { builder in
            builder.field(for: \.date)
        }
    }

    //删除字段
    static func revert(on conn: SQLiteConnection) -> Future<Void> {
        return Database.update(Todo.self, on: conn) { builder in
            builder.deleteField(for: \.date)
        }
    }
}

/// 按特定逻辑处理数据表的migration，此处以清理记录块为例
/// 定义后需添加到MigrationConfig
struct TodoMassCleanup: SQLiteMigration {
    static func prepare(on conn: SQLiteConnection) -> EventLoopFuture<Void> {
        return Todo.query(on: conn).filter(\.title == "vapor").delete() //该操作不可逆
    }
    
    static func revert(on conn: SQLiteConnection) -> EventLoopFuture<Void> {
        return conn.future()
    }
}
