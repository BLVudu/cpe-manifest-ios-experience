//
//  ShoppingViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/16/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import DropDown


var decriptions: NSMutableArray!
var visibleRowsPerSection = [[Int]]()
class ShoppingViewController: StylizedViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
   
    @IBOutlet weak var shoppingView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    override func viewWillAppear(animated: Bool) {
        
        super.viewDidLoad()
        
        
        loadCellDescriptors()
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "shopping")
        self.shoppingView.registerNib(UINib(nibName: "ShoppingCell", bundle: nil), forCellWithReuseIdentifier: "shop")
        self.tableView.tableFooterView = UIView()
        
        if let layout = shoppingView?.collectionViewLayout as? ExtrasLayout {
            layout.delegate = self
        }
        
 

        
       
     
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if decriptions != nil {
            return decriptions.count
        }
        else {
            return 0
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleRowsPerSection[section].count
    }
    
    func loadCellDescriptors() {
        if let path = NSBundle.mainBundle().pathForResource("Shopping", ofType: "plist") {
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
    
    func getCellDescriptorForIndexPath(indexPath: NSIndexPath) -> [String: AnyObject] {
        /*let indexOfVisibleRow = visibleRowsPerSection[indexPath.section][indexPath.row]
        let cellDescriptor = decriptions[indexPath.section][indexOfVisibleRow] as! [String: AnyObject]
        return cellDescriptor*/
        return [String: AnyObject]()
    }
    
    /*
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0){
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 100))
        
        let title = UILabel(frame: CGRectMake(10, 10, tableView.frame.size.width, 40))
        title.text = "Shopping"
        title.textColor = UIColor.whiteColor()
        title.font = UIFont(name: "Helvetica", size: 25.0)
        headerView.addSubview(title)
        
        return headerView
        }
        
        else {
            let headerView = UIView(frame: CGRectMake(0, 0, 0, 0))
            return headerView
        }
    }

    */
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier("shopping", forIndexPath: indexPath) as UITableViewCell
        let title = currentCellDescriptor["primaryTitle"] as! String
        cell.textLabel?.text = title
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
            return 10
            }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("shop", forIndexPath: indexPath)as! UICollectionViewCell
        
        return cell
          }
    
    
    
}

extension ShoppingViewController: ExtrasLayoutDelegate{
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath,
        withWidth width: CGFloat) -> CGFloat {
            
            
            return collectionView.frame.height/2.8
    }
    
    func collectionView(collectionView: UICollectionView,
        heightForLabelAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
    {
        return 100.0
    }
    
}

