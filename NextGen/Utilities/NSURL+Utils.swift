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
        let alertController = UIAlertController(title: String.localize("info.leaving_app.title"), message: String.localize("info.leaving_app.message"), preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: String.localize("label.no"), style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: String.localize("label.yes"), style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(self)
        }))
        
        alertController.show()
    }
    
}