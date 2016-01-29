//
//  CustomSegue.swift
//  
//
//  Created by Sedinam Gadzekpo on 1/22/16.
//
//

import UIKit

class CustomSegue: UIStoryboardSegue {
    
    override func perform() {
        
        
        UIView.transitionWithView((self.sourceViewController.navigationController?.view)!, duration: 1, options: .TransitionCrossDissolve,
            animations:
            {
                self.sourceViewController.navigationController?.pushViewController(self.destinationViewController as UIViewController, animated: false)
            },completion: {(Finished) -> Void in
            
        })
    
    }
    
}
