//
//  ViewController.swift
//  NextGenPOC-Native
//
//  Created by Sedinam Gadzekpo on 1/7/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var slideOutMenu: UITableView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var extView: UIView!
    @IBOutlet weak var playMovie: UIButton!
    @IBOutlet weak var extras: UIButton!
    @IBOutlet weak var instructionsImageView: UIImageView!
    @IBOutlet var LtoR: UISwipeGestureRecognizer!
    @IBOutlet var RtoL: UISwipeGestureRecognizer!
    
    @IBOutlet var titleTreatmentTopConstraint: NSLayoutConstraint!
    @IBOutlet var titleTreatmentLeftConstraint: NSLayoutConstraint!
    @IBOutlet var instructionsRightConstraint: NSLayoutConstraint!
    @IBOutlet var instructionsBottomConstraint: NSLayoutConstraint!
    
    let navImages = ["nav_extras.jpg","nav_home.jpg","nav_scenes.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.LtoR.direction = UISwipeGestureRecognizerDirection.Right
        self.RtoL.direction = UISwipeGestureRecognizerDirection.Left
        
        self.slideOutMenu.hidden = true
        self.slideOutMenu.delegate = self
        self.slideOutMenu.registerClass(UITableViewCell.self, forCellReuseIdentifier: "menuItem")
        self.slideOutMenu.backgroundColor = UIColor(patternImage: UIImage(named: "menu_bg.jpg")!)
    }
    
    override func viewWillAppear(animated: Bool) {
        extView.hidden = UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
        instructionsImageView.hidden = !extView.hidden
        startInstructionsRotation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let screenSize = UIScreen.mainScreen().bounds
        let viewHeight = (extView.hidden ? screenSize.height : (screenSize.height / 2))
        titleTreatmentTopConstraint.constant = viewHeight * 0.4125
        titleTreatmentLeftConstraint.constant = screenSize.width * 0.2
        instructionsBottomConstraint.constant = viewHeight * 0.1
        instructionsRightConstraint.constant = screenSize.width * 0.1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
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
    
    @IBAction func slideMenu(recognizer: UISwipeGestureRecognizer) {
        /*if(recognizer.direction == UISwipeGestureRecognizerDirection.Right){
            
            self.slideOutMenu.hidden = false
        } else if (recognizer.direction == UISwipeGestureRecognizerDirection.Left) {
            self.slideOutMenu.hidden = true
        }*/
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        extView.hidden = UIInterfaceOrientationIsLandscape(toInterfaceOrientation)
        instructionsImageView.hidden = !extView.hidden
        startInstructionsRotation()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.navImages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("menuItem", forIndexPath: indexPath) as UITableViewCell
        let row = indexPath.row
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "menu_bg.jpg")!)
        cell.imageView?.image = UIImage (named: navImages[row])
        
        
        return cell
    }
    
}

