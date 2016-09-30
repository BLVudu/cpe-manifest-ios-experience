//
//  UIStoryboard+Utils.swift
//

import UIKit

extension UIStoryboard {
    
    static func getNextGenViewController(_ viewControllerClass: AnyClass) -> UIViewController {
        return UIStoryboard(name: (DeviceType.IS_IPAD ? "NextGen" : "NextGen_iPhone"), bundle: nil).instantiateViewController(withIdentifier: String(describing: viewControllerClass))
    }
    
}
