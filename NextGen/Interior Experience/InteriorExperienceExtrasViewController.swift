//
//  InteriorExperienceViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

class InteriorExperienceExtrasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
    
    struct SegueIdentifier {
        static let ShowTalent = "ShowTalentSegueIdentifier"
    }
    
    @IBOutlet weak var talentTableView: TalentTableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    private var _didChangeTimeObserver: NSObjectProtocol!
    private var _currentTime = -1.0
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(_didChangeTimeObserver)
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        talentTableView.registerNib(UINib(nibName: "TalentTableViewCell-Narrow", bundle: nil), forCellReuseIdentifier: "TalentTableViewCell")
        
        _didChangeTimeObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidChangeTime, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, time = userInfo["time"] as? Double {
                strongSelf._currentTime = time
            }
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NextGenDataManager.sharedInstance.mainExperience.orderedActors.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCell.ReuseIdentifier) as! TalentTableViewCell
        let talent = NextGenDataManager.sharedInstance.mainExperience.orderedActors[indexPath.row]
        cell.talent = talent
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String.localize("label.actors").uppercaseString
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = NSTextAlignment.Center
        header.textLabel?.font = UIFont(name: "Roboto Condensed", size: 18)
        header.textLabel?.textColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TalentTableViewCell, talent = cell.talent {
            self.performSegueWithIdentifier(SegueIdentifier.ShowTalent, sender: talent)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Storyboard Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.ShowTalent {
            let talentDetailViewController = segue.destinationViewController as! TalentDetailViewController
            talentDetailViewController.talent = sender as! Talent
            talentDetailViewController.mode = TalentDetailMode.Synced
        }
    }

}
