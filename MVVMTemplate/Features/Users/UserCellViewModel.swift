//
//  UserCellViewModel.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/8/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import RxSwift

struct UserCellViewModel {
    //MARK: Output
    let nameString = BehaviorSubject<String>(value: "")
    let jobString = BehaviorSubject<String>(value: "")

    

    
    init(user: User) {
        nameString.onNext(user.name)
        jobString.onNext(user.job)
    }
}
