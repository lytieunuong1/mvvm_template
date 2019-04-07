//
//  PasswordRefreshingViewController.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/28/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import UIKit
import RxSwift

class PasswordRefreshingViewController: BaseViewController {

    //MARK: UI variables
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: Private variables
    private lazy var viewModel: PasswordRefreshingViewModelType = PasswordRefreshingViewModel()
    private lazy var disposeBag = DisposeBag()

    //MARK: Public variables

    override func viewDidLoad() {
        super.viewDidLoad()
        //bindViewModel have to called before setupActions
        bindViewModel()
        setupActions()
    }


    //MARK: Bind Output data from viewModel
    func bindViewModel() {
        //Bind viewModel's outputs here

        viewModel.enableSendButtonObservable.bind(to: sendButton.rx.isEnabled).disposed(by: disposeBag)

        viewModel.errorStringObservable.bind { [unowned self] value in
            self.showMessage(title: "Error", message: value)
        }.disposed(by: disposeBag)

        viewModel.successStringObservalbe.bind { [unowned self] value in
            self.showMessage(title: "Success", message: value)
        }.disposed(by: disposeBag)

    }


    //MARK: Map UI's actions to Input of the viewModel
    func setupActions() {
        //Map UI's actions to viewModel's inputs here
        emailTextField.rx.text.orEmpty.skip(1)
            .throttle(0.2, scheduler: MainScheduler.asyncInstance)
            .bind(to: viewModel.emailStringChangedEvent)
            .disposed(by: disposeBag)

        sendButton.rx.tap.bind(to: viewModel.sendButtonTappedEvent).disposed(by: disposeBag)

        cancelButton.rx.tap.bind { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }


    //MARK: Helpful functions



}
