//
//  StylizedViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class StylizedViewController: UIViewController {
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.addTitleStyling()
        
        let backgroundImageView = UIImageView(image: UIImage(named: "extras_bg.jpg"))
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImageView.frame = self.view.bounds
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
    }

}
