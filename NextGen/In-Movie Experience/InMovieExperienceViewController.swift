//
//  InMovieExperienceViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 1/12/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

class InMovieExperienceViewController: UIViewController {
    
    struct SegueIdentifier {
        static let PlayerViewController = "PlayerViewControllerSegue"
    }
    
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var extrasContainerView: UIView!
    @IBOutlet var playerToExtrasConstarint: NSLayoutConstraint!
    @IBOutlet var playerToSuperviewConstraint: NSLayoutConstraint!
    
    private var _didPlayMainExperienceObserver: NSObjectProtocol!
    private var _isShowingInterstitial = true
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(_didPlayMainExperienceObserver)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _didPlayMainExperienceObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidPlayMainExperience, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) in
            if let strongSelf = self {
                strongSelf._isShowingInterstitial = false
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        extrasContainerView.hidden = UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
        updatePlayerConstraints()
    }
    
    func updatePlayerConstraints() {
        playerToExtrasConstarint.active = !extrasContainerView.hidden
        playerToSuperviewConstraint.active = !playerToExtrasConstarint.active
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        extrasContainerView.hidden = UIInterfaceOrientationIsLandscape(toInterfaceOrientation)
        updatePlayerConstraints()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.PlayerViewController {
            let playerViewController = segue.destinationViewController as! VideoPlayerViewController
            playerViewController.mode = VideoPlayerMode.MainFeature
        }
    }

}