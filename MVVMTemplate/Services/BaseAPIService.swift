//
//  BaseAPIService.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/7/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import RxSwift

class BaseAPIService: APIServiceType {


    func resourceName() -> String {
        return "example"
    }



    //MARK: CRUD functions
    func create<T>(customURL: String?, object: Creatable, responeType: T.Type) -> PrimitiveSequence<SingleTrait, T> where T : ModelType {
        return APIService.request(url: getURL(customURL), method: .post, parameters: object.createValue(), responeType: responeType)
    }

    func read<T>(customURL: String?, predicate: NSPredicate?, responeType: T.Type) -> PrimitiveSequence<SingleTrait, [T]> where T : ModelType {
        return APIService.requestArray(url: queryURL(customURL, predicate: predicate), method: .get, parameters: nil,responeType: responeType)
    }

    func update<T>(customURL: String?, object: Updateable, responeType: T.Type) -> PrimitiveSequence<SingleTrait, T> where T : ModelType {
        return APIService.request(url: memberURL(param: object.idValue()), method: .put, parameters: object.updateValue(),responeType: responeType)
    }

    func delete<T>(customURL: String?, object: Updateable, responeType: T.Type) -> PrimitiveSequence<SingleTrait, T> where T : ModelType {
        return APIService.request(url: self.memberURL(param: object.idValue()), method: .delete , parameters: nil,responeType: responeType)

    }

//    func create<T>(customURL: String? = nil, object: Creatable, responeType: T.Type, completionHandler: @escaping ((Result<T>) -> Void)) where T : ModelType  {
//        APIService.request(url: getURL(customURL), method: .post, parameters: object.createValue(), responeType: responeType, completionHandler: completionHandler)
//    }
//
//
//
//    func read<T>(customURL: String? = nil, predicate: NSPredicate?, responeType: T.Type, completionHandler: @escaping ((Results<T>) -> Void)) where T : ModelType  {
//        APIService.requestArray(url: queryURL(customURL, predicate: predicate), method: .get, parameters: nil,responeType: responeType, completionHandler: completionHandler)
//    }
//
//
//
//    func update<T>(customURL: String? = nil, object: Updateable, responeType: T.Type, completionHandler: @escaping ((Result<T>) -> Void)) where T : ModelType {
//        APIService.request(url: memberURL(param: object.idValue()), method: .put, parameters: object.updateValue(),responeType: responeType, completionHandler: completionHandler)
//    }
//
//
//
//    func delete<T>(customURL: String? = nil, object: Updateable, responeType: T.Type, completionHandler: @escaping ((Result<T>) -> Void)) where T : ModelType {
//        APIService.request(url: memberURL(param: object.idValue()), method: .delete , parameters: nil, responeType: responeType, completionHandler: completionHandler)
//    }



    //MARK: Get URL functions
    func resourceNameURL() -> String {
        return APIService.getAPIURLString(apiName: resourceName())
    }



    func memberURL(param: String) -> String {
        return resourceNameURL() + "/" + param
    }



    func getURL(_ customURL: String?) -> String {
        return customURL != nil ? APIService.getAPIURLString(apiName: customURL!) : resourceNameURL()
    }



    func queryURL(_ customURL: String?, predicate: NSPredicate?) -> String {
        var query = ""
        if let predicate = predicate {
            query = "?" + predicate.predicateFormat
        }
        return getURL(customURL) + query
    }

}
