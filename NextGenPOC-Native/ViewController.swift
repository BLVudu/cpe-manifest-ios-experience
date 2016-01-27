//
//  ViewController.swift
//  NextGenPOC-Native
//
//  Created by Sedinam Gadzekpo on 1/7/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var backgroundContainerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var extView: UIView!
    
    @IBOutlet var backgroundContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var titleTreatmentTopConstraint: NSLayoutConstraint!
    @IBOutlet var titleTreatmentLeftConstraint: NSLayoutConstraint!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.revealViewController().rearViewRevealWidth = 300
        backgroundContainerView.sendSubviewToBack(backgroundImageView)
    }
    
    override func viewWillAppear(animated: Bool) {
        updateExtrasViewVisibility()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /*let screenSize = UIScreen.mainScreen().bounds
        let viewHeight = (extView.hidden ? screenSize.height : (screenSize.height / 2))
        titleTreatmentTopConstraint.constant = viewHeight * 0.4125
        titleTreatmentLeftConstraint.constant = screenSize.width * 0.2*/
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        updateExtrasViewVisibilityForInterfaceOrientation(toInterfaceOrientation)
    }
    
    func updateExtrasViewVisibility() {
        updateExtrasViewVisibilityForInterfaceOrientation(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    func updateExtrasViewVisibilityForInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation) {
        extView.hidden = UIInterfaceOrientationIsLandscape(interfaceOrientation)
        backgroundContainerBottomConstraint.active = !extView.hidden
    }
    
}

