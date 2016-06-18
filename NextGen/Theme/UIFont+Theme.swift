//
//  UIFont+Theme.swift
//

import UIKit

extension UIFont {
    
    static func themeFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto", size: size)!
    }
    
    static func themeCondensedFont(size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoCondensed-Regular", size: size)!
    }
    
    static func themeCondensedBoldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoCondensed-Bold", size: size)!
    }
    
}