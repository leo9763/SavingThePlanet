//
//  Numeric.swift
//  App
//
//  Created by NeroMilk on 2018/9/26.
//

import Foundation
import Cocoa
#if os(Linux)
import Glibc
#endif

class NumbericUtil {
    static func randomNumbericString(length: Int) -> String {
        let numbers = "1234567890"
        
        var result = ""
        for _ in 0..<length {
            let index = randomInt(min: 0, max: numbers.count - 1)
            result.append(numbers[numbers.index(numbers.startIndex, offsetBy: index)])
        }
        return result
    }
    
    public static func randomInt(min: Int, max:Int) -> Int {
        #if os(Linux)
        return Glibc.random() % max
        #else
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
        #endif
    }
}


