//
//  ModelType.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/27/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import EVReflection

class ModelType : EVObject {

    //Options will be use when convert from json to object or vice versa
    class func conversionDeserializeOptions() -> ConversionOptions {
        return ConversionOptions.DefaultDeserialize
    }

    class func conversionSerializeOptions() -> ConversionOptions {
        return ConversionOptions.DefaultSerialize
    }

    //Key path of singular respone data
    class func singularKeyPath() -> String {
        return "example"
    }

    //Key path of plural respone data
    class func pluralKeyPath() -> String {
        return singularKeyPath() + "s"
    }
    
}


extension Creatable where Self: ModelType {
    func createValue() -> [String : Any] {
        return self.toDictionary(Self.conversionSerializeOptions()) as! [String : Any]
    }
}

extension Updateable where Self: ModelType {

    func updateValue() -> [String : Any] {
        return self.toDictionary(Self.conversionSerializeOptions()) as! [String : Any]
    }
}

extension Loginnable where Self: ModelType {

    func loginParams() -> [String : Any] {
        return self.toDictionary(Self.conversionSerializeOptions()) as! [String : Any]
    }

    func logoutParams() -> [String : Any] {
        return self.toDictionary(Self.conversionSerializeOptions()) as! [String : Any]
    }
}

extension Registerrable where Self: ModelType {
    func registerParams() -> [String : Any] {
        return self.toDictionary(Self.conversionSerializeOptions()) as! [String : Any]
    }
}

extension PasswordRefreshable where Self: ModelType {
    func passwordRefreshingParams() -> [String : Any] {
        return self.toDictionary(Self.conversionSerializeOptions()) as! [String : Any]
    }
}

extension SocialLoginable where Self: ModelType {
    func socialLoginParams() -> [String : Any] {
        return self.toDictionary(Self.conversionSerializeOptions()) as! [String : Any]
    }
}
