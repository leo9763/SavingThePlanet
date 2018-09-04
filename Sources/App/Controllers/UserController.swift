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
    
    func login(_ req: Request) throws -> Future<HTTPResponse> {
        var message: HTTPResponse = HTTPResponse()
        message.contentType = .json
        message.status = .ok
        var decodeUser:User?
        
        if req.http.method == .POST {
            decodeUser = try req.content.decode(User.self).wait()
            /* 方法二
            return try req.content.decode(User.self).flatMap() { decodeUser in
                
                return User.query(on: req).filter(\.email == decodeUser.email).first().map { user in
                    guard let user = user else {
                        message.body = HTTPBody(string: """
                        {"message": "User name incorrect!"}
                    """)
                        return message
                    }
                    if decodeUser.passwordHash == user.passwordHash {
                        try req.authenticate(user) //cookie named "vapor-session" has been added to your browser.
                        return HTTPResponse(status: .ok)
                    }
                    else {
                        message.body = HTTPBody(string: """
                            {"message": "Password incorrect!"}
                        """)
                        return message
                    }
                }
            }
             */
        }
        else {
            decodeUser = try req.query.decode(User.self)
        }
        return User.query(on: req).filter(\.email == decodeUser!.email).first().map { user in
            guard let user = user else {
                message.body = HTTPBody(string: """
                        {"message": "User name incorrect!"}
                    """)
                return message
            }
            if decodeUser!.passwordHash == user.passwordHash {
                //认证用户（将在Cookie中返回一个vapor-session字段，其值为一个sessionId给客户端保存，在下次请求中带上作验证的依据）
                try req.authenticate(user)
                message.body = HTTPBody(string: """
                        {"message":"Login successfully!",
                        "userId":\(user.id!)}
                    """)
            }
            else {
                message.body = HTTPBody(string: """
                        {"message": "Password incorrect!"}
                    """)
            }
            return message
        }
    }
    
    func register(_ req: Request) throws -> Future<HTTPResponse> {
        
        var message: HTTPResponse = HTTPResponse()
        message.contentType = .json
        message.status = .ok
        var decodeUser:User?
        
        if req.http.method == .POST {
            /* 解析模型的方法一
             //若body中的数据量大时可以采用异步的返回方式
            return try req.content.decode(User.self).flatMap() { decodeUser in
                return User.query(on: req).filter(\.email == decodeUser.email).first().flatMap { user in
                    if let _ = user {
                        message.body = HTTPBody(string: """
                            {"message": "User already exists!"}
                        """)
                        return Future.map(on: req) { message }
                    }
                    else {
                        return self._saveUser(decodeUser, on: req)
                    }
                }
            }
            */
            
            /* 解析模型的方法二 */
            decodeUser = try req.content.decode(User.self).wait()
        }
        else {
            decodeUser = try req.query.decode(User.self)
        }
        return User.query(on: req).filter(\.email == decodeUser!.email).first().flatMap { user in
            if let _ = user {
                message.body = HTTPBody(string: """
                            {"message": "User already exists!"}
                        """)
                return Future.map(on: req) { message }
            }
            else {
                return self._saveUser(decodeUser!, on: req)
            }
        }
    }
    
    private func _saveUser(_ user: User, on conn: DatabaseConnectable) -> Future<HTTPResponse> {
        var message: HTTPResponse = HTTPResponse()
        message.contentType = .json
        message.status = .ok
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
            if let id = user.id {
                message.body = HTTPBody(string: """
                        {"message":"Create user successfully!",
                        "userId":\(id)}
                    """)
            }
            else {
                message.body = HTTPBody(string: """
                        {"message":"Create user unsuccessfully!"}
                    """)
            }
            return message
        }
    }
}
