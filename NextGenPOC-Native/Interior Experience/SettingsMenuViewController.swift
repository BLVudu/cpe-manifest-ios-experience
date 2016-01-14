//
//  SettingsMenuViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class SettingsMenuCell: UITableViewCell{
    
        @IBOutlet weak var setttingLabel: UILabel!
    
}

class SettingsMenuViewController: UITableViewController {
    
    var settingsLabel = ["Audio Settings", "Subtitles","User Profile"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.blackColor()

        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsItem") as! SettingsMenuCell
        cell.backgroundColor = UIColor.blackColor()
        cell.setttingLabel.text = self.settingsLabel[indexPath.row]
        
        return cell
        
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {


        let title = UILabel(frame: CGRectMake(26, 0, tableView.frame.width, 100))
        title.font = UIFont.boldSystemFontOfSize(30)
        //title.text = "Menu"
        title.textColor = UIColor.whiteColor()
        let header = UIView()
 
        header.addSubview(title)
        
        return header


    }
    
    
    
    

}
