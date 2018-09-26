
import Vapor
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    /*
     1.Api请求
     需要验证User session的请求均使用authSessionsMiddleware中间件(session)包裹的路由器(sessionAuth)来路由
     一般用于获取权限资源、或根据用户返回信息的请求
     
     使用以下方法包裹路由，则访问路由时需增加多一层路径，例如/api/login
     let apiRoutes = router.grouped("api")
     */
    let session = User.authSessionsMiddleware()
    let sessionAuth = router.grouped(session)
    let userController = UserController()
    sessionAuth.get("signup", use: userController.signup)
    sessionAuth.post("signup", use: userController.signup)
    sessionAuth.get("signup", User.parameter, use: userController.signup)
    
    sessionAuth.get("signin", use: userController.signin)//创建sessionID缓存在服务端，并使客户端之后(对sessionAuth)的请求头上带上该sessionID
    sessionAuth.get("signout", use: userController.signout)
    
    /*
     2.Web请求
     */
    let websiteVC = WebsiteController()
    try sessionAuth.register(collection: websiteVC)
    
    /*
     3.Demo & Test
     */
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
    //Test session auth
    sessionAuth.get("testSessionAuth") { req -> String in
        let user = try req.requireAuthenticated(User.self)
        return "Hello, \(user.email)!"
    }
    //Test password auth
    let password = User.basicAuthMiddleware(using: BCryptDigest())//需实现PasswordAuthenticatable协议，
    let passwordAuth = sessionAuth.grouped(password) //注意使用password包裹的路由器是sessionAuth，而不是router，否则user会无法被Authenticated；且会使客户端在之后(对passwordAuth、sessionAuth)的请求头上带上username和password字段
    passwordAuth.get("testPasswordAuth") { req -> String in
        let user = try req.requireAuthenticated(User.self) //用该方法可替换对req的content或query的decode过程
        return "Hello, \(user.email)."
    }
}
