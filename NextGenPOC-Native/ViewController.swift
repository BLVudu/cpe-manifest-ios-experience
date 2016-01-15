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
    @IBOutlet weak var instructionsImageView: UIImageView!
    
    @IBOutlet var backgroundContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var titleTreatmentTopConstraint: NSLayoutConstraint!
    @IBOutlet var titleTreatmentLeftConstraint: NSLayoutConstraint!
    @IBOutlet var instructionsRightConstraint: NSLayoutConstraint!
    @IBOutlet var instructionsBottomConstraint: NSLayoutConstraint!
    
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
        
        let screenSize = UIScreen.mainScreen().bounds
        let viewHeight = (extView.hidden ? screenSize.height : (screenSize.height / 2))
        titleTreatmentTopConstraint.constant = viewHeight * 0.4125
        titleTreatmentLeftConstraint.constant = screenSize.width * 0.2
        instructionsBottomConstraint.constant = viewHeight * 0.05
        instructionsRightConstraint.constant = screenSize.width * 0.05
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
        instructionsImageView.hidden = !extView.hidden
        startInstructionsRotation()
    }
    
    // MARK: Animations
    func startInstructionsRotation() {
        if !instructionsImageView.hidden {
            rotateInstructionsToPortrait(false, animated: false)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.rotateInstructionsToPortrait(true, animated: true)
            }
        }
    }
    
    func rotateInstructionsToPortrait(toPortrait: Bool, animated: Bool) {
        if !instructionsImageView.hidden {
            let transformationRotation = CGAffineTransformMakeRotation(toPortrait ? 0 : CGFloat(-90 * M_PI) / 180)
            if animated {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.instructionsImageView.transform = transformationRotation
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(4 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                        self.rotateInstructionsToPortrait(!toPortrait, animated: true)
                    }
                }, completion: nil)
            } else {
                instructionsImageView.transform = transformationRotation
            }
        }
    }
    
}

