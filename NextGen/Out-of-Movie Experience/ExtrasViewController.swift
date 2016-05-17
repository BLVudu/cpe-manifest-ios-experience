//
//  ExtrasViewController.swift
//  NextGenPOC-Native
//
//  Created by Sedinam Gadzekpo on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//


import UIKit
import AVFoundation

class ExtrasViewController: ExtrasExperienceViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, TalentDetailViewPresenter {
    
    struct Constants {
        static let CollectionViewItemSpacing: CGFloat = 12
        static let CollectionViewLineSpacing: CGFloat = 12
        static let CollectionViewPadding: CGFloat = 15
        static let CollectionViewItemAspectRatio: CGFloat = 338 / 230
    }
    
    struct SegueIdentifier {
        static let ShowTalent = "ShowTalentSegueIdentifier"
        static let ShowGallery = "ExtrasGallerySegue"
        static let ShowMap = "ExtrasMapSegue"
        static let ShowShopping = "ExtrasShoppingSegue"
    }
    
    @IBOutlet weak var talentTableView: UITableView!
    @IBOutlet weak var talentDetailView: UIView!
    private var _talentDetailViewController: TalentDetailViewController?
    @IBOutlet var extrasCollectionView: UICollectionView!
    
    var selectedIndexPath: NSIndexPath?
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.talentTableView.registerNib(UINib(nibName: "TalentTableViewCell-Wide", bundle: nil), forCellReuseIdentifier: TalentTableViewCell.ReuseIdentifier)
        self.extrasCollectionView.registerNib(UINib(nibName: String(TitledImageCell), bundle: nil), forCellWithReuseIdentifier: TitledImageCell.ReuseIdentifier)
        self.talentTableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0)
        
        showHomeButton()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    
    // MARK: Actions
    override func close() {
        if !talentDetailView.hidden {
            hideTalentDetailView()
        } else {
            super.close()
        }
    }
    
    
    // MARK: Talent Details
    func showTalentDetailView() {
        if selectedIndexPath != nil {
            if let cell = talentTableView.cellForRowAtIndexPath(selectedIndexPath!) as? TalentTableViewCell, talent = cell.talent {
                if _talentDetailViewController != nil {
                    _talentDetailViewController!.loadTalent(talent)
                } else {
                    if let talentDetailViewController = UIStoryboard.getMainStoryboardViewController(TalentDetailViewController) as? TalentDetailViewController {
                        talentDetailViewController.talent = talent
                        
                        talentDetailViewController.view.frame = talentDetailView.bounds
                        talentDetailView.addSubview(talentDetailViewController.view)
                        self.addChildViewController(talentDetailViewController)
                        talentDetailViewController.didMoveToParentViewController(self)
                        
                        talentDetailView.alpha = 0
                        talentDetailView.hidden = false
                        showBackButton()
                        
                        UIView.animateWithDuration(0.25, animations: {
                            self.talentDetailView.alpha = 1
                        })
                        
                        _talentDetailViewController = talentDetailViewController
                    }
                }
            }
        }
    }
    
    func hideTalentDetailView() {
        if selectedIndexPath != nil {
            talentTableView.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
            selectedIndexPath = nil
        }
        
        showHomeButton()
        
        UIView.animateWithDuration(0.25, animations: {
            self.talentDetailView.alpha = 0
        }, completion: { (Bool) -> Void in
            self.talentDetailView.hidden = true
            self._talentDetailViewController?.willMoveToParentViewController(nil)
            self._talentDetailViewController?.view.removeFromSuperview()
            self._talentDetailViewController?.removeFromParentViewController()
            self._talentDetailViewController = nil
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let actors = CurrentManifest.mainExperience.orderedActors {
            return actors.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCell.ReuseIdentifier) as! TalentTableViewCell
        if let actors = CurrentManifest.mainExperience.orderedActors {
            cell.talent = actors[indexPath.row]
        }
        
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
        showTalentDetailView()
    }
    
    // MARK: TalentDetailViewPresenter
    func talentDetailViewShouldClose() {
        hideTalentDetailView()
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CurrentManifest.outOfMovieExperience.childExperiences?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TitledImageCell.ReuseIdentifier, forIndexPath: indexPath) as! TitledImageCell
        cell.experience = CurrentManifest.outOfMovieExperience.childExperiences?[indexPath.row]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let experience = CurrentManifest.outOfMovieExperience.childExperiences?[indexPath.row] {
            if experience.isType(.Shopping) {
                self.performSegueWithIdentifier(SegueIdentifier.ShowShopping, sender: experience)
            } else if experience.isType(.Location) {
                self.performSegueWithIdentifier(SegueIdentifier.ShowMap, sender: experience)
            } else {
                self.performSegueWithIdentifier(SegueIdentifier.ShowGallery, sender: experience)
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth: CGFloat = (CGRectGetWidth(collectionView.frame) / 2) - (Constants.CollectionViewItemSpacing * 2)
        return CGSizeMake(itemWidth, itemWidth / Constants.CollectionViewItemAspectRatio)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.CollectionViewLineSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.CollectionViewItemSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding)
    }
    
    // MARK: Storyboard
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? ExtrasExperienceViewController, experience = sender as? NGDMExperience {
            viewController.experience = experience
        }
    }
    
}
