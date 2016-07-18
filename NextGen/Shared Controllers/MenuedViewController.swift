//
//  MenuedViewController.swift
//

import UIKit

class MenuedViewController: ExtrasExperienceViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak internal var menuTableView: UITableView!
    internal var menuSections = [MenuSection]()
    private var selectedSectionValue: String?
    private var selectedItemValue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        menuTableView.registerNib(UINib(nibName: String(MenuSectionCell), bundle: nil), forCellReuseIdentifier: MenuSectionCell.ReuseIdentifier)
        menuTableView.registerNib(UINib(nibName: String(MenuItemCell), bundle: nil), forCellReuseIdentifier: MenuItemCell.ReuseIdentifier)
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
            cell.active = selectedSectionValue == cell.menuSection?.value
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(MenuItemCell.ReuseIdentifier) as! MenuItemCell
        cell.menuItem = menuSection.items[indexPath.row - 1]
        cell.active = selectedItemValue == cell.menuItem?.value
        
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
        let updateActiveCells = { [weak self] in
            if let strongSelf = self {
                for cell in tableView.visibleCells {
                    if let menuSectionCell = cell as? MenuSectionCell {
                        menuSectionCell.active = strongSelf.selectedSectionValue == menuSectionCell.menuSection?.value
                    } else if let menuItemCell = cell as? MenuItemCell {
                        menuItemCell.active = strongSelf.selectedItemValue == menuItemCell.menuItem?.value
                    }
                }
            }
        }
        
        let menuSection = menuSections[indexPath.section]
        if indexPath.row == 0 {
            menuSection.toggle()
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuSectionCell {
                cell.toggleDropDownIcon()
            }
            
            if !menuSection.expandable {
                selectedSectionValue = menuSection.value
                selectedItemValue = nil
            }
            
            CATransaction.begin()
            CATransaction.setCompletionBlock(updateActiveCells)
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.None)
            CATransaction.commit()
        } else {
            selectedItemValue = menuSection.items[indexPath.row - 1].value
            selectedSectionValue = nil
            updateActiveCells()
        }
    }
    
}
