//
//  InteriorExperienceViewController.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit

let TalentTableViewCellIdentifier = "TalentTableViewCell"

class InteriorExperienceExtrasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var talentTableView: TalentTableView!
    @IBOutlet weak var talentDetailView: UIView!
    @IBOutlet weak var sceneDetailView: UIView!
    
    var talentData = [
        [
            "thumbnailImage": "cavill_thumb.jpg",
            "fullImage": "cavill_full.jpg",
            "name": "Henry Cavill",
            "role": "Clark Kent/Kal-El"
        ],
        [
            "thumbnailImage": "adams.jpg",
            "fullImage": "adams.jpg",
            "name": "Amy Adams",
            "role": "Lois Lane"
        ]
    ]

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
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talentData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCellIdentifier) as! TalentTableViewCell
        cell.talent = Talent(info: talentData[indexPath.row])
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*talentDetailViewController()?.talent = (tableView.cellForRowAtIndexPath(indexPath) as! TalentTableViewCell).talent
        talentDetailView.hidden = false
        sceneDetailView.hidden = true*/
    }

}
