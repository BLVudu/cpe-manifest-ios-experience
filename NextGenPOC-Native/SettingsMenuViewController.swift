//
//  SettingsMenuViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import DLRadioButton


class SettingsMenuViewController: UITableViewController{
   
   var settings = ["Menu","Audio Settings","Subtitles"]
    
   var subtitles = ["Subtitles","Off","English (CC)","English (United States)","Spanish (Latin America)", "French (Canada)","Portuguese (Brazil)"]
   var subtitlesShort = ["Off","Off","CC","EN(US)","SP","FR(CA)","PR(BR)"]
    
   var audioSettings = ["Audio Settings","English (US)", "English (US)(AC3)","Spanish (Latin America)", "French (Canada)"]
    
    var audioSettingsShort = ["English","English", "AC3","Spanish", "French"]
    var commentary = ["Commentary","Off","Director Commentary", "Actor Commentary"]
    var commentaryShort = ["Off","Off","Director", "Actor"]
    
    var subtitiles = ["","Turn commentary off","Hear from the director in his own words about the decisions he made","Henry Cavill walks through his approach in various scenes as the Man of Steel"]

    
    

   var showAudioList: Bool = false
   var showSubtitlesList: Bool = false
   var showCommentaryList: Bool = false
   var selectedAudioIndex: Int = 0
   var selectedSubIndex: Int = 0

    
    var currentSettings = [SettingsCell]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "MOSMenu"))
       


        selectedAudioIndex = 0
        selectedSubIndex = 0

    

    }
    
     

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 1) {
            
            if (!showAudioList) {
                return 1
            }
            else{

                return audioSettings.count
                
                
            }
        }else if (section == 2) {
            
            if (!showSubtitlesList) {
                return 1
            }
            else{
                return subtitles.count
            }

        } else {

            
            return 1
        }
       
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
         return settings.count
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (indexPath.section == 0){
            
            return 100.0
        }else {
            return 60.0
        }
        
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsItem") as! SettingsCell
                cell.cellSetting.text = settings[indexPath.section]
            cell.subtitle.hidden = true
        if (indexPath.section == 1){
            cell.currentSetting.hidden = false
            
            
        if (!showAudioList){
            
           
           cell.currentSetting.text = audioSettingsShort[selectedAudioIndex]
            
        } else {
            
            if(indexPath.row == 0){
                
                cell.radioBtn.hidden = true
            
            } else {
                

                cell.radioBtn.hidden = false
            }
            
            cell.cellSetting.text = audioSettings[indexPath.row]
            cell.currentSetting.hidden = true
            }
            
        }
        
        else if (indexPath.section == 2){
            cell.currentSetting.hidden = false
        if (!showSubtitlesList){
            

            cell.currentSetting.text = subtitlesShort[selectedSubIndex]
            
        } else {
            
            if(indexPath.row == 0){
                
                cell.radioBtn.hidden = true
                
            } else {
               cell.radioBtn.hidden = false
            }
                cell.cellSetting.text = subtitles[indexPath.row]
                cell.currentSetting.hidden = true
            
           
            
        }
        }
        
        

        return cell
        
        
      
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SettingsCell

        if (indexPath.section == 1){
            
            if (indexPath.row == 0){
         
                showAudioList = !showAudioList

                //self.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
            
            } else {
                
                
                selectedAudioIndex = indexPath.row

                return
            }
            
 
        } else if (indexPath.section == 2){
            
            if (indexPath.row == 0){
            
            
            
            showSubtitlesList = !showSubtitlesList
                //self.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
                
            } else {
                
                selectedSubIndex = indexPath.row
                return
            }

            


        } 
    
        self.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
        
    }
    
    
    
    
}
