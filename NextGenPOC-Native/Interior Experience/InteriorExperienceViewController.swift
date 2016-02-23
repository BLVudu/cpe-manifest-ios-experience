//
//  InteriorExperienceViewController.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/12/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

class InteriorExperienceViewController: UIViewController {
    
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var extrasContainerView: UIView!
    @IBOutlet var playerToExtrasConstarint: NSLayoutConstraint!
    @IBOutlet var playerToSuperviewConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        /*
        if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) == true{
                extrasContainerView.hidden = true
        } else {
            extrasContainerView.hidden = false
            
        }
*/
        extrasContainerView.hidden = UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
        updatePlayerConstraints()
    }
    
    
    func updatePlayerConstraints() {
        playerToExtrasConstarint.active = !extrasContainerView.hidden
        playerToSuperviewConstraint.active = !playerToExtrasConstarint.active
    }

    /*
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        extrasContainerView.hidden = UIInterfaceOrientationIsLandscape(toInterfaceOrientation)
        updatePlayerConstraints()
    }
   */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PlayerViewControllerSegue" {
            let playerViewController = segue.destinationViewController as! VideoPlayerViewController
            playerViewController.video = DataManager.sharedInstance.content?.video
        }
    }

}