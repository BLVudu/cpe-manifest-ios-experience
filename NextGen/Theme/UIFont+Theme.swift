//
//  UIFont+Theme.swift
//

import UIKit

extension UIFont {
    
    static func themeFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto", size: size)!
    }
    
    static func themeCondensedFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoCondensed-Regular", size: size)!
    }
    
    static func themeCondensedBoldFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoCondensed-Bold", size: size)!
    }
    
}
