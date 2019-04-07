//
//  CommonHelper.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/7/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation

class CommonHelper {

    enum PrintType: String {
        case info = "Info"
        case warning = "Warning"
        case error = "Error"
    }

    static func print(type: PrintType, atFunc funcName: String, message: String) {
        #if DEBUG
            Swift.print("**\(type.rawValue)**: \"\(message)\" at function `\(funcName)`")
        #endif
    }
    
   
}
