//
//  InteriorExperienceViewController.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/12/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit

class InteriorExperienceViewController: UIViewController {
    
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var extrasContainerView: UIView!
    @IBOutlet var playerToExtrasConstarint: NSLayoutConstraint!
    @IBOutlet var playerToSuperviewConstraint: NSLayoutConstraint!

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        extrasContainerView.hidden = UIInterfaceOrientationIsLandscape(toInterfaceOrientation)
        playerToExtrasConstarint.active = !extrasContainerView.hidden
        playerToSuperviewConstraint.active = !playerToExtrasConstarint.active
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PlayerViewControllerSegue" {
            let playerViewController = segue.destinationViewController as! VideoPlayerViewController
            playerViewController.video = Video(info: ["title": "Big Buck Bunny", "deliveryFormat": "HD", "url": "http://pdl.warnerbros.com/digitalcopy2/s/bbb/big_buck_bunny_480p_h264.mov"])
        }
    }

}