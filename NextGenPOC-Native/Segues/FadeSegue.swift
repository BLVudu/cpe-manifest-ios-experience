//
//  FadeSegue.swift
//  
//
//  Created by Sedinam Gadzekpo on 1/22/16.
//
//

import UIKit

class FadeSegue: UIStoryboardSegue {
    
    let fadeDuration = 0.25
    
    override func perform() {
        if self.sourceViewController.navigationController != nil {
            UIView.transitionWithView(self.sourceViewController.navigationController!.view, duration: fadeDuration, options: .TransitionCrossDissolve, animations: {
                self.sourceViewController.navigationController!.pushViewController(self.destinationViewController as UIViewController, animated: false)
            }, completion: {(Finished) -> Void in
                
            })
        }
    }
    
}
