//
//  Plan.swift
//  App
//
//  Created by NeroMilk on 2018/8/18.
//

import FluentSQLite
import Vapor

final class Plan: SQLiteModel {
    var id: Int?
    var title: String
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

extension Plan: SQLiteMigration { }
extension Plan: Content { }
extension Plan: Parameter { }


/// 设立父子关系，假设有一个模型类叫Plan，它的对象被视作一个父模型（有一个自身的ID标识属性），Todo是它的子模型（有一个存放其父模型ID的属性，必须是唯一的）
/// 一个父模型对象可以对应多个子模型对象，一个子模型对象只能对应一个父模型对象
/// <From, To> 通过父模型的ID建立关系
extension Todo {
    var plan: Parent<Todo, Plan>? {
        return parent(\.id)
    }
}
extension Plan {
    var todos: Children<Plan, Todo> {
        return children(\.id)
    }
}
/// 使用情境：在父模型为plan的todos下查询
/*
 let plan: Plan = ...
 let todos = plan.todos.query(on: ...).all()
 */
/// 使用情境：在子模型获取其对应的父模型
/*
 let planet: Planet = ...
 let galaxy = planet.galaxy.get(on: ...)
 */


/// 设立兄弟关系，假设上面的Plan和Todo是平级的关系，则它们可以实现多对多的关系，但需要借助一个支点模型Pivot
struct PlanTodo: Pivot {
    static var idKey: WritableKeyPath<PlanTodo, Int?> {
        return \.id
    }
    
    typealias Database = SQLiteDatabase
    
    typealias ID = Int
    
    typealias Left = Plan
    typealias Right = Todo
    
    static var leftIDKey: LeftIDKey = \.planID
    static var rightIDKey: RightIDKey = \.todoID
    
    var id: ID?
    var planID: Int
    var todoID: Int
}
/// <From, To, Through> 通过各自持有大家建立关系（Siblings内部根据Through连接对应的模型）
extension Plan {
    var siblingsTodos: Siblings<Plan, Todo, PlanTodo> {
        return siblings()
    }
}
extension Todo {
    var siblingsPlans: Siblings<Todo, Plan, PlanTodo> {
        return siblings()
    }
}
/// 使用情境
/*
let plan: Plan = Plan(id: 10, title: "Vapor plan")
plan.siblingsTodos.query(on: req).all()
*/


/// 可修改的兄弟关系，即建立关系的操作
extension PlanTodo: ModifiablePivot {
    init(_ plan: Plan, _ todo: Todo) throws {
        planID = try plan.requireID() //唯一的plan ID
        todoID = try todo.requireID() //唯一的todo ID
    }
}
/// 使用情境
/*
 let plan: Plan = Plan(id: 10, title: "Vapor plan 10")
 let todo: Todo = Todo(id: 20, title: "Vapor todo 20", date: "2018-08-18")
 plan.siblingsTodos.attach(todo, on: req)
*/
