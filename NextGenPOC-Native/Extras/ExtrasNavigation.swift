//
//  ExtrasNavigation.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/15/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class ExtrasNavigation: UINavigationController{
    
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.alpha = 1
        let logo = UIImageView(image:UIImage(named: "home_logo.png"))
        //let titleImg = UIImageView(image:UIImage(named: "nav_extras.jpg"))
        logo.frame = CGRectMake((self.navigationBar.frame.width/2), 0, 300, 40)
        //titleImg.frame = CGRectMake((self.navigationBar.frame.width)+75, -15, 200, 55)

        self.navigationBar.addSubview(logo)
        //self.navigationBar.addSubview(titleImg)
        


    }
    
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        
        
        if ((self.viewControllers.last?.isKindOfClass(ExtrasViewController)) != nil){
                     
            let transition = CATransition()
            transition.duration = 1
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            self.view.layer.addAnimation(transition, forKey: nil)
            var vc:UIViewController = super.popViewControllerAnimated(false)!
            return vc;
        } else {
            return super.popViewControllerAnimated(true)
        }
            
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
   
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    
}

