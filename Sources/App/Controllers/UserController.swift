//
//  UserController.swift
//  App
//
//  Created by NeroMilk on 2018/8/29.
//

import Foundation
import FluentPostgreSQL
import Vapor
import Crypto

final class UserController {
    
    //登录API
    func login(_ req: Request) throws -> Future<HTTPResponse> {
        // 先释放用户上一次的会话
        try req.unauthenticateSession(User.self)
        
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
        
        return User.authenticate(username:decodeUser!.email,password:decodeUser!.passwordHash,using:BCryptDigest(),on:req).map { user in
            guard let user = user else {
                message.body = HTTPBody(string: """
                        {"message": "User auth unsuccessfully!"}
                    """)
                return message
            }
            //缓存session在服务端（未知与authenticateSession的区别）
            try req.authenticate(user)
            
            message.body = HTTPBody(string: """
                {"message":"Login successfully!",
                "userId":\(user.id!)}
                """)
            return message
        }
    }
    
    //检查会话状态API
    func checkLogin(_ req: Request) throws -> Future<HTTPResponse> {
        var message: HTTPResponse = HTTPResponse()
        message.contentType = .json
        message.status = .ok
        
        if try req.isAuthenticated(User.self) {
            return Future.map(on: req) {
                message.body = HTTPBody(string: """
                        {"message": "User is authenticated!"}
                    """)
                return message
            }
        }
        return Future.map(on: req) {
            message.body = HTTPBody(string: """
                        {"message": "User is unauthenticated!"}
                    """)
            return message
        }
    }
    
    //注册API
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
                return try self._saveUser(decodeUser!, on: req)
            }
        }
    }
    
    private func _saveUser(_ user: User, on conn: DatabaseConnectable) throws -> Future<HTTPResponse> {
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
        user.passwordHash = try BCryptDigest().hash(user.passwordHash)
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
