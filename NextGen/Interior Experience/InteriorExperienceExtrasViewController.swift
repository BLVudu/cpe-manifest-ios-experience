//
//  InteriorExperienceViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

class InteriorExperienceExtrasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TalentDetailViewPresenter {
    
    @IBOutlet weak var talentTableView: TalentTableView!
    @IBOutlet weak var talentDetailView: UIView!
    @IBOutlet weak var sceneDetailView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    private var _didChangeTimeObserver: NSObjectProtocol!
    private var _selectedIndexPath: NSIndexPath?
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
                strongSelf.talentTableView.reloadData()
            }
        }
    }
    
    func talentDetailViewController() -> TalentDetailViewController? {
        for viewController in self.childViewControllers {
            if viewController is TalentDetailViewController {
                return viewController as? TalentDetailViewController
            }
        }
        
        return nil
    }
    
    func showTalentDetailView() {
        if talentDetailView.hidden {
            talentDetailView.alpha = 0
            talentDetailView.hidden = false
            
            UIView.animateWithDuration(0.25, animations: {
                self.talentDetailView.alpha = 1
                self.sceneDetailView.alpha = 0
                self.talentTableView.alpha = 0
            }, completion: { (Bool) -> Void in
                self.sceneDetailView.hidden = true
                self.talentTableView.hidden = true
            })
        }
    }
    
    func hideTalentDetailView() {
        if let indexPath = _selectedIndexPath {
            talentTableView.deselectRowAtIndexPath(indexPath, animated: true)
            _selectedIndexPath = nil
        }
        
        sceneDetailView.alpha = 0
        sceneDetailView.hidden = false
        talentTableView.alpha = 0
        talentTableView.hidden = false
        
        UIView.animateWithDuration(0.25, animations: {
            self.talentDetailView.alpha = 0
            self.sceneDetailView.alpha = 1
            self.talentTableView.alpha = 1
        }, completion: { (Bool) -> Void in
            self.talentDetailView.hidden = true
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if let sceneTalent = currentScene?.talent {
        //    return sceneTalent.count
        //}
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCell.ReuseIdentifier) as! TalentTableViewCell
        //if let sceneTalent = currentScene?.talent {
        //    cell.talent = sceneTalent[indexPath.row]
        //}
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ACTORS"
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath == _selectedIndexPath {
            hideTalentDetailView()
            return nil
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _selectedIndexPath = indexPath
        talentDetailViewController()?.talent = (tableView.cellForRowAtIndexPath(indexPath) as! TalentTableViewCell).talent
        showTalentDetailView()
    }
    
    // MARK: TalentDetailViewPresenter
    func talentDetailViewShouldClose() {
        hideTalentDetailView()
    }

}
