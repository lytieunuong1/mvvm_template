//
//  PasswordRefreshingViewModel.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/28/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


protocol PasswordRefreshingViewModelType {

    //MARK: Input
    var emailStringChangedEvent: PublishSubject<String> {get}
    var sendButtonTappedEvent: PublishSubject<Void> {get}

    //MARK: Output
    var errorStringObservable: Observable<String> {get}
    var successStringObservalbe: Observable<String> {get}
    var enableSendButtonObservable: Observable<Bool> {get}

}

class PasswordRefreshingViewModel: PasswordRefreshingViewModelType {

    //MARK: Variable for Output
    private var errorString = PublishSubject<String>()
    private var successString = PublishSubject<String>()
    private var enableSendButton = Variable<Bool>(false)

    //MARK: Input
    lazy var emailStringChangedEvent = PublishSubject<String>()
    lazy var sendButtonTappedEvent = PublishSubject<Void>()

    //MARK: Output
    lazy var errorStringObservable: Observable<String> = self.errorString
    lazy var successStringObservalbe: Observable<String> = self.successString
    lazy var enableSendButtonObservable: Observable<Bool> = self.enableSendButton.asObservable()

    //MARK: Variables
    private let disposeBag = DisposeBag()
    private lazy var user: UserAuth = UserAuth()

    init() {
        //respone events from view
        emailStringChangedEvent.bind {[unowned self] value in
            self.enableSendButton.value = value.isEmail()
            self.user.email = value
        }.disposed(by: disposeBag)

        sendButtonTappedEvent.do(onNext: {[unowned self] (_) in
                self.enableSendButton.value = false
            })
            .flatMap{ [unowned self] in
                AppConfiguration.shared.obtainAuthentication().forgotPassword(user: self.user)
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] (_) in
                self.enableSendButton.value = true
                self.successString.onNext("Change password was successful!")
                }, onError: {[unowned self] (error) in
                    self.enableSendButton.value = true
                    self.errorString.onNext(error.localizedDescription)
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)


    }

    //MARK: Helpful functions

}
