//
//  ExtrasViewController.swift
//


import UIKit
import AVFoundation
import NextGenDataManager

class ExtrasViewController: ExtrasExperienceViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, TalentDetailViewPresenter {
    
    private struct Constants {
        static let CollectionViewItemSpacing: CGFloat = (DeviceType.IS_IPAD ? 12 : 5)
        static let CollectionViewLineSpacing: CGFloat = (DeviceType.IS_IPAD ? 12 : 15)
        static let CollectionViewPadding: CGFloat = (DeviceType.IS_IPAD ? 15 : 10)
        static let CollectionViewItemAspectRatio: CGFloat = 338 / 230
    }
    
    private struct SegueIdentifier {
        static let ShowTalent = "ShowTalentSegueIdentifier"
        static let ShowGallery = "ExtrasGallerySegue"
        static let ShowMap = "ExtrasMapSegue"
        static let ShowShopping = "ExtrasShoppingSegue"
        static let ShowTalentSelector = "TalentSelectorSegueIdentifier"
    }
    
    @IBOutlet weak var talentTableView: UITableView?
    @IBOutlet weak var talentDetailView: UIView?
    @IBOutlet var extrasCollectionView: UICollectionView!
    
    private var talentDetailViewController: TalentDetailViewController?
    private var selectedIndexPath: NSIndexPath?
    
    private var showActorsInGrid: Bool {
        return !DeviceType.IS_IPAD && NGDMManifest.sharedInstance.hasActors
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let talentTableView = talentTableView {
            if let actors = NGDMManifest.sharedInstance.mainExperience?.orderedActors where actors.count > 0 {
                talentTableView.registerNib(UINib(nibName: "TalentTableViewCell-Wide", bundle: nil), forCellReuseIdentifier: TalentTableViewCell.ReuseIdentifier)
                talentTableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0)
            } else {
                talentTableView.removeFromSuperview()
                self.talentTableView = nil
            }
        }
        
        extrasCollectionView.registerNib(UINib(nibName: String(TitledImageCell), bundle: nil), forCellWithReuseIdentifier: TitledImageCell.ReuseIdentifier)
        
        showHomeButton()
    }
    
    
    // MARK: Actions
    override func close() {
        if talentDetailView != nil && !talentDetailView!.hidden {
            hideTalentDetailView()
        } else {
            super.close()
        }
    }
    
    
    // MARK: Talent Details
    func showTalentDetailView() {
        if selectedIndexPath != nil {
            if let cell = talentTableView?.cellForRowAtIndexPath(selectedIndexPath!) as? TalentTableViewCell, talent = cell.talent {
                if talentDetailViewController != nil {
                    talentDetailViewController!.loadTalent(talent)
                } else {
                    if let talentDetailView = talentDetailView, talentDetailViewController = UIStoryboard.getNextGenViewController(TalentDetailViewController) as? TalentDetailViewController {
                        talentDetailViewController.talent = talent
                        
                        talentDetailViewController.view.frame = talentDetailView.bounds
                        talentDetailView.addSubview(talentDetailViewController.view)
                        self.addChildViewController(talentDetailViewController)
                        talentDetailViewController.didMoveToParentViewController(self)
                        
                        talentDetailView.alpha = 0
                        talentDetailView.hidden = false
                        showBackButton()
                        
                        UIView.animateWithDuration(0.25, animations: {
                            talentDetailView.alpha = 1
                        })
                        
                        self.talentDetailViewController = talentDetailViewController
                    }
                }
            }
        }
    }
    
    func hideTalentDetailView() {
        if selectedIndexPath != nil {
            talentTableView?.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
            selectedIndexPath = nil
        }
        
        showHomeButton()
        
        UIView.animateWithDuration(0.25, animations: {
            self.talentDetailView?.alpha = 0
        }, completion: { (Bool) -> Void in
            self.talentDetailView?.hidden = true
            self.talentDetailViewController?.willMoveToParentViewController(nil)
            self.talentDetailViewController?.view.removeFromSuperview()
            self.talentDetailViewController?.removeFromParentViewController()
            self.talentDetailViewController = nil
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NGDMManifest.sharedInstance.mainExperience?.orderedActors?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCell.ReuseIdentifier) as! TalentTableViewCell
        cell.talent = NGDMManifest.sharedInstance.mainExperience?.orderedActors?[indexPath.row]
        
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
        var experiencesCount = NGDMManifest.sharedInstance.outOfMovieExperience?.childExperiences?.count ?? 0
        if showActorsInGrid {
            experiencesCount += 1
        }
        
        return experiencesCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TitledImageCell.ReuseIdentifier, forIndexPath: indexPath) as! TitledImageCell
        
        var childExperienceIndex = indexPath.row
        if showActorsInGrid {
            if indexPath.row == 0 {
                cell.experience = nil
                cell.setTitle(String.localize("label.actors"))
                cell.setImageURL(NGDMManifest.sharedInstance.mainExperience?.orderedActors?.first?.images?.first?.thumbnailImageURL)
                return cell
            }
            
            childExperienceIndex -= 1
        }
        
        cell.experience = NGDMManifest.sharedInstance.outOfMovieExperience?.childExperiences?[childExperienceIndex]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var childExperienceIndex = indexPath.row
        if showActorsInGrid {
            if indexPath.row == 0 {
                self.performSegueWithIdentifier(SegueIdentifier.ShowTalentSelector, sender: nil)
                return
            }
            
            childExperienceIndex -= 1
        }
        
        if let experience = NGDMManifest.sharedInstance.outOfMovieExperience?.childExperiences?[childExperienceIndex] {
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
        let containerWidth = CGRectGetWidth(collectionView.frame) - (Constants.CollectionViewPadding * 2)
        let itemWidth: CGFloat = (containerWidth / 2) - Constants.CollectionViewItemSpacing
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
