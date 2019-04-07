//
//  UserCreateViewController.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/8/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserCreateViewController: BaseViewController {

    //MARK: UI variables
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var addButton: UIBarButtonItem!

    //MARK: Private variables
    private var viewModel: UserCreateViewModelType = UserCreateViewModel()
    private var disposeBag = DisposeBag()

    //MARK: Public variables
    var updatingUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.addButton
        // Do any additional setup after loading the view.
        bindViewModel()
        setupActions()
        if let user = updatingUser {
            viewModel.userUpdatedEvent.onNext(user)
            self.nameTextField.isEnabled = false
        }

    }


    //MARK: Bind Output data from viewModel
    func bindViewModel() {

        viewModel.addButtonEnableObservable.bind{ [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.navigationItem.rightBarButtonItem?.isEnabled = value
            strongSelf.addButton.isEnabled = value
        }.disposed(by: disposeBag)

        viewModel.nameStringObservable.bind(to: nameTextField.rx.text).disposed(by: disposeBag)

        viewModel.jobStringObservable.bind(to: jobTextField.rx.text).disposed(by: disposeBag)

        viewModel.successStringObvervable.bind { [weak self] (value) in
            self?.showMessage(title: "Success", message: value)
        }.disposed(by: disposeBag)

        viewModel.errorStringObservable.bind { [weak self] (value) in
            self?.showMessage(title:"Error", message: value)
        }.disposed(by: disposeBag)
    }



    //MARK: Map UI's actions to Input of the viewModel
    func setupActions() {
        //after 0.2s will send current value to the nameStringChangedEvent.
        nameTextField.rx.text.orEmpty.skip(1)
            .throttle(0.2, scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged({$0 == $1})
            .bind(to: viewModel.nameStringChangedEvent)
            .disposed(by: disposeBag)

        jobTextField.rx.text.orEmpty.skip(1)
            .throttle(0.2, scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged({$0 == $1})
            .bind(to: viewModel.jobStringChangedEvent)
            .disposed(by: disposeBag)

        addButton.rx.tap.bind(to:viewModel.addButtonTappedEvent).disposed(by: disposeBag)

    }


    
    //MARK: Helpful functions

}
