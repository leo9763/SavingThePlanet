
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
    router.get("register", use: userController.register)
    router.post("register", use: userController.register)
    router.get("register", User.parameter, use: userController.register)
    
    /*
     需要验证User session的请求均使用authSessionsMiddleware中间件(session)包裹的路由器(auth)来路由
     一般用于获取权限资源、或根据用户返回信息的请求
     */
    let session = User.authSessionsMiddleware()
    let sessionAuth = router.grouped(session)
    sessionAuth.get("login", use: userController.login)
    sessionAuth.get("analyze") { req -> String in
        let user = try req.requireAuthenticated(User.self)
        return "Hello, \(user.email)!"
    }
    
    let password = User.basicAuthMiddleware(using: BCryptDigest())
    let passwordAuth = router.grouped(password)
//    router.grouped(password).get("abc") { req in
//        let user = try req.requireAuthenticated(User.self)
//        return "Hello, \(user.name)."
//    }
    
}
