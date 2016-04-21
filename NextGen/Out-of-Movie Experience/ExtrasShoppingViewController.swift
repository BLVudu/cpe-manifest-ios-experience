//
//  ExtrasShoppingViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 3/25/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

let kShoppingNotificationDidSelectCategory = "kShoppingNotificationDidSelectCategory"
let kShoppingNotificationCloseDetailsView = "kShoppingNotificationCloseDetailsView"

class ExtrasShoppingViewController: MenuedViewController {
    
    private var _didAutoSelectCategory = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showsSelectedMenuItem = false
        
        for category in TheTakeAPIUtil.sharedInstance.productCategories {
            let info = NSMutableDictionary()
            info[MenuSection.Keys.Title] = category.name
            info[MenuSection.Keys.Value] = String(category.id)
            
            if let children = category.children {
                if children.count > 1 {
                    var rows = [[MenuItem.Keys.Title: String.localize("label.all"), MenuItem.Keys.Value: String(category.id)]]
                    for child in children {
                        rows.append([MenuItem.Keys.Title: child.name, MenuItem.Keys.Value: String(child.id)])
                    }
                    
                    info[MenuSection.Keys.Rows] = rows
                }
            }
            
            menuSections.append(MenuSection(info: info))
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !_didAutoSelectCategory {
            let selectedPath = NSIndexPath(forRow: 0, inSection: 0)
            self.menuTableView.selectRowAtIndexPath(selectedPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
            self.tableView(self.menuTableView, didSelectRowAtIndexPath: selectedPath)
            if let menuSection = menuSections.first {
                if menuSection.expandable {
                    let selectedPath = NSIndexPath(forRow: 1, inSection: 0)
                    self.menuTableView.selectRowAtIndexPath(selectedPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
                    self.tableView(self.menuTableView, didSelectRowAtIndexPath: selectedPath)
                }
            }
            
            _didAutoSelectCategory = true
        }
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuItemCell, menuItem = cell.menuItem, categoryId = menuItem.value {
            NSNotificationCenter.defaultCenter().postNotificationName(kShoppingNotificationCloseDetailsView, object: nil, userInfo: nil)
            NSNotificationCenter.defaultCenter().postNotificationName(kShoppingNotificationDidSelectCategory, object: nil, userInfo: ["categoryId": categoryId])
        }
    }

}
