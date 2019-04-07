//
//  RegisterViewModel.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/26/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


protocol RegisterViewModelType {

    //MARK: Input
    var fullNameStringChangedEvent: PublishSubject<String> {get}
    var userNameStringChangedEvent: PublishSubject<String> {get}
    var passwordStringChangedEvent: PublishSubject<String> {get}
    var repasswordStringChangedEvent: PublishSubject<String> {get}
    var registerButtonTappedEvent: PublishSubject<Void> {get}
//    var cancelButtonTappedEvent: PublishSubject<Void> {get}

    //MARK: Output
    var enableRegisterButtonObservable: Observable<Bool> {get}
    var successStringObservable: Observable<String> {get}
    var errorStringObservable: Observable<String> {get}
}


class RegisterViewModel: RegisterViewModelType {
    //MARK: Variable for Output
    private var enableRegisterButton = Variable<Bool>(false)
    private var successString = PublishSubject<String>()
    private var errorString = PublishSubject<String>()

    //MARK: Input
    lazy var fullNameStringChangedEvent = PublishSubject<String>()
    lazy var userNameStringChangedEvent = PublishSubject<String>()
    lazy var passwordStringChangedEvent = PublishSubject<String>()
    lazy var repasswordStringChangedEvent = PublishSubject<String>()
    lazy var registerButtonTappedEvent = PublishSubject<Void>()
//    lazy var cancelButtonTappedEvent = PublishSubject<Void>()

    //MARK: Output
    lazy var enableRegisterButtonObservable: Observable<Bool> = self.enableRegisterButton.asObservable()
    lazy var successStringObservable: Observable<String> = self.successString
    lazy var errorStringObservable: Observable<String> = self.errorString

    //MARK: Variables
    private let disposeBag = DisposeBag()
    private let user = UserAuth()
    private var repassword: String = ""
//    private var authService = AuthenticationService()

    init() {
        //respone events from view
        fullNameStringChangedEvent.bind {[unowned self] value in
            self.user.fullname = value
            self.enableRegisterButton.value = self.valid()
        }.disposed(by: disposeBag)

        userNameStringChangedEvent.bind {[unowned self] value in
            self.user.username = value
            self.enableRegisterButton.value = self.valid()
        }.disposed(by: disposeBag)

        passwordStringChangedEvent.bind {[unowned self] value in
            self.user.password = value
            self.enableRegisterButton.value = self.valid()
        }.disposed(by: disposeBag)

        repasswordStringChangedEvent.bind {[unowned self] value in
            self.repassword = value
            self.enableRegisterButton.value = self.valid()
        }.disposed(by: disposeBag)

//        registerButtonTappedEvent.debug().flatMap { [unowned self] in
//            AppConfiguration.shared.obtainAuthentication().register(user: self.user).catchError({ (error) -> PrimitiveSequence<SingleTrait, Void> in
//                self.errorString.onNext(error.localizedDescription)
//                 
//            })
//            }
//            .observeOn(MainScheduler.asyncInstance)
//            .subscribe(onNext: { [unowned self] (_) in
//                self.successString.onNext("Register was successful!")
//            }, onError: { [unowned self] (error) in
//                self.errorString.onNext(error.localizedDescription)
//            }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

    }

    //MARK: Helpful functions
    private func valid() -> Bool {
        return self.user.fullname != "" && self.user.username != "" && self.user.password != "" && self.user.password == self.repassword
    }
}
