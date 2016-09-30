//
//  UIAlertController+Utils.swift
//

import UIKit

extension UIAlertController {
    
    func show() {
        show(true)
    }
    
    func show(_ animated: Bool) {
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while topViewController!.presentedViewController != nil {
            topViewController = topViewController!.presentedViewController
        }
        
        topViewController?.present(self, animated: animated, completion: nil)
    }
    
}
