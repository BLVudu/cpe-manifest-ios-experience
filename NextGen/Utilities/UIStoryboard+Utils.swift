//
//  UIStoryboard+Utils.swift
//

import UIKit

extension UIStoryboard {
    
    static func getNextGenViewController(viewControllerClass: AnyClass) -> UIViewController {
        return UIStoryboard(name: "NextGen", bundle: nil).instantiateViewControllerWithIdentifier(String(viewControllerClass))
    }
    
}