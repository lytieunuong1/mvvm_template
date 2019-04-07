//
//  AppAuthenticationService.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/26/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import Alamofire
import TNSocialNetWorkLogin
import RxSwift
import RxCocoa



class AppAuthenticationService: AuthenticationService {



    public private(set) var userAuth: UserAuth? {
        didSet {
            UserDefaults.standard.set(userAuth?.toDictionary(), forKey: "UserAuth")
        }
    }



    init() {
        if let user = UserDefaults.standard.object(forKey: "UserAuth") as? NSDictionary {
            userAuth = UserAuth(dictionary: user)
        }
    }



    func login(user: Loginnable)-> Single<UserAuth> {
        let urlString = APIService.getAPIURLString(apiName: user.loginAPIName())
        return APIService.request(url: urlString, method: .post, parameters: user.loginParams(), responeType: UserAuth.self).do(onNext: {[unowned self] (user) in
            self.userAuth = user

        })
    }



    func register(user: Registerrable) -> Single<Void> {
        let urlString = APIService.getAPIURLString(apiName: user.registerAPIName())
        return APIService.requestCheckErrorData(url: urlString, method: .post, parameters: user.registerParams()).map{_ in Void()}
    }



    func forgotPassword(user: PasswordRefreshable) -> Single<Void> {
         let urlString = APIService.getAPIURLString(apiName: user.passwordRefreshingAPIName())
        return APIService.requestCheckErrorData(url: urlString, method: .post, parameters: user.passwordRefreshingParams()).map{_ in Void()}
    }



    func logout() -> Single<Void> {
        if let user = self.userAuth {
            let urlString = APIService.getAPIURLString(apiName: user.logoutAPIName())
            return APIService.requestCheckErrorData(url: urlString, method: .post, parameters: user.logoutParams())
                .map{ _ in Void() }
                .do(onNext: {[unowned self] (_) in
                    self.userAuth = nil
                    TNAuthenticationManager.shared.obtainAuthentication().signOut()
                })
        }

        return Single<Void>.create(subscribe: { (completable) -> Disposable in
            completable(.error(RxError.noElements))
            return Disposables.create()

        })
    }



    func loginByFacebook(withReadPermissions permissions: [Dictionary<String, [String]>]?, from vc: UIViewController?) -> Single<UserAuth> {
        return Single<LoginResult>.create(subscribe: { (single) -> Disposable in
            TNAuthenticationManager.shared.obtainAuthentication()
                .signInByFacebook(withReadPermissions: permissions, from: vc, completionHandler: { (result) in
                    single(.success(result))
            })
            return Disposables.create()
        }).flatMap({[unowned self] (result) -> PrimitiveSequence<SingleTrait, UserAuth> in
            self.loginToServerFromSocial(result: result, loginType: .facebook)
        })
    }



    func loginByGoogle() -> Single<UserAuth> {
        return Single<LoginResult>.create(subscribe: { (single) -> Disposable in
            TNAuthenticationManager.shared.obtainAuthentication()
                .signInByGoogle(completionHandler: { (result) in
                single(.success(result))
            })
            return Disposables.create()
        }).flatMap({[unowned self] (result) -> PrimitiveSequence<SingleTrait, UserAuth> in
            self.loginToServerFromSocial(result: result, loginType: .facebook)
        })
    }
//    func login(user: Loginnable, completionHandler: @escaping( (Result<UserAuth>) -> Void)) {
//        let urlString = APIService.getAPIURLString(apiName: user.loginAPIName())
//
//
//        APIService.request(url: urlString, method: HTTPMethod.post, parameters: user.loginParams(), responeType: UserAuth.self) {[unowned self]  (result) in
//            switch result {
//            case .success(let user):
//                self.userAuth = user
//                completionHandler(.success(user))
//                break
//            case .error(let err):
//                completionHandler(.error(err))
//                break
//            }
//        }
//    }
//
//
//
//    func register(user: Registerrable, completionHandler: @escaping( (Result<UserAuth?>) -> Void)) {
//        let urlString = APIService.getAPIURLString(apiName: user.registerAPIName())
//        APIService.requestCheckErrorData(url: urlString, method: HTTPMethod.post, parameters: user.registerParams(), completionHandler: {(_, _) in
//            completionHandler(.success(nil))
//        }, errorHandler: { (error) in
//            completionHandler(.error(error))
//        })
//    }
//
//
//
//    func forgotPassword(user: PasswordRefreshable, completionHandler: @escaping ((Result<String>) -> Void)) {
//        let urlString = APIService.getAPIURLString(apiName: user.passwordRefreshingAPIName())
//        APIService.requestCheckErrorData(url: urlString, method: HTTPMethod.post, parameters: user.passwordRefreshingParams(), completionHandler: {(message, _) in
//            completionHandler(.success(message))
//        }, errorHandler: { (error) in
//            completionHandler(.error(error))
//        })
//    }
//
//
//
//    func logout(completionHandler: @escaping ((Result<String>) -> Void)) {
//        if let user = self.userAuth {
//            let urlString = APIService.getAPIURLString(apiName: user.logoutAPIName())
//            APIService.requestCheckErrorData(url: urlString, method: HTTPMethod.post, parameters: user.logoutParams(), completionHandler: {[unowned self]  (message, _) in
//                self.userAuth = nil
//                TNAuthenticationManager.shared.obtainAuthentication().signOut()
//                completionHandler(.success(message))
//            }, errorHandler: { (error) in
//                completionHandler(.error(error))
//            })
//        }
//    }



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {
        TNAuthenticationManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }



//    func loginByFacebook(withReadPermissions permissions: [Dictionary<String, [String]>]?, from vc: UIViewController?, completionHandler: @escaping ((Result<UserAuth>) -> Void)) {
//        TNAuthenticationManager.shared.obtainAuthentication().signInByFacebook(withReadPermissions: permissions, from: vc) {[unowned self] (result) in
//            self.loginToServerFromSocial(result: result, loginType: LoginType.facebook, completionHandler: completionHandler)
//        }
//    }
//
//
//
//    func loginByGoogle(completionHandler: @escaping ((Result<UserAuth>) -> Void)) {
//        TNAuthenticationManager.shared.obtainAuthentication().signInByGoogle {[unowned self] (result) in
//            self.loginToServerFromSocial(result: result, loginType: LoginType.google, completionHandler: completionHandler)
//        }
//    }



    // MARK: Social login support functions
    private func loginToServerFromSocial(result: LoginResult, loginType: LoginType) -> Single<UserAuth> {
        let loginSingle = Single<UserAuth>.create(subscribe: { (single) -> Disposable in
            switch result {
            case .error(let error):
                single(.error(error))
                break
            case .cancel:
                single(.error(NSError(domain: "", code: CocoaError.userCancelled.rawValue, userInfo: nil)))
                break
            case .success(let u):
                let user = UserAuth(from: u)
                user.loginType = loginType.rawValue
                single(.success(user))
                break
            }
            return Disposables.create()
        }).flatMap({ (user) -> Single<UserAuth> in
            let urlString = APIService.getAPIURLString(apiName: user.socialLoginAPIName())
            return APIService.request(url: urlString, method: .post, parameters: user.socialLoginParams(), responeType: UserAuth.self)
        }).do(onNext: {[unowned self] (user) in
            self.userAuth = user
        })
        return loginSingle
    }

//    private func loginToServerFromSocial(result: LoginResult, loginType: LoginType, completionHandler: @escaping ((Result<UserAuth>) -> Void)) {
//        switch result {
//        case .error(let error):
//            completionHandler(.error(error.localizedDescription))
//            break
//        case .cancel:
//            completionHandler(.error(""))
//            break
//        case .success(let u):
//            let user = UserAuth(from: u)
//            user.loginType = loginType.rawValue
////            self.socialLogin(user: user, completionHandler: completionHandler)
//            break
//        }
//    }




//    private func socialLogin(user: SocialLoginable, completionHandler: @escaping( (Result<UserAuth>) -> Void)) {
//        let urlString = APIService.getAPIURLString(apiName: user.socialLoginAPIName())
//        APIService.request(url: urlString, method: HTTPMethod.post, parameters: user.socialLoginParams(), responeType: UserAuth.self) {[unowned self] (result) in
//            switch result {
//            case .success(let user):
//                self.userAuth = user
//                completionHandler(.success(user))
//                break
//            case .error(let err):
//                completionHandler(.error(err))
//                break
//            }
//        }
//    }

}



extension UserAuth {

    convenience init(from user: TNUser) {
        self.init()
        email = user.email ?? ""
        fullname = (user.firstName ?? "") + " " + (user.lastName ?? "")
        username = user.name ?? ""
    }

}

