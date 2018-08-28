import FluentSQLite
import FluentPostgreSQL
import Authentication
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    /*
     Register providers first
     */
    try services.register(FluentSQLiteProvider())
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider()) // register Authentication provider

    /*
     Configure database
     */
    var databases = DatabasesConfig()
    
    let sqlite = try SQLiteDatabase(storage: .memory) // Configure a SQLite database
    databases.add(database: sqlite, as: .sqlite) // Register the configured SQLite database to the database config.
    
    let postgreSql = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(hostname: "localhost", port:5432, username: "neromilk", database:"users", password:nil, transport:.cleartext)) // Configure a PostgreSQL database
    databases.add(database: postgreSql, as: .psql) // Register the configured SQLite database to the database config.
    
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
    //middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    /*
     Configure migrations
     */
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Todo.self, database: .sqlite) //若要使用自定义的migration，如CreateTodo，应该这样 extension Todo: CreateTodo ，而不是在这设置
    migrations.add(migration: EditDateProperty.self, database: .sqlite) //要设置自定义的migration，需要指定migration而非model，并且这个migration一般作为更新数据表的字段使用
    
    services.register(migrations)
}
