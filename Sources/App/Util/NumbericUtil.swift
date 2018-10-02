//
//  Numeric.swift
//  App
//
//  Created by NeroMilk on 2018/9/26.
//

import Foundation

class NumbericUtil {
    static func randomNumbericString(length: Int) -> String {
        let numbers = "1234567890"
        
        var result = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(numbers.count)))
            result.append(numbers[numbers.index(numbers.startIndex, offsetBy: index)])
        }
        return result
    }
}

