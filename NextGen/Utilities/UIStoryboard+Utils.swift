//
//  UIStoryboard+Utils.swift
//  NextGen
//
//  Created by Alec Ananian on 3/29/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static func getNextGenViewController(viewControllerClass: AnyClass) -> UIViewController {
        return UIStoryboard(name: "NextGen", bundle: nil).instantiateViewControllerWithIdentifier(String(viewControllerClass))
    }
    
}