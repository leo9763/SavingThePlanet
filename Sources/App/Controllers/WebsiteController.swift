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
        router.get("airPollution",use: airPollutionHandler)
        router.get("whitePollution",use: whitePollutionHandler)
        router.get("environmentScience",use: environmentScienceHandler)
    }
    
    func homeHandler(_ req: Request) throws -> Future<View> {
        

        let homeMoudleContexts = [homeModuleContext(imagePath: "home/images/air-pollution.jpg", route: "/airPollution", title: "空气污染"),
                                  homeModuleContext(imagePath: "home/images/white_pollution.jpeg", route: "/whitePollution", title: "白色污染"),
                                  homeModuleContext(imagePath: "home/images/env_protection.jpg", route: "/environmentScience", title: "环保科普")]
        
        let context = homeContext(homeModules:homeMoudleContexts,
                                  userEmail:_authenticate(req)?.email)
        
        return try req.view().render("home",context)
    }
    
    func rigisterHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("register")
    }
    
    func whitePollutionHandler(_ req: Request) throws -> Future<View> {

        let context = whitePollutionContext(userEmail:_authenticate(req)?.email,
                                            plasticBoxCount:"1亿",
                                            orderCount:"3000万+")
        return try req.view().render("whitePollution",context)
    }
    
    func airPollutionHandler(_ req: Request) throws -> Future<View> {
        let context = airPollutionContext(userEmail:_authenticate(req)?.email)
        return try req.view().render("airPollution",context)
    }
    
    func environmentScienceHandler (_ req: Request) throws -> Future<View> {
        let context = environmentScienceContext(userEmail:_authenticate(req)?.email)
        return try req.view().render("environmentScience",context)
    }
    
    func _authenticate(_ req:Request) -> User? {
        do {
            if try req.isAuthenticated(User.self) {
                return try req.requireAuthenticated(User.self)
            }
            else {
                return nil
            }
        } catch {
            return nil
        }
    }
}

struct homeContext: Encodable {
    let homeModules: [homeModuleContext]
    let userEmail:String?
}
struct homeModuleContext: Encodable {
    let imagePath:String
    let route:String
    let title:String
}
struct whitePollutionContext: Encodable {
    let userEmail:String?
    let plasticBoxCount:String
    let orderCount:String
}
struct airPollutionContext: Encodable {
    let userEmail:String?
}
struct environmentScienceContext: Encodable {
    let userEmail:String?
}
