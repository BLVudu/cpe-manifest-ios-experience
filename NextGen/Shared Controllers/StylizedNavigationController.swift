//
//  StylizedNavigationController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/15/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class StylizedNavigationController: UINavigationController {
    
    let fadeDuration = 0.25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.translucent = true
        self.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        if self.viewControllers.count > 1 {
            let transition = CATransition()
            transition.duration = fadeDuration
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            self.view.layer.addAnimation(transition, forKey: nil)
            return super.popViewControllerAnimated(false)
        }
        
        return super.popViewControllerAnimated(animated)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
}