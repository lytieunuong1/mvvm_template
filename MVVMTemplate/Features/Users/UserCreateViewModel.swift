//
//  UserCreateViewModel.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/8/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift



protocol UserCreateViewModelType {

    //MARK: Input
    var nameStringChangedEvent: PublishSubject<String> {get}
    var jobStringChangedEvent: PublishSubject<String> {get}
    var addButtonTappedEvent: PublishSubject<Void> {get}
    var userUpdatedEvent: PublishSubject<User> {get}

    //MARK: Output
    var addButtonEnableObservable: Observable<Bool> {get}
    var nameStringObservable: Observable<String> {get}
    var jobStringObservable: Observable<String> {get}
    var successStringObvervable: Observable<String> {get}
    var errorStringObservable: Observable<String> {get}

}



class UserCreateViewModel : NSObject, UserCreateViewModelType {

    //MARK: Variable for output
    private var nameString = PublishSubject<String>()
    private var jobString = PublishSubject<String>()
    private var addButtonEnable = Variable<Bool>(false)
    private var successString = PublishSubject<String>()
    private var errorString = PublishSubject<String>()

    //MARK: Input
    lazy var nameStringChangedEvent = PublishSubject<String>()
    lazy var jobStringChangedEvent = PublishSubject<String>()
    lazy var addButtonTappedEvent = PublishSubject<Void>()
    lazy var userUpdatedEvent = PublishSubject<User>()

    //MARK: Output
    lazy var addButtonEnableObservable = self.addButtonEnable.asObservable()
    lazy var nameStringObservable: Observable<String> = self.nameString
    lazy var jobStringObservable: Observable<String> = self.jobString
    lazy var successStringObvervable: Observable<String> = self.successString
    lazy var errorStringObservable: Observable<String> = self.errorString

    //MARK: Variables
    private let userService = UserAPIService()
    private var user: User = User()
    private var disposeBag = DisposeBag()
    private var isUpdating = false



    override init() {
        super.init()
        //Setting for the update
        userUpdatedEvent.bind {[unowned self] (user) in
            self.user = user
            self.isUpdating = true
            self.nameString.onNext(user.name)
            self.jobString.onNext(user.job)
            self.addButtonEnable.value = true
        }.disposed(by: disposeBag)

        //Listen when user typing and validate value
        nameStringChangedEvent.bind {[unowned self] (value) in
            self.user.name = value
            self.addButtonEnable.value = self.valid(user: self.user)
        }.disposed(by: disposeBag)

        jobStringChangedEvent.bind {[unowned self] (value) in
            self.user.job = value
            self.addButtonEnable.value = self.valid(user: self.user)
        }.disposed(by: disposeBag)

//        Solve when the user tap on save button
        addButtonTappedEvent.flatMap{ [unowned self] in
            self.saveUser()
        }
        .subscribe(onNext: {[unowned self] (user) in
            self.updateUI()
        }, onError: {[unowned self] (error) in
            self.errorString.onNext(error.localizedDescription)
        }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
    }


    //MARK: Helpful functions
    private func saveUser() -> Single<User> {
        if !self.isUpdating{
            return userService.create(customURL: nil, object: user, responeType: User.self)
        }
        return userService.update(customURL: nil, object: user, responeType: User.self)
    }

    private func updateUI() {
        self.addButtonEnable.value = true
        if self.isUpdating{
            self.successString.onNext("Update was success!")
            return
        }
        self.nameString.onNext("")
        self.jobString.onNext("")
        self.successString.onNext("Creation was success!")
    }

//    private func addUser() {
//        userService.create(customURL: nil, object: user, responeType: User.self).subscribe(onSuccess: { (_) in
//            self.nameString.onNext("")
//            self.jobString.onNext("")
//            self.addButtonEnable.value = true
//            self.successString.onNext("Creation was success!")
//        }) { (error) in
//            self.errorString.onNext("Creation was error!")
//            self.addButtonEnable.value = true
//        }.disposed(by: disposeBag)
////        userService.create(object: user, responeType: User.self, completionHandler: { (result) in
////            self.addButtonEnable.value = true
////            switch(result) {
////            case .success(_):
////                self.nameString.onNext("")
////                self.jobString.onNext("")
////                self.addButtonEnable.value = false
////                self.successString.onNext("Creation was success!")
////                break
////            case .error(let err):
////                self.errorString.onNext("Creation was error!")
////                self.addButtonEnable.value = true
////                break
////            }
////
////        })
//    }
//
//
//
//    private func updateUser() {
//        userService.update(object: self.user, responeType: User.self, completionHandler: { (result) in
//            self.addButtonEnable.value = true
//            switch(result) {
//            case .success(let user):
//                self.successString.onNext("Update was success!")
//                break
//            case .error(let err):
//                self.errorString.onNext("Update was error!")
//                break
//            }
//
//        })
//    }



    private func valid(user: User) -> Bool {
        return user.job != "" && user.name != ""
    }



}
