//
//  UIStoryboard+Utils.swift
//  NextGen
//
//  Created by Alec Ananian on 3/29/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

extension UIStoryboard {
    
    static func getMainStoryboardViewController(viewControllerClass: AnyClass) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(String(viewControllerClass))
    }
    
}