//
//  MenuedViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 3/25/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class MenuedViewController: ExtrasExperienceViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuTableView: UITableView!
    var menuSections = [MenuSection]()
    var selectedItem: MenuItem?
    var showsSelectedMenuItem = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        menuTableView.registerNib(UINib(nibName: MenuSectionCell.NibName, bundle: nil), forCellReuseIdentifier: MenuSectionCell.ReuseIdentifier)
        menuTableView.registerNib(UINib(nibName: MenuItemCell.NibName, bundle: nil), forCellReuseIdentifier: MenuItemCell.ReuseIdentifier)
    }
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menuSections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuSections[section].numRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let menuSection = menuSections[indexPath.section]
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(MenuSectionCell.ReuseIdentifier) as! MenuSectionCell
            cell.menuSection = menuSection
            if showsSelectedMenuItem {
                cell.selectedItem = selectedItem
            } else {
                cell.secondaryLabel?.removeFromSuperview()
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(MenuItemCell.ReuseIdentifier) as! MenuItemCell
        cell.menuItem = menuSection.items[indexPath.row - 1]
        cell.selected = selectedItem != nil && selectedItem == cell.menuItem
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60.0
        }
        
        return 40.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menuSection = menuSections[indexPath.section]
        if indexPath.row == 0 {
            menuSection.toggle()
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuSectionCell {
                cell.toggleDropDownIcon()
            }
            
            tableView.beginUpdates()
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.None)
            tableView.endUpdates()
        } else {
            selectedItem = menuSection.items[indexPath.row - 1]
        }
    }
    
}
