//
//  LandscapeNavigationController.swift
//  NextGen
//
//  Created by Alec Ananian on 6/1/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class LandscapeNavigationController: UINavigationController {
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }

}
