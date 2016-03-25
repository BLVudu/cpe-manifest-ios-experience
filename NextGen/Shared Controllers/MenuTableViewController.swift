//
//  MenuTableViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    var menuSections = [MenuSection]()
    
    convenience init(plistName: String) {
        self.init(style: UITableViewStyle.Plain)
        
        if let path = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist"), let sections = NSArray(contentsOfFile: path) {
            for section in sections {
                if let sectionInfo = section as? NSDictionary {
                    menuSections.append(MenuSection(info: sectionInfo))
                }
            }
        }
    }
    
    convenience init(sections: [NSDictionary]) {
        self.init(style: UITableViewStyle.Plain)
        
        for section in sections {
            menuSections.append(MenuSection(info: section))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "MOSMenu"))
        self.tableView.registerNib(UINib(nibName: MenuSectionCell.NibName, bundle: nil), forCellReuseIdentifier: MenuSectionCell.ReuseIdentifier)
        self.tableView.registerNib(UINib(nibName: MenuItemCell.NibName, bundle: nil), forCellReuseIdentifier: MenuItemCell.ReuseIdentifier)
    }
    
    // MARK: UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menuSections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuSections[section].numRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(MenuSectionCell.ReuseIdentifier) as! MenuSectionCell
            cell.menuSection = menuSections[indexPath.section]
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(MenuItemCell.ReuseIdentifier) as! MenuItemCell
        cell.menuItem = menuSections[indexPath.section].items[indexPath.row - 1]
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menuSection = menuSections[indexPath.section]
        if indexPath.row == 0 {
            menuSection.toggle()
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuSectionCell {
                cell.toggleDropDownIcon()
            }
        } else {
            let menuItem = menuSection.items[indexPath.row - 1]
            menuSection.selectedItem = menuItem
        }
        
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
}
