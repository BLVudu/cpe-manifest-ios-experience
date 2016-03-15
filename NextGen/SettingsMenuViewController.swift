//
//  SettingsMenuViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit



class SettingsMenuViewController: UITableViewController{
   
     override func viewWillAppear(animated: Bool) {
        
        super.viewDidLoad()
        
        
        loadCellDescriptors()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "MOSMenu"))
       
         self.tableView.tableFooterView = UIView()
    

    }
    
    func loadCellDescriptors() {
        if let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist") {
            decriptions = NSMutableArray(contentsOfFile: path)
            getIndicesOfVisibleRows()
            self.tableView.reloadData()
    }
    }
    
    func getIndicesOfVisibleRows() {
        visibleRowsPerSection.removeAll()
        
        for currentSectionCells in decriptions {
            var visibleRows = [Int]()
            
            for row in 0...((currentSectionCells as! [[String: AnyObject]]).count - 1) {
                if currentSectionCells[row]["isVisible"] as! Bool == true {
                    visibleRows.append(row)
                }
            }
            
            visibleRowsPerSection.append(visibleRows)
        }
    }

    
    

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return visibleRowsPerSection[section].count
       
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if decriptions != nil {
            return decriptions.count
        }
        else {
            return 0
        }
    }
    
    func getCellDescriptorForIndexPath(indexPath: NSIndexPath) -> [String: AnyObject] {
        let indexOfVisibleRow = visibleRowsPerSection[indexPath.section][indexPath.row]
        let cellDescriptor = decriptions[indexPath.section][indexOfVisibleRow] as! [String: AnyObject]
        return cellDescriptor
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
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsItem") as! SettingsCell
        cell.cellSetting.text = currentCellDescriptor["primaryTitle"] as? String
        cell.cellSetting.textColor = UIColor.yellowColor()
        
        

        return cell
        
        
      
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexOfTappedRow = visibleRowsPerSection[indexPath.section][indexPath.row]
        
        if decriptions[indexPath.section][indexOfTappedRow]["isExpandable"] as! Bool == true {
            var shouldExpandAndShowSubRows = false
            if decriptions[indexPath.section][indexOfTappedRow]["isExpanded"] as! Bool == false {
                // In this case the cell should expand.
                shouldExpandAndShowSubRows = true
            }
            
            decriptions[indexPath.section][indexOfTappedRow].setValue(shouldExpandAndShowSubRows, forKey: "isExpanded")
            for i in (indexOfTappedRow + 1)...(indexOfTappedRow + (decriptions[indexPath.section][indexOfTappedRow]["additionalRows"] as! Int)) {
                decriptions[indexPath.section][i].setValue(shouldExpandAndShowSubRows, forKey: "isVisible")
            }
        }
        
        getIndicesOfVisibleRows()
        self.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
    
    }
    
}
