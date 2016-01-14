//
//  UIAlertController+Utils.swift
//  NextGen
//
//  Created by Alec Ananian on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    func show() {
        show(true)
    }
    
    func show(animated: Bool) {
        let alertWidow = UIWindow(frame: UIScreen.mainScreen().bounds)
        alertWidow.rootViewController = UIViewController()
        alertWidow.windowLevel = UIWindowLevelAlert + 1;
        alertWidow.makeKeyAndVisible()
        alertWidow.rootViewController?.presentViewController(self, animated: animated, completion: nil)
    }
    
}
