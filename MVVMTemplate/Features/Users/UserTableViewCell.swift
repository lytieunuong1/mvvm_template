//
//  UserTableViewCell.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/8/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import UIKit
import RxSwift

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!

    private var disposeBag = DisposeBag()

    //Use a trigger that when the viewModel change we will register observers to show data into view
    var viewModel: UserCellViewModel? {
        didSet {
            bindViewModel()
        }
    }


    override func prepareForReuse() {
        super.prepareForReuse()
        //You have to re-create a new DisposeBag to clear the old observers
        disposeBag = DisposeBag()
    }


    //MARK: Helpful functions
    func bindViewModel() {

        viewModel?.jobString.bind(to: jobLabel.rx.text).disposed(by: disposeBag)

        viewModel?.nameString.bind(to: nameLabel.rx.text).disposed(by: disposeBag)
    }

}
