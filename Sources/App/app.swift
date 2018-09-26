import Vapor

/// Creates an instance of Application. This is called from main.swift in the run target.
public func app(_ env: Environment) throws -> Application {
    
    let body = HTTPBody(string: """
                        {"message": "User auth unsuccessfully!"}
                        """)
    var message: HTTPResponse = HTTPResponse()
    message.body = body
    if let data = message.body.data {
        do {
            let result = try JSONDecoder().decode([String:String].self, from: data)
            print(result)
            print("no decode")
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    var config = Config.default()
    var env = env
    var services = Services.default()
    try configure(&config, &env, &services)
    let app = try Application(config: config, environment: env, services: services)
    try boot(app)
    return app
}
