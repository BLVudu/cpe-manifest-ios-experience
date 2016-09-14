//
//  ExtrasViewController.swift
//


import UIKit
import AVFoundation
import NextGenDataManager

class ExtrasViewController: ExtrasExperienceViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, TalentDetailViewPresenter {
    
    fileprivate struct Constants {
        static let CollectionViewItemSpacing: CGFloat = (DeviceType.IS_IPAD ? 12 : 5)
        static let CollectionViewLineSpacing: CGFloat = (DeviceType.IS_IPAD ? 12 : 25)
        static let CollectionViewPadding: CGFloat = (DeviceType.IS_IPAD ? 15 : 10)
        static let CollectionViewItemAspectRatio: CGFloat = 318 / 224
    }
    
    fileprivate struct SegueIdentifier {
        static let ShowTalent = "ShowTalentSegueIdentifier"
        static let ShowGallery = "ExtrasGallerySegue"
        static let ShowMap = "ExtrasMapSegue"
        static let ShowShopping = "ExtrasShoppingSegue"
        static let ShowTalentSelector = "TalentSelectorSegueIdentifier"
    }
    
    @IBOutlet weak var talentTableView: UITableView?
    @IBOutlet weak var talentDetailView: UIView?
    @IBOutlet var extrasCollectionView: UICollectionView!
    
    fileprivate var talentDetailViewController: TalentDetailViewController?
    fileprivate var selectedIndexPath: IndexPath?
    
    fileprivate var showActorsInGrid: Bool {
        return !DeviceType.IS_IPAD && NGDMManifest.sharedInstance.hasActors
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let talentTableView = talentTableView {
            if let actors = NGDMManifest.sharedInstance.mainExperience?.orderedActors , actors.count > 0 {
                talentTableView.register(UINib(nibName: "TalentTableViewCell-Wide", bundle: nil), forCellReuseIdentifier: TalentTableViewCell.ReuseIdentifier)
                talentTableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0)
            } else {
                talentTableView.removeFromSuperview()
                self.talentTableView = nil
            }
        }
        
        extrasCollectionView.register(UINib(nibName: "TitledImageCell", bundle: nil), forCellWithReuseIdentifier: TitledImageCell.ReuseIdentifier)
        
        showHomeButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        extrasCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    // MARK: Actions
    override func close() {
        if talentDetailView != nil && !talentDetailView!.isHidden {
            hideTalentDetailView()
        } else {
            super.close()
        }
    }
    
    
    // MARK: Talent Details
    func showTalentDetailView() {
        if selectedIndexPath != nil {
            if let cell = talentTableView?.cellForRow(at: selectedIndexPath!) as? TalentTableViewCell, let talent = cell.talent {
                if talentDetailViewController != nil {
                    talentDetailViewController!.loadTalent(talent)
                } else {
                    if let talentDetailView = talentDetailView, let talentDetailViewController = UIStoryboard.getNextGenViewController(TalentDetailViewController.self) as? TalentDetailViewController {
                        talentDetailViewController.talent = talent
                        
                        talentDetailViewController.view.frame = talentDetailView.bounds
                        talentDetailView.addSubview(talentDetailViewController.view)
                        self.addChildViewController(talentDetailViewController)
                        talentDetailViewController.didMove(toParentViewController: self)
                        
                        talentDetailView.alpha = 0
                        talentDetailView.isHidden = false
                        showBackButton()
                        
                        UIView.animate(withDuration: 0.25, animations: {
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
            talentTableView?.deselectRow(at: selectedIndexPath!, animated: true)
            selectedIndexPath = nil
        }
        
        showHomeButton()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.talentDetailView?.alpha = 0
        }, completion: { (Bool) -> Void in
            self.talentDetailView?.isHidden = true
            self.talentDetailViewController?.willMove(toParentViewController: nil)
            self.talentDetailViewController?.view.removeFromSuperview()
            self.talentDetailViewController?.removeFromParentViewController()
            self.talentDetailViewController = nil
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NGDMManifest.sharedInstance.mainExperience?.orderedActors?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TalentTableViewCell.ReuseIdentifier) as! TalentTableViewCell
        cell.talent = NGDMManifest.sharedInstance.mainExperience?.orderedActors?[indexPath.row]
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath == selectedIndexPath {
            hideTalentDetailView()
            return nil
        }
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        showTalentDetailView()
    }
    
    // MARK: TalentDetailViewPresenter
    func talentDetailViewShouldClose() {
        hideTalentDetailView()
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var experiencesCount = NGDMManifest.sharedInstance.outOfMovieExperience?.childExperiences?.count ?? 0
        if showActorsInGrid {
            experiencesCount += 1
        }
        
        return experiencesCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitledImageCell.ReuseIdentifier, for: indexPath) as! TitledImageCell
        
        var childExperienceIndex = (indexPath as NSIndexPath).row
        if showActorsInGrid {
            if (indexPath as NSIndexPath).row == 0 {
                cell.experience = nil
                cell.title = String.localize("label.actors")
                cell.imageURL = NGDMManifest.sharedInstance.mainExperience?.orderedActors?.first?.images?.first?.thumbnailImageURL
                return cell
            }
            
            childExperienceIndex -= 1
        }
        
        cell.experience = NGDMManifest.sharedInstance.outOfMovieExperience?.childExperiences?[childExperienceIndex]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var childExperienceIndex = (indexPath as NSIndexPath).row
        if showActorsInGrid {
            if (indexPath as NSIndexPath).row == 0 {
                self.performSegue(withIdentifier: SegueIdentifier.ShowTalentSelector, sender: nil)
                return
            }
            
            childExperienceIndex -= 1
        }
        
        if let experience = NGDMManifest.sharedInstance.outOfMovieExperience?.childExperiences?[childExperienceIndex] {
            if experience.isType(.shopping) {
                self.performSegue(withIdentifier: SegueIdentifier.ShowShopping, sender: experience)
            } else if experience.isType(.location) {
                self.performSegue(withIdentifier: SegueIdentifier.ShowMap, sender: experience)
            } else if experience.isType(.app) {
                if let app = experience.app, let url = app.url {
                    let webViewController = WebViewController(title: app.title, url: url)
                    self.present(webViewController, animated: true, completion: nil)
                }
            } else {
                self.performSegue(withIdentifier: SegueIdentifier.ShowGallery, sender: experience)
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let containerWidth = collectionView.frame.width - (Constants.CollectionViewPadding * 2)
        let itemWidth: CGFloat = (containerWidth / 2) - Constants.CollectionViewItemSpacing
        return CGSize(width: itemWidth, height: itemWidth / Constants.CollectionViewItemAspectRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.CollectionViewLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.CollectionViewItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding)
    }
    
    // MARK: Storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ExtrasExperienceViewController, let experience = sender as? NGDMExperience {
            viewController.experience = experience
        }
    }
    
}
