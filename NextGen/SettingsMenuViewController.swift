//
//  SettingsMenuViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 3/25/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class SettingsMenuViewController: MenuedViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist"), let sections = NSArray(contentsOfFile: path) {
            for section in sections {
                if let sectionInfo = section as? NSDictionary {
                    menuSections.append(MenuSection(info: sectionInfo))
                }
            }
        }
    }

}
