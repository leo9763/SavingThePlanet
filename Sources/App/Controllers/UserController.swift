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
import Leaf
import SwiftSMTP

final class UserController {
    
    //登录API
    func signin(_ req: Request) throws -> Future<HTTPResponse> {

        try req.unauthenticateSession(User.self)
        
        let handler = {(user: User?) throws -> HTTPResponse in
            
            guard let user = user else {
                let body = ["message":"User auth unsuccessfully!","code":"1001"]
                return try jsonResponse(inBody: body)
            }
            //缓存session在服务端（未知与authenticateSession的区别）
            try req.authenticate(user)
            let body = ["message":"Login successfully!",
                        "code":"1000",
                        "userId":"\(user.id!)"]
            return try jsonResponse(inBody: body)
        }
        
        if req.http.method == .POST {
            return try req.content.decode(User.self).flatMap { decodeUser in
                return User.authenticate(username:decodeUser.email,
                                         password:decodeUser.passwordHash,
                                         using:BCryptDigest(),
                                         on:req).map { user in
                    return try handler(user)
                }
            }
        }
        else {
            let decodeUser:User = try req.query.decode(User.self)
            return User.authenticate(username:decodeUser.email,
                                     password:decodeUser.passwordHash,
                                     using:BCryptDigest(),
                                     on:req).map(handler)
        }
    }
    
    func signout(_ req: Request) throws -> Future<HTTPResponse> {
        try req.unauthenticateSession(User.self)
        return Future.map(on: req) { try jsonResponse(inBody: ["message":"Login successfully!","code":"1000"]) }
    }
    
    //注册API
    func signup(_ req: Request) throws -> Future<HTTPResponse> {
        
        var decodeUser:User?
        
        var inputCaptcha = ""
        
        let handler = {(user:User?) throws -> Future<HTTPResponse> in
            
            if let _ = user {
                return Future.map(on: req) { try jsonResponse(inBody: ["message":"User already exists!","code":"1001"]) }
            }
            
            guard let toSaveUser = decodeUser else {
                return Future.map(on: req) {
                    return try jsonResponse(inBody: ["message":"Register user info failly by decoding!","code":"1001"])
                }
            }
            guard let verifyCode = self.emailDic[toSaveUser.email] else {
                return Future.map(on: req) { try jsonResponse(inBody: ["message":"No CAPTCHA record!","code":"1001"]) }
            }
            
            if verifyCode != inputCaptcha {
                self.emailDic[toSaveUser.email] = nil
                return Future.map(on: req) { try jsonResponse(inBody: ["message":"Wrong CAPTCHA!","code":"1001"]) }
            }
            return try self._saveUser(toSaveUser, on: req)
        }
        
        if req.http.method == .POST {
            
            inputCaptcha = try req.content.syncGet(String.self, at: "captcha")
            
            return try req.content.decode(User.self).flatMap { user in
                decodeUser = user
                return User.query(on: req).filter(\.email == decodeUser!.email).first().flatMap(handler)
            }
        }
        else {
            guard let captcha = req.query[String.self, at: "captcha"] else {
                return Future.map(on: req) { try jsonResponse(inBody: ["message":"Missing CAPTCHA!","code":"1001"]) }
            }
            inputCaptcha = captcha
            
            decodeUser = try req.query.decode(User.self)
            return User.query(on: req).filter(\.email == decodeUser!.email).first().flatMap(handler)
        }
    }
    
    private func _saveUser(_ user: User, on conn: Request) throws -> Future<HTTPResponse> {
        
        guard !user.email.isEmpty else {
            let body = ["message":"Missing user email!","code":"1001"]
            return Future.map(on: conn) { try jsonResponse(inBody: body) }
        }
        guard !user.passwordHash.isEmpty else {
            let body = ["message":"Missing user password!","code":"1001"]
            return Future.map(on: conn) { try jsonResponse(inBody: body) }
        }
        user.passwordHash = try BCryptDigest().hash(user.passwordHash)
        return user.save(on: conn).map() { user in
            var body:[String:String]
            if let id = user.id {
                body = ["message":"Create user successfully!",
                        "code":"1000",
                        "userId":"\(id)"]
                try conn.authenticate(user)
            }
            else {
                body = ["message":"Create user fail!","code":"1001"]
            }
            return try jsonResponse(inBody: body)
        }
    }
    
    func sendCAPTCHA(_ req: Request) throws -> Future<HTTPResponse> {
        
        var email = ""
        if req.http.method == .POST {
            email = try req.content.get(String.self, at: "email").wait()
        }
        else {
            email = try req.query.get(String.self, at: "email")
        }
        
        var verifyCode = emailDic[email]
        
        if verifyCode == nil{
            verifyCode = randomNumericString(length: 4)
        }
        let userMail = Mail.User(email: email)
        
        let mail = Mail(
            from: PUBGNewsBoxMailAddress,
            to: [userMail],
            subject: "欢迎注册为救救这星球的用户",
            text: "您本次注册的验证码为：\(verifyCode!)"
        )
        let result = req.eventLoop.newPromise(Bool.self)
        smtp.send(mail) { (error) in
            if let error = error {
                print(error)
                result.succeed(result: false)
            }else{
                self.emailDic[email] = verifyCode!
                result.succeed(result: true)
            }
        }
        return result.futureResult.map(to: HTTPResponse.self) { isSucceed in
            if isSucceed {
                return try jsonResponse(inBody: ["message":"Send successfully!","code":"1000"])
            }
            else{
                self.emailDic[email] = verifyCode!
                return try jsonResponse(inBody: ["message":"Send fail!","code":"1001"])
            }
        }
    }
    
    fileprivate var emailDic = Dictionary<String,String>()
    fileprivate let smtp = SMTP(hostname: "smtp.163.com",
                                email: "Savingtheplanet@163.com",
                                password: "savingtheplanet1")
    fileprivate let PUBGNewsBoxMailAddress = Mail.User(name: "Saving The Planet", email: "Savingtheplanet@163.com")
}
