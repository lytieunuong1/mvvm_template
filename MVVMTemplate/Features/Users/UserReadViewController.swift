//
//  UserReadViewController.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/8/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserReadViewController: UIViewController {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!

    //MARK: Private variables
    private let viewModel: UserReadViewModelType = UserReadViewModel()
    private let disposeBag = DisposeBag()

    //MARK: Public variables




    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
        setupActions()
    }



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadUserListEvent.onNext(())
    }



    //MARK: Bind Output data from viewModel
    func bindViewModel() {

        viewModel.selectedDeleteButtonObservable.bind{ [unowned self] value in
            self.deleteButton.isSelected = value
            self.userTableView.isEditing = value
        }.disposed(by: disposeBag)

        viewModel.userListObservable.bind(to: userTableView.rx.items(cellIdentifier: "cell", cellType: UserTableViewCell.self)) { index, item, cell in
            //set viewModel for cell => the same with show data to cell
            cell.viewModel = UserCellViewModel(user: item)
        }.disposed(by: disposeBag)

        //Listen user selected and move to update screen
        viewModel.userSelectedObservable.bind { [unowned self] (user) in
            //Get create view controller
            let vc = UIStoryboard.Main.userCreateViewController() as! UserCreateViewController
            vc.updatingUser = user
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)

        viewModel.logoutSuccessObservable.bind {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = UIStoryboard.Main.loginViewController()
        }.disposed(by: disposeBag)
    }



    //MARK: Map UI's actions to Input of the viewModel
    func setupActions() {

        deleteButton.rx.tap.bind(to: viewModel.deleteButtonTappedEvent).disposed(by: disposeBag)

        //call viewModel when the user selected cell in table view
        userTableView.rx.modelSelected(User.self).bind(to: viewModel.userSelectedEvent).disposed(by: disposeBag)

        //call viewModel when the user deleted cell in table view
        userTableView.rx.itemDeleted.bind(to: viewModel.deletedUserEvent).disposed(by: disposeBag)

        logoutButton.rx.tap.bind(to: viewModel.logoutButtonTappedEvent).disposed(by: disposeBag)

    }



    //MARK: Helpful functions

}
