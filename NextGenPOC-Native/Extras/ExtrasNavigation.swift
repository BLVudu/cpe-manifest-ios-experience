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
        //self.navigationBar.barTintColor = UIColor.clearColor()
        self.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationBar.tintColor = UIColor.whiteColor()
        let logo = UIImageView(image:UIImage(named: "home_logo.png"))
        let titleImg = UIImageView(image:UIImage(named: "nav_extras.jpg"))
        logo.frame = CGRectMake((self.navigationBar.frame.width/2), 0, 300, 43)
        titleImg.frame = CGRectMake((self.navigationBar.frame.width)+75, -15, 200, 55)

        self.navigationBar.addSubview(logo)
        self.navigationBar.addSubview(titleImg)
        

        


    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
   
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    
    
}

