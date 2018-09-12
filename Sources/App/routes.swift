
import Vapor
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    // Example of Basic "Hello, world!"
    router.get("hello") { req in
        return "Hello, world!"
    }
    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
    router.get("update", Todo.parameter, use: todoController.update)
    
    /*
     用户API
     */
    let apiRoutes = router.grouped("api")
    let userController = UserController()
    apiRoutes.get("register", use: userController.register)
    apiRoutes.post("register", use: userController.register)
    apiRoutes.get("register", User.parameter, use: userController.register)
    
    /*
     需要验证User session的请求均使用authSessionsMiddleware中间件(session)包裹的路由器(sessionAuth)来路由
     一般用于获取权限资源、或根据用户返回信息的请求
     */
    let session = User.authSessionsMiddleware()
    let sessionAuth = apiRoutes.grouped(session)
    sessionAuth.get("login", use: userController.login)//创建sessionID缓存在服务端，并使客户端之后(对sessionAuth)的请求头上带上该sessionID
    sessionAuth.get("analyze") { req -> String in
        let user = try req.requireAuthenticated(User.self)
        return "Hello, \(user.email)!"
    }
    
    let password = User.basicAuthMiddleware(using: BCryptDigest())//需实现PasswordAuthenticatable协议，
    let passwordAuth = sessionAuth.grouped(password) //注意使用password包裹的路由器是sessionAuth，而不是router，否则user会无法被Authenticated；且会使客户端在之后(对passwordAuth、sessionAuth)的请求头上带上username和password字段
    passwordAuth.get("abc") { req -> String in
        let user = try req.requireAuthenticated(User.self)
        return "Hello, \(user.email)."
    }
    passwordAuth.get("/", use: userController.checkLogin)
    
    /*
     Web请求
     */
    let websiteVC = WebsiteController()
    try router.register(collection: websiteVC)
}
