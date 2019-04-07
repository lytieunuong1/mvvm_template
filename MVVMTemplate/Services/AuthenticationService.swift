//
//  AuthenticationService.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/7/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol AuthenticationService {

    var userAuth: UserAuth? {get}

//    func login(user: Loginnable, completionHandler: @escaping( (Result<UserAuth>) -> Void))
//
//    func register(user: Registerrable, completionHandler: @escaping( (Result<UserAuth?>) -> Void))
//
//    func forgotPassword(user: PasswordRefreshable, completionHandler: @escaping((Result<String>) -> Void))
//
//    func logout(completionHandler: @escaping((Result<String>) -> Void))
    func login(user: Loginnable) -> Single<UserAuth>

    func register(user: Registerrable) -> Single<Void>

    func forgotPassword(user: PasswordRefreshable) -> Single<Void>

    func logout() -> Single<Void>

//
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)

    func loginByFacebook(withReadPermissions: [Dictionary<String, [String]>]?, from vc: UIViewController?) -> Single<UserAuth>

    func loginByGoogle() -> Single<UserAuth>
//
//    func loginByFacebook(withReadPermissions: [Dictionary<String, [String]>]?, from vc: UIViewController?, completionHandler: @escaping( (Result<UserAuth>) -> Void))
//
//    func loginByGoogle(completionHandler: @escaping( (Result<UserAuth>) -> Void))

}


protocol Loginnable {
    func loginAPIName() -> String
    func loginParams() -> [String : Any]
    func logoutAPIName() -> String
    func logoutParams() -> [String : Any]
}

protocol Registerrable {
    func registerAPIName() -> String
    func registerParams() -> [String : Any]
}

protocol PasswordRefreshable {
    func passwordRefreshingAPIName() -> String
    func passwordRefreshingParams() -> [String : Any]
}

protocol SocialLoginable {
    func socialLoginAPIName() -> String
    func socialLoginParams() -> [String : Any]
}

