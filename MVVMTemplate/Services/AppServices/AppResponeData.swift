//
//  AppResponeData.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/26/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import EVReflection
//import RxSwift

class ResponeResult: ModelType {

    var success: Bool = false
    var message: String = ""

}

class AppResponeData {
    static func convertResponeData<T>(data: Data, completionHandler: @escaping ((Result<T>) -> Void)) where T : ModelType{
        let value = T(data: data, conversionOptions: T.conversionDeserializeOptions(), forKeyPath: T.singularKeyPath())
        completionHandler(.success(value))
    }
    static func convertResponeData<T>(data: Data, type: T.Type) -> T where T : ModelType{
        let value = T(data: data, conversionOptions: T.conversionDeserializeOptions(), forKeyPath: T.singularKeyPath())
        return value
//        completionHandler(.success(value))
    }

    static func convertArrayResponeData<T>(data: Data, type: T.Type) -> [T] where T : ModelType{
        let values = [T](data: data, conversionOptions: T.conversionDeserializeOptions(), forKeyPath: T.pluralKeyPath())
        return values
        //        completionHandler(.success(value))
    }

    static func checkErrorResponeData(data: Data)-> String?{
        let result = ResponeResult(data: data)
        if !result.success {
            return result.message
//            return (isError: true, result.message)
//            errorHandler(result.message)
        } else {
            return nil
//            return (isError: false, result.message)
//            successHandler(result.message, data)
        }
    }




    static func convertArrayResponeData<T>(data: Data, completionHandler: @escaping ((Results<T>) -> Void)) where T : ModelType{
        let value = [T](data: data, conversionOptions: T.conversionDeserializeOptions(), forKeyPath: T.pluralKeyPath())
        completionHandler(.success(value))
    }

//    static func checkErrorResponeData(data: Data) -> String{
//        let result = ResponeResult(data: data)
//        if !result.success {
////            errorHandler(result.message)
//        } else {
////            successHandler(result.message, data)
//        }
//    }

    
    static func checkErrorResponeData(data: Data, successHandler:@escaping ((String, Data) -> Void), errorHandler:@escaping ((String) -> Void)){
        let result = ResponeResult(data: data)
        if !result.success {
            errorHandler(result.message)
        } else {
            successHandler(result.message, data)
       }
    }
    
}
