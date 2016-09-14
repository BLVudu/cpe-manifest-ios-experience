//
//  NSURL+Utils.swift
//

import UIKit

extension URL {
    
    func promptLaunchBrowser() {
        let alertController = UIAlertController(title: String.localize("info.leaving_app.title"), message: String.localize("info.leaving_app.message"), preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: String.localize("label.no"), style: UIAlertActionStyle.cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: String.localize("label.yes"), style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            UIApplication.shared.openURL(self)
        }))
        
        alertController.show()
    }
    
}
