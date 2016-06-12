//
//  InMovieExperienceViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import NextGenDataManager

class InMovieExperienceExtrasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
    
    struct SegueIdentifier {
        static let ShowTalent = "ShowTalentSegueIdentifier"
    }
    
    @IBOutlet weak var talentTableView: UITableView?
    @IBOutlet weak var backgroundImageView: UIImageView!
    var appApperance: NGDMAppearance!
    
    private var _didChangeTimeObserver: NSObjectProtocol!
    
    private var _currentTime: Double = -1
    private var _currentExperienceCellData = [ExperienceCellData]()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(_didChangeTimeObserver)
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let backgroundImageURL = CurrentManifest.inMovieExperience.appearance?.backgroundImageURL {
            backgroundImageView.setImageWithURL(backgroundImageURL)
        }
        
        if let actors = CurrentManifest.mainExperience.orderedActors where actors.count > 0 {
            talentTableView?.registerNib(UINib(nibName: "TalentTableViewCell-Narrow", bundle: nil), forCellReuseIdentifier: "TalentTableViewCell")
        } else {
            talentTableView?.removeFromSuperview()
            talentTableView = nil
        }
        
        _didChangeTimeObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidChangeTime, object: nil, queue: nil) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, time = userInfo["time"] as? Double {
                if time != strongSelf._currentTime {
                    strongSelf.processExperiencesForTime(time)
                }
            }
        }
    }
    
    func currentCellDataForExperience(experience: NGDMExperience) -> ExperienceCellData? {
        for cellData in _currentExperienceCellData {
            if cellData.experience == experience {
                return cellData
            }
        }
        
        return nil
    }
    
    func processExperiencesForTime(time: Double) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            self._currentTime = time
            
            if let allExperiences = CurrentManifest.inMovieExperience.childTalentDataExperience?.childExperiences {
                var hasNewData = false
                var newExperienceCellData = [ExperienceCellData]()
                
                for i in 0 ..< allExperiences.count {
                    let experience = allExperiences[i]
                    let timedEvent = experience.timedEventSequence?.timedEvent(self._currentTime)
                    let oldCellData = self.currentCellDataForExperience(experience)
                    
                    if let newTimedEvent = timedEvent {
                        newExperienceCellData.append(ExperienceCellData(experience: experience, timedEvent: newTimedEvent))
                        hasNewData = hasNewData || oldCellData == nil || oldCellData!.timedEvent != newTimedEvent
                    } else if oldCellData != nil {
                        hasNewData = true
                    }
                }
                
                if hasNewData {
                    dispatch_async(dispatch_get_main_queue()) {
                        self._currentExperienceCellData = newExperienceCellData
                        self.talentTableView?.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _currentExperienceCellData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCell.ReuseIdentifier) as! TalentTableViewCell
        if _currentExperienceCellData.count > indexPath.row {
            let experienceCellData = _currentExperienceCellData[indexPath.row]
            cell.talent = experienceCellData.timedEvent.talent
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String.localize("label.actors").uppercaseString
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = NSTextAlignment.Center
        header.textLabel?.font = UIFont.themeCondensedFont(19)
        header.textLabel?.textColor = UIColor(netHex: 0xe5e5e5)
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
            talentDetailViewController.title = String.localize("talentdetail.title")
            talentDetailViewController.talent = sender as! Talent
            talentDetailViewController.mode = TalentDetailMode.Synced
        }
    }

}
