//
//  APIService.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/7/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
extension NSError {
    public convenience init(message: String) {
        self.init(domain: message, code: 99999, userInfo: nil)
    }
}
class APIService {
    //MARK: Request functions

    static func getAPIURLString(apiName: String)-> String {
        if AppConfiguration.shared.baseURL().hasSuffix("/") {
            return  AppConfiguration.shared.baseURL() + apiName
        }
        return  AppConfiguration.shared.baseURL() + "/" + apiName
    }



    static func request<T>(url: String, method: HTTPMethod, parameters: Parameters?, responeType: T.Type) -> Single<T>  where T : ModelType{
        return self.requestCheckErrorData(url:url, method: method, parameters: parameters).map({ (data) -> T in
//            return T()
            return AppResponeData.convertResponeData(data: data, type: responeType)
        })
    }


    
    static func requestArray<T>(url: String, method: HTTPMethod, parameters: Parameters?, responeType: T.Type) -> Single<[T]>  where T : ModelType{
        return self.requestCheckErrorData(url:url, method: method, parameters: parameters).map({ (data) -> [T] in
//            return []
            return AppResponeData.convertArrayResponeData(data: data, type: responeType)
        })
    }



    static func requestCheckErrorData(url: String, method: HTTPMethod, parameters: Parameters?) -> Single<Data> {
        return self.request(url: url, method: method, parameters: parameters)
            .flatMap { (data) -> PrimitiveSequence<SingleTrait, Data> in
                return Single.create(subscribe: { (single) -> Disposable in
                    if let error = AppResponeData.checkErrorResponeData(data: data) {
                        single(.error(NSError(message: error)))
                        return Disposables.create()
                    }
                    single(.success(data))
                    return Disposables.create()
                })
            }
    }



    static func request(url: String, method: HTTPMethod, parameters: Parameters?) -> Single<Data>{
        return Single<Data>.create(subscribe: { (single) -> Disposable in
            guard let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                single(.error(RxCocoaURLError.unknown))
                return Disposables.create{}
            }
            let request = Alamofire.request(urlString, method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
                if let error = response.error {
                    single(.error(error))
                    return
                }
                if let data = response.data {
                    single(.success(data))
                    return
                }
            }
            return Disposables.create {
                request.cancel()
            }
        })
    }
//
//
//
//    static func request<T>(url: String, method: HTTPMethod, parameters: Parameters?, responeType: T.Type, completionHandler:@escaping ((Result<T>) -> Void)) where T : ModelType {
//        self.requestCheckErrorData(url: url, method: method, parameters: parameters, completionHandler: { (message, data) in
//            AppResponeData.convertResponeData(data: data, completionHandler: completionHandler)
//        }) { (error) in
//            completionHandler(.error(error))
//        }
//    }
//
//
//
//    static func requestArray<T>(url: String, method: HTTPMethod, parameters: Parameters?, responeType: T.Type, completionHandler:@escaping ((Results<T>) -> Void)) where T : ModelType {
//        self.requestCheckErrorData(url: url, method: method, parameters: parameters, completionHandler: { (message, data) in
//            AppResponeData.convertArrayResponeData(data: data, completionHandler: completionHandler)
//        }) { (error) in
//            completionHandler(.error(error))
//        }
//    }
//
//    static func requestCheckErrorData(url: String, method: HTTPMethod, parameters: Parameters?, completionHandler:@escaping ((String, Data) -> Void), errorHandler: @escaping((String) -> Void ))  {
//        self.request(url: url, method: method, parameters: parameters, completionHandler: { (data) in
//            AppResponeData.checkErrorResponeData(data: data, successHandler: { (message, successData) in
//                completionHandler(message, successData)
//            }) { (error) in
//                errorHandler(error)
//            }
//        }) { (error) in
//            errorHandler(error)
//        }
//    }
//
//
//
//    static func request(url: String, method: HTTPMethod, parameters: Parameters?, completionHandler:@escaping ((Data) -> Void), errorHandler: @escaping((String) -> Void ))  {
//        guard let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
//            errorHandler("Unrecognized the link")
//            return
//        }
//        Alamofire.request(urlString, method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
//            if let error = response.error {
//                errorHandler(error.localizedDescription)
//                return
//            }
//            if let data = response.data {
//                completionHandler(data)
//                return
//            }else {
//                errorHandler("Have no respone data")
//                return
//            }
//        }
//    }
}


protocol APIServiceType{
    func resourceName() -> String

    func create<T>(customURL: String?, object: Creatable, responeType: T.Type) -> Single<T> where T : ModelType
    func read<T>(customURL: String?, predicate: NSPredicate?, responeType: T.Type) -> Single<[T]> where T : ModelType
    func update<T>(customURL: String?, object: Updateable, responeType: T.Type) -> Single<T> where T : ModelType
    func delete<T>(customURL: String?, object: Updateable, responeType: T.Type) -> Single<T> where T : ModelType

}

protocol Creatable {
    func createValue() -> [String : Any]
}

protocol Updateable {
    func idValue() -> String
    func updateValue() -> [String : Any]
}



enum Result<T> {
    case success(T)
    case error(String)
}

enum Results<T> {
    case success([T])
    case error(String)
}
