//
//  UIButton+Utils.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

extension UIButton {
    
    static func buttonWithImage(image: UIImage!) -> UIButton {
        let button = UIButton(type: .Custom)
        button.setImage(image, forState: .Normal)
        return button
    }
    
    static func homeButton() -> UIButton {
        let button = buttonWithImage(UIImage(named: "Home"))
        button.frame = CGRectMake(0, 0, 90, 44)
        button.setTitle("Home", forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)
        return button
    }
    
    static func backButton() -> UIButton {
        let button = buttonWithImage(UIImage(named: "Back Nav"))
        button.frame = CGRectMake(0, 0, 90, 44)
        button.setTitle("Back", forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)
        return button
    }
    
}