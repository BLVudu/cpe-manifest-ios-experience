//
//  ViewController.swift
//  NextGenPOC-Native
//
//  Created by Sedinam Gadzekpo on 1/7/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var slideOutMenu: UITableView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var extView: UIView!
    @IBOutlet weak var playMovie: UIButton!
    @IBOutlet weak var extras: UIButton!
    @IBOutlet var LtoR: UISwipeGestureRecognizer!
    @IBOutlet var RtoL: UISwipeGestureRecognizer!
    
    
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
        self.extView.hidden = UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    @IBAction func slideMenu(recognizer: UISwipeGestureRecognizer) {
        /*if(recognizer.direction == UISwipeGestureRecognizerDirection.Right){
            
            self.slideOutMenu.hidden = false
        } else if (recognizer.direction == UISwipeGestureRecognizerDirection.Left) {
            self.slideOutMenu.hidden = true
        }*/
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.extView.hidden = UIInterfaceOrientationIsLandscape(toInterfaceOrientation)
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

