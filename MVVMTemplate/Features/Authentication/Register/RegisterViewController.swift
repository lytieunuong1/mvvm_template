//
//  RegisterViewController.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/26/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import UIKit
import RxSwift

class RegisterViewController: BaseViewController {
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!


    private lazy var viewModel: RegisterViewModelType = RegisterViewModel()
    private lazy var disposeBag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindViewModel()
        setupActions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    private func bindViewModel() {

        viewModel.enableRegisterButtonObservable.bind(to: registerButton.rx.isEnabled).disposed(by: disposeBag)

        viewModel.errorStringObservable.bind {[unowned self] value in
            self.showMessage(title: "Error", message: value)
        }.disposed(by: disposeBag)

        viewModel.successStringObservable.bind {[unowned self] value in
            self.showMessage(title: "Success", message: value)
        }.disposed(by: disposeBag)

        
    }

    private func setupActions() {

        fullNameTextField.rx.text.throttle(0.2, scheduler: MainScheduler.instance).bind {[unowned self] (value) in
            self.viewModel.fullNameStringChangedEvent.onNext(value ?? "")
        }.disposed(by: disposeBag)

        userNameTextField.rx.text.throttle(0.2, scheduler: MainScheduler.instance).bind {[unowned self] (value) in
            self.viewModel.userNameStringChangedEvent.onNext(value ?? "")
        }.disposed(by: disposeBag)

        passwordTextField.rx.text.throttle(0.2, scheduler: MainScheduler.instance).bind {[unowned self] (value) in
            self.viewModel.passwordStringChangedEvent.onNext(value ?? "")
        }.disposed(by: disposeBag)

        repasswordTextField.rx.text.throttle(0.2, scheduler: MainScheduler.instance).bind {[unowned self] (value) in
            self.viewModel.repasswordStringChangedEvent.onNext(value ?? "")
        }.disposed(by: disposeBag)

        registerButton.rx.tap.bind {[unowned self] in
            self.viewModel.registerButtonTappedEvent.onNext(())
        }.disposed(by: disposeBag)

        cancelButton.rx.tap.bind { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)

    }

}
