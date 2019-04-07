//
//  UIStoryboardExtension.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 2/8/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import UIKit


//TODO: Rename this file to UIStoryboardExtension
protocol StoryboardScene: RawRepresentable {

    static var storyboardName : String { get }

}


extension StoryboardScene {

    static func storyboard() -> UIStoryboard {
        return UIStoryboard(name: self.storyboardName, bundle: nil)
    }

    func viewController() -> UIViewController {
        return Self.storyboard().instantiateViewController(withIdentifier: self.rawValue as! String)
    }
}



extension UIStoryboard {

    struct Main {

        private enum Identifier : String, StoryboardScene {
            static let storyboardName = "Main"
            case mainVC = "SIMain"
            case loginVC = "SILogin"
            case registerVC = "SIRegister"
            case userCreateVC = "SIUserCreate"
        }

        static func mainViewController() -> UIViewController {
            return Identifier.mainVC.viewController()
        }

        static func loginViewController() -> UIViewController {
            return Identifier.loginVC.viewController()
        }

        static func registerViewController() -> UIViewController {
            return Identifier.registerVC.viewController()
        }

        static func userCreateViewController() -> UIViewController {
            return Identifier.userCreateVC.viewController()
        }
    }

}
