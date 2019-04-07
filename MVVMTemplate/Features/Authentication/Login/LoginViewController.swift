//
//  LoginViewController.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/26/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import UIKit
import RxSwift



class LoginViewController: BaseViewController {
    //MARK: UI variables
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!

    //MARK: Private variables
    private let viewModel: LoginViewModelType = LoginViewModel()
    private var disposeBag = DisposeBag()

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
        self.viewModel.enableSignInButtonObservable.bind(to: signInButton.rx.isEnabled).disposed(by: disposeBag)

        self.viewModel.errorStringObservable.bind {[unowned self] value in
            self.showMessage(title: "Error", message: value)
        }.disposed(by: disposeBag)

        self.viewModel.loginSuccessObservalbe.bind {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = UIStoryboard.Main.mainViewController()
        }.disposed(by: disposeBag)

    }



    //MARK: Map UI's actions to Input of the viewModel
    func setupActions() {
        //Map UI's actions to viewModel's inputs here
        nameTextField.rx.text.orEmpty.skip(1).throttle(0.2, scheduler: MainScheduler.asyncInstance).distinctUntilChanged({$0 == $1}).bind(to: viewModel.nameStringChangedEvent).disposed(by: disposeBag)

        passwordTextField.rx.text.orEmpty.skip(1).throttle(0.2, scheduler: MainScheduler.asyncInstance).distinctUntilChanged({$0 == $1}).bind(to: viewModel.passwordStringChangedEvent).disposed(by: disposeBag)


        signInButton.rx.tap.bind(to: viewModel.signInButtonTappedEvent).disposed(by: disposeBag)

        registerButton.rx.tap.bind { [unowned self] in
            let registerVC = UIStoryboard.Main.registerViewController()
            self.present(registerVC, animated: true, completion: nil)
        }.disposed(by: disposeBag)

        facebookButton.rx.tap.bind(to: viewModel.facebookButtonTappedEvent).disposed(by: disposeBag)

        googleButton.rx.tap.bind(to: viewModel.googleButtonTappedEvent).disposed(by: disposeBag)
        
    }



     //MARK: Helpful functions
    


}
