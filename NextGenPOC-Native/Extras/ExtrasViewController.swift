//
//  ExtrasViewController.swift
//  NextGenPOC-Native
//
//  Created by Sedinam Gadzekpo on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//


import UIKit
import AVFoundation



class ExtrasViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, TalentDetailViewPresenter {
    
    @IBOutlet weak var talentTableView: TalentTableView!
    @IBOutlet weak var talentDetailView: UIView!
    @IBOutlet var extrasCollectionView: UICollectionView!
    @IBOutlet var extrasContentView: UIView!
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var selectedIndexPath: NSIndexPath?
    
    let extraImages = ["extras_bts.jpg","extras_galleries.jpg","extras_krypton.jpg","extras_legacy.jpg","extras_places.jpg","extras_scenes.jpg","extras_shopping.jpg","extras_universe.jpg"]
    let extrasCaption =  ["Behind The Scenes","Galleries","Explore Krypton","Legacy","Places","Deleted Scenes","Shopping", "DC Universe"]
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.talentTableView.registerNib(UINib(nibName: "TalentTableViewCell-Wide", bundle: nil), forCellReuseIdentifier: "TalentTableViewCell")
        self.extrasCollectionView.registerNib(UINib(nibName: "ContentCell", bundle: nil), forCellWithReuseIdentifier: "content")
        
        if let layout = extrasCollectionView?.collectionViewLayout as? ExtrasLayout {
            layout.delegate = self
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    
    // MARK: Actions
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func back(sender: AnyObject) {
        hideTalentDetailView()
        hideExtrasContentView()
    }
    
    
    // MARK: Talent Details
    func talentDetailViewController() -> TalentDetailViewController? {
        for viewController in self.childViewControllers {
            if viewController is TalentDetailViewController {
                return viewController as? TalentDetailViewController
            }
        }
        
        return nil
    }
    
    func showTalentDetailView() {
        if talentDetailView.hidden {
            talentDetailView.alpha = 0
            talentDetailView.hidden = false
            homeButton.hidden = true
            backButton.hidden = false
            
            UIView.animateWithDuration(0.25, animations: {
                self.extrasCollectionView.alpha = 0
                self.talentDetailView.alpha = 1
            }, completion: { (Bool) -> Void in
                self.extrasCollectionView.hidden = true
            })
        }
    }
    
    func hideTalentDetailView() {
        if selectedIndexPath != nil {
            talentTableView.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
            selectedIndexPath = nil
        }
        
        extrasCollectionView.hidden = false
        extrasCollectionView.alpha = 0
        homeButton.hidden = false
        backButton.hidden = true
        
        UIView.animateWithDuration(0.25, animations: {
            self.extrasCollectionView.alpha = 1
            self.talentDetailView.alpha = 0
        }, completion: { (Bool) -> Void in
            self.talentDetailView.hidden = true
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let allActors = DataManager.sharedInstance.content?.allActors() {
            return allActors.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCellIdentifier) as! TalentTableViewCell
        if let allActors = DataManager.sharedInstance.content?.allActors() {
            cell.talent = allActors[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ACTORS"
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath == selectedIndexPath {
            hideTalentDetailView()
            return nil
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        talentDetailViewController()?.talent = (tableView.cellForRowAtIndexPath(indexPath) as! TalentTableViewCell).talent
        showTalentDetailView()
    }
    
    // MARK: TalentDetailViewPresenter
    func talentDetailViewShouldClose() {
        hideTalentDetailView()
    }
    
    
    // MARK: Extras Content
    func showExtrasContentView() {
        if extrasContentView.hidden {
            extrasContentView.alpha = 0
            extrasContentView.hidden = false
            homeButton.hidden = true
            backButton.hidden = false
            
            UIView.animateWithDuration(0.25, animations: {
                self.extrasContentView.alpha = 1
            }, completion: { (Bool) -> Void in
                
            })
        }
    }
    
    func hideExtrasContentView() {
        homeButton.hidden = false
        backButton.hidden = true
        
        UIView.animateWithDuration(0.25, animations: {
            self.extrasContentView.alpha = 0
        }, completion: { (Bool) -> Void in
            self.extrasContentView.hidden = true
        })
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.extraImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("content", forIndexPath: indexPath)as! ContentCell
        
        cell.extraImg.image = UIImage (named: self.extraImages[indexPath.row])
        cell.extrasTitle.text = self.extrasCaption[indexPath.row]

        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        showExtrasContentView()
    }
}

extension ExtrasViewController: ExtrasLayoutDelegate{
    
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
