//
//  InteriorExperienceViewController.swift
//  NextGen
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
    
    var allowPortraitOrientation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(kVideoPlayerIsPlayingPrimaryVideo, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (_) -> Void in
            if let strongSelf = self {
                strongSelf.allowPortraitOrientation = true
            }
        }
        
        extrasContainerView.hidden = UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
        updatePlayerConstraints()
    }
    
    func updatePlayerConstraints() {
        playerToExtrasConstarint.active = !extrasContainerView.hidden
        playerToSuperviewConstraint.active = !playerToExtrasConstarint.active
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return (allowPortraitOrientation ? UIInterfaceOrientationMask.All : UIInterfaceOrientationMask.Landscape)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        extrasContainerView.hidden = UIInterfaceOrientationIsLandscape(toInterfaceOrientation)
        updatePlayerConstraints()
    }

}