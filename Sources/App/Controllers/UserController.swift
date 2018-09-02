//
//  UserController.swift
//  App
//
//  Created by NeroMilk on 2018/8/29.
//

import Foundation
import FluentPostgreSQL
import Vapor

final class UserController {
    
    func create(_ req: Request) throws -> Future<HTTPResponse> {
        
        if req.http.method == .POST {
            return try req.content.decode(User.self).flatMap() { user in
                return self._saveUser(user, on: req)
            }
        }
        else {
            let user:User = try req.query.decode(User.self)
            return self._saveUser(user, on: req)
        }
    }
    
    private func _saveUser(_ user: User, on conn: DatabaseConnectable) -> Future<HTTPResponse> {
        var message: HTTPResponse = HTTPResponse()
        message.contentType = .json
        message.status = .ok
        guard !user.name.isEmpty else {
            message.body = HTTPBody(string: """
                        {"message": "Missing user name!"}
                    """)
            return Future.map(on: conn) { message }
        }
        guard !user.email.isEmpty else {
            message.body = HTTPBody(string: """
                        {"message": "Missing user email!"}
                    """)
            return Future.map(on: conn) { message }
        }
        guard !user.passwordHash.isEmpty else {
            message.body = HTTPBody(string: """
                        {"message": "Missing user password!"}
                    """)
            return Future.map(on: conn) { message }
        }
        return user.save(on: conn).map() { user in
            message.body = HTTPBody(string: """
                        {"message": "Create successfully!"}
                    """)
            return message
        }
    }
}
