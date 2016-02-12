//
//  SettingsMenuViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class SettingsMenuViewController: UITableViewController{
   
   var settings = ["Menu","Audio Settings","Subtitles", "Commentary"]
    
   var subtitles = ["Subtitles","Off","English (CC)","English (United States)","Spanish (Latin America)", "French (Canada)","Portuguese (Brazil)"]
   var subtitlesShort = ["Off","Off","CC","EN(US)","SP","FR(CA)","PR(BR)"]
    
   var audioSettings = ["Audio Settings","English (US)", "English (US)(AC3)","Spanish (Latin America)", "French (Canada)"]
    
    var audioSettingsShort = ["English","English", "AC3","Spanish", "French"]
    var commentary = ["Commentary","Director Commentary", "Actor Commentary"]
    var commentaryShort = ["Off","Director", "Actor"]
    
    

   var showAudioList: Bool = false
   var showSubtitlesList: Bool = false
   var showCommentaryList: Bool = false
   var selectedAudioIndex: Int = 0
   var selectedSubIndex: Int = 0
   var selectedCommIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "MOSMenu"))
       


        selectedAudioIndex = 0
        selectedSubIndex = 0
        selectedCommIndex = 0
    

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

        } else if (section == 3) {
            
            if (!showCommentaryList) {
                return 1
            }
            else{
                return commentary.count
            }
            
        }else {

            
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
        } else {
            
            return 60.0
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsItem") as! SettingsCell
        
        
            cell.cellSetting.text = settings[indexPath.section]
            
      
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
        
        else if (indexPath.section == 3){
            cell.currentSetting.hidden = false
            if (!showCommentaryList){
                
                    cell.currentSetting.text = commentaryShort[selectedCommIndex]
                
            } else {
                
                if(indexPath.row == 0){
                    
                   cell.radioBtn.hidden = true

                    
                } else {
                    cell.radioBtn.hidden = false
                
            
            }
                    cell.cellSetting.text = commentary[indexPath.row]
                    cell.currentSetting.hidden = true
                    
               

            }

        }
        
        return cell
        
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    


        if (indexPath.section == 1){
            
            if (showAudioList){
                selectedAudioIndex = indexPath.row
            }
            
            showAudioList = !showAudioList
            
 
        } else if (indexPath.section == 2){
            
            if (showSubtitlesList){
                selectedSubIndex = indexPath.row
            }
            
            showSubtitlesList = !showSubtitlesList
            


        } else if (indexPath.section == 3){
            
            if (showCommentaryList){
                selectedCommIndex = indexPath.row
            }
            
            showCommentaryList = !showCommentaryList
        
        }
    
        self.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
        
    }
    
    

    
  
}
