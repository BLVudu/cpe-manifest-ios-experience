//
//  InitialViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 2/4/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import SWRevealViewController

class InitialViewController: SWRevealViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rearViewController = MenuTableViewController(plistName: "Settings")
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }

}
