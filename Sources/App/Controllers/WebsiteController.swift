//
//  WebSiteController.swift
//  App
//
//  Created by NeroMilk on 2018/9/12.
//

import Vapor
import Foundation

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get("/",use: homeHandler)
        router.get("home",use: homeHandler)
        router.get("login",use: loginHandler)
        router.get("register",use: rigisterHandler)
    }
    
    func loginHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("login")
    }
    
    func homeHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("home")
    }
    
    func rigisterHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("register")
    }
}

