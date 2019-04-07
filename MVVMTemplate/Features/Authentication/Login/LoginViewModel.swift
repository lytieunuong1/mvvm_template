//
//  LoginViewModel.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/26/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift



protocol LoginViewModelType {

    //MARK: Input
    var nameStringChangedEvent: PublishSubject<String> {get}
    var passwordStringChangedEvent: PublishSubject<String> {get}
    var signInButtonTappedEvent: PublishSubject<Void> {get}
    var googleButtonTappedEvent: PublishSubject<Void> {get}
    var facebookButtonTappedEvent: PublishSubject<Void> {get}

    //MARK: Output
    var enableSignInButtonObservable: Observable<Bool> {get}
    var isLoadingObservable: Observable<Bool> {get}
    var loginSuccessObservalbe: Observable<Void> {get}
    var errorStringObservable: Observable<String> {get}

}

class LoginViewModel: LoginViewModelType {
    //MARK: Variable for Output
//    private var enableSignInButton = Variable<Bool>(false)
    private var loginSuccess = PublishSubject<Void>()
    private var isLoading = Variable<Bool>(false)
    private var errorString = PublishSubject<String>()

    //MARK: Input
    lazy var nameStringChangedEvent: PublishSubject<String> = PublishSubject<String>()
    lazy var passwordStringChangedEvent: PublishSubject<String> = PublishSubject<String>()
    lazy var signInButtonTappedEvent: PublishSubject<Void> = PublishSubject<Void>()
    lazy var googleButtonTappedEvent: PublishSubject<Void> = PublishSubject<Void>()
    lazy var facebookButtonTappedEvent: PublishSubject<Void> = PublishSubject<Void>()

    //MARK: Output
    lazy var enableSignInButtonObservable: Observable<Bool> = Observable.of(self.isLoading.asObservable().map({!$0}), Observable.combineLatest(self.nameStringChangedEvent, self.passwordStringChangedEvent){[unowned self] in return self.valid(userName: $0, password: $1) }).merge()
    lazy var isLoadingObservable: Observable<Bool> = self.isLoading.asObservable()
    lazy var loginSuccessObservalbe: Observable<Void> = self.loginSuccess
    lazy var errorStringObservable: Observable<String>  = self.errorString

    //MARK: Variables
    private let disposeBag = DisposeBag()
    private var user: UserAuth = UserAuth()



    init() {
        //respone events from view
        nameStringChangedEvent.bind {[unowned self] (value) in
            self.user.username = value
        }.disposed(by: disposeBag)

        passwordStringChangedEvent.bind {[unowned self] (value) in
            self.user.password = value
        }.disposed(by: disposeBag)

        let signIn = signInButtonTappedEvent.flatMap{ [unowned self] in
            AppConfiguration.shared.obtainAuthentication().login(user: self.user)
        }

        let fbSignIn = facebookButtonTappedEvent.flatMap{
            AppConfiguration.shared.obtainAuthentication().loginByFacebook(withReadPermissions: nil, from: nil)
        }

        let ggSignIn = googleButtonTappedEvent.flatMap{
            AppConfiguration.shared.obtainAuthentication().loginByGoogle()
            }

        Observable.merge(signIn,fbSignIn,ggSignIn)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (user) in
            CommonHelper.print(type: .info , atFunc: "login", message: "user name: \(String(describing: user.username)) logined in")
            self?.loginSuccess.onNext(())
        }, onError: {[weak self]  (error) in
            self?.errorString.onNext(error.localizedDescription)
        }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

    }


    
    //MARK: Helpful functions
    private func checkResult(result: Result<UserAuth>){
        switch result {
        case .success(let u):
            CommonHelper.print(type: .info , atFunc: "login", message: "user name: \(String(describing: u.username)) logined in")
            self.loginSuccess.onNext(())
            break
        case .error(let err):
            self.errorString.onNext(err)
            break
        }
    }



    private func valid(userName: String?, password: String?) -> Bool{
        return userName != nil && userName != "" && password != nil && password != ""
    }

//    private func valid(user: UserAuth) -> Bool {
//        return self.user.username != "" && self.user.password != ""
//    }
}

