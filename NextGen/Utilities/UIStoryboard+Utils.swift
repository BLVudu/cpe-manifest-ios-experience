//
//  UIStoryboard+Utils.swift
//

import UIKit

extension UIStoryboard {
    
    static func getNextGenViewController(viewControllerClass: AnyClass) -> UIViewController {
        return UIStoryboard(name: (DeviceType.IS_IPAD ? "NextGen" : "NextGen_iPhone"), bundle: nil).instantiateViewControllerWithIdentifier(String(viewControllerClass))
    }
    
}