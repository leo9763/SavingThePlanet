//
//  User.swift
//  App
//
//  Created by nero on 2018/8/17.
//

import Authentication
#if abc//#if os(OSX)
import FluentPostgreSQL

final class User: PostgreSQLModel {
    
    typealias Database = PostgreSQLDatabase
    typealias ID = Int
    
    var id: ID?
    
    var email:String
    var passwordHash:String
    
    init(id: ID? = nil, email: String, passwordHash: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
    }
}

extension User:PasswordAuthenticatable {
    
    static var usernameKey: WritableKeyPath<User, String> {
        return \.email
    }
    
    static var passwordKey: WritableKeyPath<User, String> {
        return \.passwordHash
    }
}

struct CreateUser: PostgreSQLMigration {
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(User.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.email, isIdentifier: true)
            builder.field(for: \.passwordHash)
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.update(User.self, on: conn) { builder in
        
        }
    }
}

extension User: PostgreSQLMigration { }

#else

import FluentSQLite

final class User: SQLiteModel {
    
    typealias Database = SQLiteDatabase
    typealias ID = Int
    
    var id: ID?
    
    var email:String
    var passwordHash:String
    
    init(id: ID? = nil, email: String, passwordHash: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
    }
}

extension User:PasswordAuthenticatable {
    
    static var usernameKey: WritableKeyPath<User, String> {
        return \.email
    }
    
    static var passwordKey: WritableKeyPath<User, String> {
        return \.passwordHash
    }
}

struct CreateUser: SQLiteMigration {
    
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(User.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.email, isIdentifier: true)
            builder.field(for: \.passwordHash)
        }
    }
    
    static func revert(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.update(User.self, on: conn) { builder in
            
        }
    }
}

extension User: SQLiteMigration { }

#endif

extension User: Content { }

extension User: Parameter { }

extension User: SessionAuthenticatable { }
