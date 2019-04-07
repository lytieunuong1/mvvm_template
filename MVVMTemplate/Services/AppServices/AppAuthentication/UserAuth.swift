//
//  UserAuth.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/23/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import EVReflection

enum LoginType: String {
    case facebook = "facebook"
    case google = "google"
    case server = "server"
}

class UserAuth: ModelType {

    var username: String = ""
    var password: String = ""
    var fullname: String = ""
    var token: String = ""
    var email: String = ""
    var loginType: String = ""

    required init() {
        
    }



    override class func singularKeyPath() -> String {
        return "user"
    }



    override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [
            (key: "password" ,
             decodeConverter: {[unowned self] in self.password = ($0 as? String)! } ,
             encodeConverter: {[unowned self] in return self.password.md5()}
                )]
    }

}



extension UserAuth: Loginnable {

    func loginAPIName() -> String {
        return "login"
    }

    func logoutAPIName() -> String {
        return "logout"
    }

}



extension UserAuth: Registerrable {

    func registerAPIName() -> String {
        return "register"
    }
    
}



extension UserAuth: PasswordRefreshable {

    func passwordRefreshingAPIName() -> String {
        return "forgotPassword"
    }

}

extension UserAuth: SocialLoginable {
    func socialLoginAPIName() -> String {
        return "socialLogin"
    }

}


