//
//  NSURL+Utils.swift
//  NextGen
//
//  Created by Alec Ananian on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

extension NSURL {
    
    func promptLaunchBrowser() {
        let alertController = UIAlertController(title: "Leaving App", message: "Following this link will exit the app and launch your browser. Would you like to continue?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(self)
        }))
        
        alertController.show()
    }
    
}