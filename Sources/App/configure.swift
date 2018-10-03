import FluentSQLite
#if abc//#if os(OSX)
import FluentPostgreSQL
#endif
import Authentication
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    /*
     Register providers first
     */
    try services.register(FluentSQLiteProvider())
    #if abc//#if os(OSX)
    try services.register(FluentPostgreSQLProvider())
    #endif
    try services.register(AuthenticationProvider()) // register Authentication provider

    /*
     Configure database
     */
    var databases = DatabasesConfig()
    
    #if abc//#if os(OSX)
    let postgreSql = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(hostname: "localhost",
                                                                         port:5432,
                                                                         username: "neromilk",
                                                                         database:"users",
                                                                         password:nil,
                                                                         transport:.cleartext)) // Configure a PostgreSQL database
    databases.add(database: postgreSql, as: .psql) // Register the configured SQLite database to the database config.
    
    let sqlite = try SQLiteDatabase(storage: .file(path: "/Users/neromilk/Documents/SavingThePlanet/todos.sqlite")) // Configure a SQLite database
    #else
    let sqlite = try SQLiteDatabase(storage: .memory)
    #endif
    databases.add(database: sqlite, as: .sqlite) // Register the configured SQLite database to the database config.
    services.register(databases)
    
    
    /*
     Register routes to the router
     */
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /*
     Register middleware
     */
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self) // 设置缓存服务的优先级
    middlewares.use(SessionsMiddleware.self) // Session 验证的中间件
    services.register(middlewares)
    
    /*
     Configure migrations
     */
    var migrations = MigrationConfig()
    #if abc//#if os(OSX)
    migrations.add(model: User.self, database: .psql)
    #else
    migrations.add(model: User.self, database: .sqlite)
    #endif
    migrations.add(model: Todo.self, database: .sqlite) //若要使用自定义的migration，如CreateTodo，应该这样 extension Todo: CreateTodo ，而不是在这设置
    //migrations.add(migration: EditDateProperty.self, database: .sqlite) //要设置自定义的migration，需要指定migration而非model，并且这个migration一般作为更新数据表的字段使用
    
    services.register(migrations)
    
    
    /*
     Configure and register leaf
     */
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    try services.register(LeafProvider())
    
    
    /*
    /// Create default content config
    var contentConfig = ContentConfig.default()
    
    /// Create custom JSON encoder
    let jsonEncoder = JSONEncoder()
    jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
    
    /// Register JSON encoder and content config
    contentConfig.use(encoder: jsonEncoder, for: .json)
    contentConfig.use(encoder: jsonEncoder, for: .urlEncodedForm)
    services.register(contentConfig)
     */
}
