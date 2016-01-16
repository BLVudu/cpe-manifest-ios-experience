//
//  SettingsMenuViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class SettingsItemCell: UITableViewCell{
    
    
    @IBOutlet weak var switchItem: CustomSwitch!
    @IBOutlet weak var settingsLabel: UILabel!
}


class SettingsMenuViewController: UITableViewController{
    
    var settingsItems = ["Audio Settings", "Subtitles","User Profile"]
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       
        return 70.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsItem") as! SettingsItemCell
        cell.backgroundColor = UIColor.blackColor()
        cell.settingsLabel.text = self.settingsItems[indexPath.row]
        
        if (indexPath.row == 1){
            
            cell.switchItem.hidden = false
            
        } else {
            
            cell.switchItem.hidden = true
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UILabel(frame: CGRectMake(0,0,tableView.frame.width,80))
        
        view.backgroundColor = UIColor.blackColor()
        
        let header = UIView()
        header.addSubview(view)
        
        return header
    }
    
    
    
    
}
