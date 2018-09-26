//
//  Network.swift
//  App
//
//  Created by NeroMilk on 2018/9/26.
//
import Vapor
import Foundation

func jsonResponse(inBody objct:[String:String]) throws -> HTTPResponse {
    var message: HTTPResponse = HTTPResponse()
    message.contentType = .json
    message.status = .ok
    message.body = try HTTPBody(data: JSONEncoder().encode(objct))
    return message
}
