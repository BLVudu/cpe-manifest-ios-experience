//
//  ExtrasShoppingViewController.swift
//

import UIKit

struct ShoppingMenuNotification {
    static let DidSelectCategory = "kShoppingMenuNotificationDidSelectCategory"
    static let ShouldCloseDetails = "kShoppingMenuNotificationShouldCloseDetails"
}

class ExtrasShoppingViewController: MenuedViewController {
    
    fileprivate var _didAutoSelectCategory = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuSections.append(MenuSection(info: [MenuSection.Keys.Title: String.localize("label.all"), MenuSection.Keys.Value: "-1"]))
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !_didAutoSelectCategory {
            let selectedPath = IndexPath(row: 0, section: 0)
            self.menuTableView.selectRow(at: selectedPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
            self.tableView(self.menuTableView, didSelectRowAt: selectedPath)
            if let menuSection = menuSections.first {
                if menuSection.expandable {
                    let selectedPath = IndexPath(row: 1, section: 0)
                    self.menuTableView.selectRow(at: selectedPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
                    self.tableView(self.menuTableView, didSelectRowAt: selectedPath)
                }
            }
            
            _didAutoSelectCategory = true
        }
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        var categoryId: String?
        if let menuSection = (tableView.cellForRow(at: indexPath) as? MenuSectionCell)?.menuSection , !menuSection.expandable {
            categoryId = menuSection.value
        } else {
            categoryId = (tableView.cellForRow(at: indexPath) as? MenuItemCell)?.menuItem?.value
        }
        
        if categoryId != nil {
            NotificationCenter.default.post(name: Notification.Name(rawValue: ShoppingMenuNotification.ShouldCloseDetails), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: ShoppingMenuNotification.DidSelectCategory), object: nil, userInfo: ["categoryId": categoryId!])
        }
    }

}
