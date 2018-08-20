import FluentSQLite
import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo]> {
        
        //由于Request遵从DatabaseConnectable协议，所以可以直接用于模型在数据中的增删改查操作上
        //当使用request作为connection时，其实是request这个容器container会从事件循环event loop那里的connection池获取一个connection，并且为request的整个生命周期缓存这个connection
        return Todo.query(on: req).all()
        
        /// 前n个结果
        //Todo.query(on: req).range(..<50).all()
        /// 限制容量
        //Todo.query(on: req).chunk(max: 32) { todos in
        //}
        /// 排序
        //Todo.query(on: req).sort(\.title, .descending)
    }
    
    func filter(_ req: Request) throws -> Future<[Todo]> {
        return Todo.query(on: req).filter(\.title == "Vapor").all()
        
        /// 过滤后的第一条记录
        //Todo.query(on: req).filter(\.title == "Vapor").first()
        /// 查询的逻辑组合（若没有group则链式过滤等同于.and）
        //Todo.query(on: req).group(.or) {
        //    $0.filter(\.title == "vapor").filter(\.title == "Vapor")
        //}
        /// 连接表查询
        //Todo.query(on: req).join(\User.id, to: \Todo.id).filter(\User.name == "Nero")
        /// 连接表的解码，返回元祖为(Todo, User)的数组
        //Todo.query(on: req).alsoDecode(User.self).all()
    }
    
    
    
    func find(_ req: Request) throws -> Future<Todo> {
        /// 通过唯一的id查找
        let future:Future<Todo?> = Todo.find(1, on: req)
        return future.unwrap(or: Abort(.noContent))
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.self).flatMap { todo in
            return todo.save(on: req)
        }
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
    
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo -> Future<Todo> in
            todo.title = "vapor"
            return todo.update(on: req)
        }.transform(to: HTTPStatus.ok)
    }
}
