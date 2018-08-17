import Authentication
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    
    // use middleware to protect a group
//     Use user model to create an authentication middleware
//    let password = User.basicAuthMiddleware(using: BCryptDigest())
//
    // Create a route closure wrapped by this middleware
//    router.grouped(password).get("hello") { req in
        ///
//    }

    // add a protected route
//    protectedGroup.get("test") { req in
//        // require that a User has been authed by middleware or throw
//        let user = try req.requireAuthenticated(User.self)
//
//        // say hello to the user
//        return "Hello, \(user.name)."
//
//    }

    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}
