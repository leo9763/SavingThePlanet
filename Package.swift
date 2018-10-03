// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SavingThePlanet",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.6"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
//        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        //Auth
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),
        
        ///Mail Server
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP.git", from: "4.0.1"),
        
        //View
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Authentication", "SwiftSMTP","Leaf"]),//"FluentPostgreSQL",
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

