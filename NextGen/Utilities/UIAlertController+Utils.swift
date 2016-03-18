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
        var topViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        while topViewController!.presentedViewController != nil {
            topViewController = topViewController!.presentedViewController
        }
        
        topViewController?.presentViewController(self, animated: animated, completion: nil)
    }
    
}
