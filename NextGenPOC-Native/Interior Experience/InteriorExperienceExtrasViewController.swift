//
//  InteriorExperienceViewController.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

let TalentTableViewCellIdentifier = "TalentTableViewCell"

class InteriorExperienceExtrasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TalentDetailViewPresenter {
    
    @IBOutlet weak var talentTableView: TalentTableView!
    @IBOutlet weak var talentDetailView: UIView!
    @IBOutlet weak var sceneDetailView: UIView!
    
    var selectedIndexPath: NSIndexPath?

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        talentTableView.registerNib(UINib(nibName: "TalentTableViewCell", bundle: nil), forCellReuseIdentifier: "TalentTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func talentDetailViewController() -> TalentDetailViewController? {
        for viewController in self.childViewControllers {
            if viewController is TalentDetailViewController {
                return viewController as? TalentDetailViewController
            }
        }
        
        return nil
    }
    
    func sceneDetailViewController() -> SceneDetailViewController? {
        for viewController in self.childViewControllers {
            if viewController is SceneDetailViewController {
                return viewController as? SceneDetailViewController
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
            }, completion: { (Bool) -> Void in
                self.sceneDetailView.hidden = true
            })
        }
    }
    
    func hideTalentDetailView() {
        if selectedIndexPath != nil {
            talentTableView.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
            selectedIndexPath = nil
        }
        
        sceneDetailView.alpha = 0
        sceneDetailView.hidden = false
        
        UIView.animateWithDuration(0.25, animations: {
            self.talentDetailView.alpha = 0
            self.sceneDetailView.alpha = 1
            }, completion: { (Bool) -> Void in
                self.talentDetailView.hidden = true
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sceneTalent = DataManager.sharedInstance.content?.talentAtSceneTime(0) {
            return sceneTalent.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCellIdentifier) as! TalentTableViewCell
        if let sceneTalent = DataManager.sharedInstance.content?.talentAtSceneTime(0) {
            cell.talent = sceneTalent[indexPath.row]
        }
        
        cell.nameLabel?.removeFromSuperview()
        cell.roleLabel?.removeFromSuperview()
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
        if indexPath == selectedIndexPath {
            hideTalentDetailView()
            return nil
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        talentDetailViewController()?.talent = (tableView.cellForRowAtIndexPath(indexPath) as! TalentTableViewCell).talent
        showTalentDetailView()
    }
    
    // MARK: TalentDetailViewPresenter
    func talentDetailViewShouldClose() {
        hideTalentDetailView()
    }

}
