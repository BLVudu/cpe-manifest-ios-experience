//
//  TalentDetailViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

protocol TalentDetailViewPresenter {
    func talentDetailViewShouldClose()
}

enum TalentDetailMode: String {
    case Synced = "TalentDetailModeSynced"
    case Extras = "TalentDetailModeExtras"
}

class TalentDetailViewController: SceneDetailViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private struct SegueIdentifier {
        static let TalentImageGallery = "TalentImageGallerySegueIdentifier"
    }
    
    @IBOutlet private var _containerViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var _talentImageView: UIImageView!
    @IBOutlet weak private var _talentGalleryButton: UIButton!
    @IBOutlet weak private var _talentNameLabel: UILabel!
    @IBOutlet weak private var _talentBiographyHeaderLabel: UILabel!
    @IBOutlet weak private var _talentBiographyLabel: UITextView!
    @IBOutlet private var _talentNoGalleryConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var _galleryContainerView: UIView?
    @IBOutlet weak private var _galleryHeaderLabel: UILabel?
    @IBOutlet weak private var _galleryCollectionView: UICollectionView?
    
    @IBOutlet weak private var _filmographyContainerView: UIView!
    @IBOutlet weak private var _filmographyHeaderLabel: UILabel!
    @IBOutlet weak private var _filmographyCollectionView: UICollectionView!
    
    @IBOutlet weak private var _twitterButton: SocialButton!
    @IBOutlet weak private var _facebookButton: SocialButton!
    @IBOutlet weak private var _instagramButton: SocialButton!
    @IBOutlet private var _facebookMainConstraint: NSLayoutConstraint!
    @IBOutlet private var _twitterMainConstraint: NSLayoutConstraint!
    @IBOutlet private var _facebookNoInstagramConstraint: NSLayoutConstraint!
    @IBOutlet private var _twitterNoFacebookConstraint: NSLayoutConstraint!
    @IBOutlet private var _twitterNoFacebookNoInstagramConstraint: NSLayoutConstraint!
    
    var images = [String]()
    var talent: Talent!
    var mode = TalentDetailMode.Extras
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localizations
        _talentBiographyHeaderLabel.text = String.localize("talentdetail.biography").uppercaseString
        _galleryHeaderLabel?.text = String.localize("talentdetail.gallery").uppercaseString
        _filmographyHeaderLabel.text = String.localize("talentdetail.filmography").uppercaseString
        
        if mode == .Extras {
            titleLabel.removeFromSuperview()
            closeButton.removeFromSuperview()
            _containerViewTopConstraint.constant = 20
        } else {
            _galleryHeaderLabel?.removeFromSuperview()
            _galleryCollectionView?.removeFromSuperview()
            _galleryContainerView?.removeFromSuperview()
            _galleryHeaderLabel = nil
            _galleryCollectionView = nil
            _galleryContainerView = nil
            _talentNoGalleryConstraint.priority = UILayoutPriorityRequired
        }
        
        loadTalent(talent)
    }
    
    func loadTalent(talent: Talent) {
        self.talent = talent
        
        _talentGalleryButton.hidden = mode != .Synced || talent.images == nil || talent.images!.count == 1
        
        _talentNameLabel.text = talent.name?.uppercaseString
        if let imageURL = talent.fullImageURL {
            _talentImageView.setImageWithURL(imageURL)
        } else {
            _talentImageView.image = nil
        }
        
        talent.getBiography({ (biography) in
            dispatch_async(dispatch_get_main_queue(), {
                self._talentBiographyLabel.text = biography
            })
        })
        
        _twitterButton.hidden = true
        _facebookButton.hidden = true
        _instagramButton.hidden = true
        talent.getSocialAccounts({ (socialAccounts) in
            dispatch_async(dispatch_get_main_queue(), {
                if let socialAccounts = socialAccounts {
                    for socialAccount in socialAccounts {
                        switch (socialAccount.type) {
                        case .Facebook:
                            self._facebookButton.hidden = false
                            self._facebookButton.socialAccount = socialAccount
                            break
                            
                        case .Twitter:
                            self._twitterButton.hidden = false
                            self._twitterButton.socialAccount = socialAccount
                            break
                            
                        case .Instagram:
                            self._instagramButton.hidden = false
                            self._instagramButton.socialAccount = socialAccount
                            break
                            
                        default:
                            break
                        }
                    }
                }
                
                self._twitterNoFacebookNoInstagramConstraint.active = self._facebookButton.hidden && self._instagramButton.hidden
                self._twitterNoFacebookConstraint.active = self._facebookButton.hidden && !self._instagramButton.hidden
                self._twitterMainConstraint.active = !self._twitterNoFacebookNoInstagramConstraint.active && !self._twitterNoFacebookConstraint.active
                self._facebookNoInstagramConstraint.active = self._instagramButton.hidden
                self._facebookMainConstraint.active = !self._facebookNoInstagramConstraint.active
            })
        })
        
        _filmographyCollectionView.backgroundColor = UIColor.clearColor()
        _filmographyCollectionView.showsHorizontalScrollIndicator = true
        _filmographyContainerView.hidden = true
        talent.getFilmography({ (films) in
            if let films = films {
                dispatch_async(dispatch_get_main_queue(), {
                    if films.count > 0 {
                        self._filmographyContainerView.hidden = false
                        self._filmographyCollectionView.reloadData()
                    } else {
                        self._filmographyContainerView.hidden = true
                    }
                })
            }
        })
        
        _galleryCollectionView?.reloadData()
    }
    
    // MARK: Actions
    override func close() {
        if self.parentViewController is TalentDetailViewPresenter {
            (self.parentViewController as! TalentDetailViewPresenter).talentDetailViewShouldClose()
        } else {
            super.close()
        }
    }
    
    @IBAction func openSocialURL(sender: SocialButton) {
        sender.openURL()
    }
    
    @IBAction func onLaunchGallery() {
        self.performSegueWithIdentifier(SegueIdentifier.TalentImageGallery, sender: nil)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == _filmographyCollectionView {
            return talent?.films?.count ?? 0
        }
        
        return talent?.additionalImages?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == _filmographyCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FilmCollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! FilmCollectionViewCell
            cell.film = talent?.films?[indexPath.row]
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SimpleImageCollectionViewCell.BaseReuseIdentifier, forIndexPath: indexPath) as! SimpleImageCollectionViewCell
        cell.imageURL = talent?.additionalImages?[indexPath.row].thumbnailImageURL
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == _galleryCollectionView {
            self.performSegueWithIdentifier(SegueIdentifier.TalentImageGallery, sender: indexPath.row + 1)
        }
    }
    
    // MARK: Storyboard Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.TalentImageGallery, let talentImageGalleryViewController = segue.destinationViewController as? TalentImageGalleryViewController {
            talentImageGalleryViewController.talent = talent
            talentImageGalleryViewController.initialPage = (sender as? Int) ?? 0
        }
    }

}
