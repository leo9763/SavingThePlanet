//
//  WebSiteController.swift
//  App
//
//  Created by NeroMilk on 2018/9/12.
//

import Vapor
import Foundation
import Crypto

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get("/",use: homeHandler)
        router.get("home",use: homeHandler)
        router.get("register",use: rigisterHandler)
    }
    
    func homeHandler(_ req: Request) throws -> Future<View> {
        
        var context: homeContext
        let homeMoudleContexts = [homeModuleContext(imagePath: "home/images/air-pollution.jpg", route: "/register"),
                                  homeModuleContext(imagePath: "home/images/white_pollution.jpeg", route: "/register"),
                                  homeModuleContext(imagePath: "home/images/env_protection.jpg", route: "/register")]
        do {
            if try req.isAuthenticated(User.self) {
                let user = try req.requireAuthenticated(User.self)
                context = homeContext(homeModules:homeMoudleContexts,
                                      userEmail:user.email)
            }
            else {
                context = homeContext(homeModules:homeMoudleContexts,
                                      userEmail:nil)
            }
            return try req.view().render("home",context)
        } catch {
            context = homeContext(homeModules:homeMoudleContexts,
                                  userEmail:nil)
            return try req.view().render("home",context)
        }
    }
    
    func rigisterHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("register")
    }
}

struct homeContext: Encodable {
    let homeModules: [homeModuleContext]
    let userEmail:String?
}
struct homeModuleContext: Encodable {
    let imagePath:String
    let route:String
}
