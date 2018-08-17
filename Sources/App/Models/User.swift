//
//  User.swift
//  App
//
//  Created by nero on 2018/8/17.
//

import Authentication
import FluentPostgreSQL

final class User: PostgreSQLModel,Content {
    
    typealias Database = PostgreSQLDatabase
    typealias ID = Int
    
    var id: ID?
    var name: String
    
    var email:String
    var passwordHash:String
    
    init(id: ID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}

extension User:BasicAuthenticatable,PasswordAuthenticatable {
    static func authenticate(username: String, password: String, using verifier: PasswordVerifier, on conn: DatabaseConnectable) -> EventLoopFuture<User?> {
        return
    }
    
    static func authenticate(using basic: BasicAuthorization, verifier: PasswordVerifier, on connection: DatabaseConnectable) -> EventLoopFuture<User?> {
        
    }
    
    static var usernameKey: WritableKeyPath<User, String> {
        return \.email
    }
    
    static var passwordKey: WritableKeyPath<User, String> {
        return \.passwordHash
    }
}


