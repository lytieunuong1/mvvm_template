//
//  UIButtonExtension.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/28/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import UIKit



extension UIButton {

    open override var isEnabled: Bool{
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }

}
