//
//  UIFont+Theme.swift
//  NextGen
//
//  Created by Alec Ananian on 4/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

extension UIFont {
    
    static func themeFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto", size: size)!
    }
    
    static func themeCondensedFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto Condensed", size: size)!
    }
    
}