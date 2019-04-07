//
//  User.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/7/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import EVReflection



class User : ModelType {

    //MARK: API Properties
    var name: String = ""
    var job: String = ""

    //MARK: Ignored Properties
    //properties will be ignored to write or read to/from json


    override class func singularKeyPath() -> String {
        return "user"
    }

}

extension User : Creatable {}



extension User : Updateable {
    func idValue() -> String {
        return name
    }

}
