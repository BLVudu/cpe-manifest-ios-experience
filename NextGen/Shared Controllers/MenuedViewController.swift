//
//  MenuedViewController.swift
//

import UIKit

class MenuedViewController: ExtrasExperienceViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak internal var menuTableView: UITableView!
    internal var menuSections = [MenuSection]()
    fileprivate var selectedSectionValue: String?
    fileprivate var selectedItemValue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        menuTableView.register(UINib(nibName: "MenuSectionCell", bundle: nil), forCellReuseIdentifier: MenuSectionCell.ReuseIdentifier)
        menuTableView.register(UINib(nibName: "MenuItemCell", bundle: nil), forCellReuseIdentifier: MenuItemCell.ReuseIdentifier)
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuSections[section].numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuSection = menuSections[(indexPath as NSIndexPath).section]
        
        if (indexPath as NSIndexPath).row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MenuSectionCell.ReuseIdentifier) as! MenuSectionCell
            cell.menuSection = menuSection
            cell.active = selectedSectionValue == cell.menuSection?.value
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemCell.ReuseIdentifier) as! MenuItemCell
        cell.menuItem = menuSection.items[(indexPath as NSIndexPath).row - 1]
        cell.active = selectedItemValue == cell.menuItem?.value
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0 {
            return 60.0
        }
        
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        
        let menuSection = menuSections[(indexPath as NSIndexPath).section]
        if (indexPath as NSIndexPath).row == 0 {
            menuSection.toggle()
            
            if let cell = tableView.cellForRow(at: indexPath) as? MenuSectionCell {
                cell.toggleDropDownIcon()
            }
            
            if !menuSection.expandable {
                selectedSectionValue = menuSection.value
                selectedItemValue = nil
            }
            
            CATransaction.begin()
            CATransaction.setCompletionBlock(updateActiveCells)
            tableView.reloadSections(IndexSet(integer: (indexPath as NSIndexPath).section), with: UITableViewRowAnimation.none)
            CATransaction.commit()
        } else {
            selectedItemValue = menuSection.items[(indexPath as NSIndexPath).row - 1].value
            selectedSectionValue = nil
            updateActiveCells()
        }
    }
    
}
