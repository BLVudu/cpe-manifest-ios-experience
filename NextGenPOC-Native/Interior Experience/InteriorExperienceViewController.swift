//
//  InteriorExperienceViewController.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit

let TalentTableViewCellIdentifier = "TalentTableViewCell"

class InteriorExperienceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var talentTableView: TalentTableView!
    @IBOutlet weak var talentDetailView: TalentDetailView!
    
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
        ],
        ["name": "Michael Shannon", "role": "General Zod"],
        ["name": "Diane Lane", "role": "Martha Kent"],
        ["name": "Russell Crowe", "role": "Jor-El"],
        ["name": "Antje Traue", "role": "Faora-Ul"],
        ["name": "Harry Lennix", "role": "General Swanwick"],
        ["name": "Richard Schiff", "role": "Dr. Emil Hamilton"],
        ["name": "Christopher Meloni", "role": "Colonel Nathan Hardy"],
        ["name": "Kevin Costner", "role": "Jonathan Kent"],
        ["name": "Ayelet Zurer", "role": "Lara Lor-Van"],
        ["name": "Laurence Fishburne", "role": "Perry White"]
    ]

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        talentTableView.dataSource = self
        talentTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talentData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCellIdentifier) as! TalentTableViewCell
        cell.talent = Talent(info: talentData[indexPath.row])
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
        talentDetailView.talent = (tableView.cellForRowAtIndexPath(indexPath) as! TalentTableViewCell).talent
        talentDetailView.hidden = false
    }

}
