//
//  ExtrasViewController.swift
//  NextGenPOC-Native
//
//  Created by Sedinam Gadzekpo on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//


import UIKit
import AVFoundation

class ExtrasViewController: StylizedViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, TalentDetailViewPresenter {
    
    let ExtrasContentSegueIdentifier = "ExtrasContentSegue"
    
    @IBOutlet weak var talentTableView: TalentTableView!
    @IBOutlet weak var talentDetailView: UIView!
    @IBOutlet var extrasCollectionView: UICollectionView!
    
    var selectedIndexPath: NSIndexPath?
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.talentTableView.registerNib(UINib(nibName: "TalentTableViewCell-Wide", bundle: nil), forCellReuseIdentifier: "TalentTableViewCell")
        self.extrasCollectionView.registerNib(UINib(nibName: "ContentCell", bundle: nil), forCellWithReuseIdentifier: "content")
        
        if let layout = extrasCollectionView?.collectionViewLayout as? ExtrasLayout {
            layout.delegate = self
        }
        
        self.navigationItem.setHomeButton(self, action: "close")
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
            self.navigationItem.setBackButton(self, action: "close")
            
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
        self.navigationItem.setHomeButton(self, action: "close")
        
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
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NextGenDataManager.sharedInstance.mainExperience.extrasExperience.childExperiences.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("content", forIndexPath: indexPath)as! ContentCell
        
        let experience = NextGenDataManager.sharedInstance.mainExperience.extrasExperience.childExperiences[indexPath.row]
        cell.extrasTitle.text = experience.metadata?.title
        if let thumbnailImagePath = experience.thumbnailImagePath {
            cell.extraImg.setImageWithURL(NSURL(string: thumbnailImagePath)!)
        }
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(ExtrasContentSegueIdentifier, sender: NextGenDataManager.sharedInstance.mainExperience.extrasExperience.childExperiences[indexPath.row])
    }
    
    
    // MARK: Storyboard
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let experience = sender as? NGDMExperience {
            if segue.identifier == ExtrasContentSegueIdentifier && segue.destinationViewController.isKindOfClass(ExtrasContentViewController) {
                let contentViewController = segue.destinationViewController as! ExtrasContentViewController
                contentViewController.experience = experience
            }
        }
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
