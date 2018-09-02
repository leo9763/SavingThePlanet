
import Vapor
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
    router.get("update", Todo.parameter, use: todoController.update)
    
    let userController = UserController()
    router.get("createUser", use: userController.create)
    router.post("createUser", use: userController.create)
    router.get("createUser", User.parameter, use: userController.create)
}
