//
//  SettingsMenuViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class SettingsItemCell: UITableViewCell {
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var switchItem: CustomSwitch!
}


class SettingsMenuViewController: UITableViewController{
    
    var settingsItems = ["Audio Settings", "Subtitles", "User Profile"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "MOSMenu"))
    

    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
         cell.backgroundColor = UIColor.clearColor()
    }

    /*
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsItems.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsItem") as UITableViewCell!
        
        //cell.backgroundColor = UIColor.clearColor()
        //cell.settingsLabel.text = self.settingsItems[indexPath.row]
        //cell.switchItem.hidden = indexPath.row != 1
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SettingsItemCell
        
        if(indexPath.row == 2){
            
            self.performSegueWithIdentifier("profile", sender: nil)
        }

        
        if !cell.switchItem.hidden {
            cell.switchItem.setOn(!cell.switchItem.on, animated: true)
        }
        
           }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "profile"){
            let profileVC = segue.destinationViewController as! ExtrasNavigation
            
        }

        
    }
    */
}
