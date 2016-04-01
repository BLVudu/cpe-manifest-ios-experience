//
//  ExtrasViewController.swift
//  NextGenPOC-Native
//
//  Created by Sedinam Gadzekpo on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//


import UIKit
import AVFoundation

class ExtrasViewController: StylizedViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, TalentDetailViewPresenter {
    
    let ExtrasVideoGallerySegueIdentifier = "ExtrasVideoGallerySegue"
    let ExtrasImageGalleryListSegueIdentifier = "ExtrasImageGalleryListSegue"
    let ExtrasShoppingSegueIdentifier = "ExtrasShoppingSegue"
    
    @IBOutlet weak var talentTableView: TalentTableView!
    @IBOutlet weak var talentDetailView: UIView!
    @IBOutlet var extrasCollectionView: UICollectionView!
    
    var selectedIndexPath: NSIndexPath?
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.talentTableView.registerNib(UINib(nibName: "TalentTableViewCell-Wide", bundle: nil), forCellReuseIdentifier: "TalentTableViewCell")
        self.extrasCollectionView.registerNib(UINib(nibName: "TitledImageCell", bundle: nil), forCellWithReuseIdentifier: TitledImageCell.ReuseIdentifier)
        
        self.navigationItem.setHomeButton(self, action: #selector(ExtrasViewController.close))
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    
    // MARK: Actions
    func close() {
        if talentDetailView.hidden {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            hideTalentDetailView()
        }
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
            self.navigationItem.setBackButton(self, action: #selector(ExtrasViewController.close))
            
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
        self.navigationItem.setHomeButton(self, action: #selector(ExtrasViewController.close))
        
        UIView.animateWithDuration(0.25, animations: {
            self.extrasCollectionView.alpha = 1
            self.talentDetailView.alpha = 0
        }, completion: { (Bool) -> Void in
            self.talentDetailView.hidden = true
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NextGenDataManager.sharedInstance.mainExperience.orderedActors.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCell.ReuseIdentifier) as! TalentTableViewCell
        let talent = NextGenDataManager.sharedInstance.mainExperience.orderedActors[indexPath.row]
        cell.talent = talent
        
        return cell
    }
    
    // MARK: UITableViewDelegate
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
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NextGenDataManager.sharedInstance.mainExperience.extrasExperience.childExperiences.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TitledImageCell.ReuseIdentifier, forIndexPath: indexPath) as! TitledImageCell
        cell.experience = NextGenDataManager.sharedInstance.mainExperience.extrasExperience.childExperiences[indexPath.row]
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let experience = NextGenDataManager.sharedInstance.mainExperience.extrasExperience.childExperiences[indexPath.row]
        if experience.isGalleryList() {
            self.performSegueWithIdentifier(ExtrasImageGalleryListSegueIdentifier, sender: experience)
        } else if experience.isShopping() {
            self.performSegueWithIdentifier(ExtrasShoppingSegueIdentifier, sender: experience)
        } else {
            self.performSegueWithIdentifier(ExtrasVideoGallerySegueIdentifier, sender: experience)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((CGRectGetWidth(collectionView.frame) / 2) - 10, 235)
    }
    
    
    // MARK: Storyboard
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let experience = sender as? NGDMExperience {
            if segue.identifier == ExtrasVideoGallerySegueIdentifier {
                if let videoGalleryViewController = segue.destinationViewController as? ExtrasVideoGalleryViewController {
                    videoGalleryViewController.experience = experience
                }
            } else if segue.identifier == ExtrasImageGalleryListSegueIdentifier {
                if let imageGalleryListViewController = segue.destinationViewController as? ExtrasImageGalleryListCollectionViewController {
                    imageGalleryListViewController.experience = experience
                }
            } else if segue.identifier == ExtrasShoppingSegueIdentifier {
                if let shoppingViewController = segue.destinationViewController as? ExtrasShoppingViewController {
                    shoppingViewController.experience = experience
                }
            }
        }
    }
    
}
