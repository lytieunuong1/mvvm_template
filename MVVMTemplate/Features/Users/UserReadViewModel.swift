//
//  UserReadViewModel.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/8/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa



protocol UserReadViewModelType {

    //MARK: Input
    var deleteButtonTappedEvent: PublishSubject<Void> {get}
    var userSelectedEvent: PublishSubject<User> {get}
    var reloadUserListEvent: PublishSubject<Void> {get}
    var deletedUserEvent: PublishSubject<IndexPath> {get}
    var logoutButtonTappedEvent: PublishSubject<Void> {get}

    //MARK: Output
    var selectedDeleteButtonObservable: Observable<Bool> {get}
    var userListObservable: Observable<[User]> {get}
    var userSelectedObservable: Observable<User> {get}
    var logoutSuccessObservable: Observable<Void> {get}

}


class UserReadViewModel: UserReadViewModelType {

    //MARK: Variable for Output
    private var selectedDeleteButton = Variable<Bool>(false)
    private var userList = Variable<[User]>([])
    private var userSelected = PublishSubject<User>()
    private var logoutSuccess = PublishSubject<Void>()

    //MARK: Input
    lazy var deleteButtonTappedEvent = PublishSubject<Void>()
    lazy var userSelectedEvent = PublishSubject<User>()
    lazy var reloadUserListEvent = PublishSubject<Void>()
    lazy var deletedUserEvent = PublishSubject<IndexPath>()
    lazy var logoutButtonTappedEvent = PublishSubject<Void>()

    //MARK: Output
    lazy var selectedDeleteButtonObservable: Observable<Bool> = self.selectedDeleteButton.asObservable()
    lazy var userListObservable: Observable<[User]> = self.userList.asObservable()
    lazy var userSelectedObservable: Observable<User> = self.userSelected
    lazy var logoutSuccessObservable: Observable<Void> = self.logoutSuccess

    //MARK: Variables
    private let userService = UserAPIService()
    private let disposeBag = DisposeBag()

    

    init() {

        //Listen refresh data requirement from UI
        reloadUserListEvent.flatMap{ [unowned self] in self.loadUser() }
            .asDriver(onErrorJustReturn: [])
            .drive(userList)
            .disposed(by: disposeBag)

        deleteButtonTappedEvent.map{ [unowned self] in !self.selectedDeleteButton.value }
            .bind(to: selectedDeleteButton)
            .disposed(by: disposeBag)

        //Listen the deleted person.
        deletedUserEvent.map{ [unowned self] in self.userList.value[$0.row] }
            .flatMap{ [unowned self] in self.deleteUser($0) }
            .withLatestFrom(deletedUserEvent)
            .bind { [unowned self] (indexPath) in
                self.userList.value.remove(at: indexPath.row)
            }.disposed(by: disposeBag)

        //Listen when the user selected a person.
        userSelectedEvent.bind(to: userSelected).disposed(by: disposeBag)

        logoutButtonTappedEvent.flatMap{ AppConfiguration.shared.obtainAuthentication().logout() }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (_) in
                self?.logoutSuccess.onNext(())
            }, onError: { (error) in
                CommonHelper.print(type: .error, atFunc: "Logout", message: error.localizedDescription)
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }



    //MARK: Helpful functions
    private func loadUser() -> Single<[User]> {
        return userService.read(customURL: nil, predicate: nil, responeType: User.self)
    }
//    private func loadUser() {
//        userService.read(predicate: nil, responeType: User.self) {[weak self] (result) in
//            switch (result) {
//            case .success(let array):
//                //update userList
//                self?.userList.value = array
//                break
//            case .error(let error):
//                //we can show message here
//                break
//            }
//        }
//    }


    private func deleteUser(_ user: User) -> Single<User> {
        return userService.delete(customURL: nil, object: user, responeType: User.self)
    }


//    private func deleteUser(at indexPath: IndexPath) {
//        let user = self.userList.value[indexPath.row]
//        userService.delete(object: user, responeType: User.self) {[unowned self] (result) in
//            switch (result) {
//            case .success(_):
//                //Remove the person in list after deleted at server.
//                 self.userList.value.remove(at: indexPath.row)
//                break
//            case .error(let error):
//                //we can show message here
//                 CommonHelper.print(type: .error, atFunc: "deleteUser", message: "Delete user got an error: " + error)
//                break
//            }
//        }
//    }



//    private func logout() {
//        AppConfiguration.shared.obtainAuthentication().logout(completionHandler: {[weak self] (result) in
//            switch result {
//            case .success(let message):
//                CommonHelper.print(type: .info, atFunc: "Logout", message: message)
//                self?.logoutSuccess.onNext(())
//                break
//            case .error(let error):
//                CommonHelper.print(type: .error, atFunc: "Logout", message: error)
//                break
//            }
//        })
//    }
}
