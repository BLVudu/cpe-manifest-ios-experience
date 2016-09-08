//
//  TalentDetailViewController.swift
//

import UIKit
import NextGenDataManager
import MBProgressHUD

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
    @IBOutlet weak private var _talentGalleryButton: UIButton?
    @IBOutlet weak private var _talentNameLabel: UILabel!
    @IBOutlet weak private var _talentBiographyHeaderLabel: UILabel!
    @IBOutlet weak private var _talentBiographyLabel: UITextView!
    
    @IBOutlet weak private var _galleryContainerView: UIView?
    @IBOutlet weak private var _galleryHeaderLabel: UILabel?
    @IBOutlet weak private var _galleryCollectionView: UICollectionView?
    @IBOutlet private var _biographyToFilmographyConstraint: NSLayoutConstraint?
    @IBOutlet private var _biographyToGalleryConstraint: NSLayoutConstraint?
    
    @IBOutlet weak private var _filmographyContainerView: UIView!
    @IBOutlet weak private var _filmographyHeaderLabel: UILabel!
    @IBOutlet weak private var _filmographyCollectionView: UICollectionView!
    
    @IBOutlet weak private var _twitterButton: SocialButton!
    @IBOutlet weak private var _facebookButton: SocialButton!
    @IBOutlet weak private var _instagramButton: SocialButton!
    @IBOutlet private var _facebookMainConstraint: NSLayoutConstraint?
    @IBOutlet private var _twitterMainConstraint: NSLayoutConstraint?
    @IBOutlet private var _facebookNoInstagramConstraint: NSLayoutConstraint?
    @IBOutlet private var _twitterNoFacebookConstraint: NSLayoutConstraint?
    @IBOutlet private var _twitterNoFacebookNoInstagramConstraint: NSLayoutConstraint?
    
    var images = [String]()
    var talent: NGDMTalent!
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
            
            _talentGalleryButton?.removeFromSuperview()
            _galleryCollectionView?.registerNib(UINib(nibName: String(SimpleImageCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: SimpleImageCollectionViewCell.BaseReuseIdentifier)
        } else {
            _biographyToFilmographyConstraint?.active = true
            _biographyToGalleryConstraint?.active = false
            _biographyToGalleryConstraint = nil
            _galleryHeaderLabel?.removeFromSuperview()
            _galleryCollectionView?.removeFromSuperview()
            _galleryContainerView?.removeFromSuperview()
        }
        
        let launchGalleryTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onLaunchGallery))
        launchGalleryTapGestureRecognizer.numberOfTapsRequired = 1
        _talentImageView.addGestureRecognizer(launchGalleryTapGestureRecognizer)
        
        _filmographyCollectionView.registerNib(UINib(nibName: String(SimpleImageCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: SimpleImageCollectionViewCell.BaseReuseIdentifier)
        
        loadTalent(talent)
    }
    
    func loadTalent(talent: NGDMTalent) {
        self.talent = talent
        
        _talentNameLabel.text = talent.name?.uppercaseString
        if let imageURL = talent.fullImageURL {
            _talentImageView.af_setImageWithURL(imageURL)
        } else {
            _talentImageView.af_cancelImageRequest()
            _talentImageView.image = nil
        }
        
        _twitterButton.hidden = true
        _facebookButton.hidden = true
        _instagramButton.hidden = true
        
        
        let talentHasGallery = talent.images != nil && talent.images!.count > 1
        _talentImageView.userInteractionEnabled = talentHasGallery
        if mode == .Extras {
            _galleryContainerView?.hidden = !talentHasGallery
            _biographyToFilmographyConstraint?.active = !talentHasGallery
            _biographyToGalleryConstraint?.active = talentHasGallery
        } else {
            _talentGalleryButton?.hidden = !talentHasGallery
        }
        
        _talentBiographyLabel.text = nil
        
        _filmographyCollectionView.backgroundColor = UIColor.clearColor()
        _filmographyContainerView.hidden = true
        
        if !talent.detailsLoaded {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            talent.getTalentDetails({ (biography, socialAccounts, films) in
                dispatch_async(dispatch_get_main_queue(), {
                    self._talentBiographyLabel.text = biography
                    self._talentBiographyLabel.scrollRangeToVisible(NSMakeRange(0, 0))
                    
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
                    
                    if self._twitterNoFacebookNoInstagramConstraint != nil {
                        self._twitterNoFacebookNoInstagramConstraint!.active = self._facebookButton.hidden && self._instagramButton.hidden
                        self._twitterNoFacebookConstraint!.active = self._facebookButton.hidden && !self._instagramButton.hidden
                        self._twitterMainConstraint!.active = !self._twitterNoFacebookNoInstagramConstraint!.active && !self._twitterNoFacebookConstraint!.active
                        self._facebookNoInstagramConstraint!.active = self._instagramButton.hidden
                        self._facebookMainConstraint!.active = !self._facebookNoInstagramConstraint!.active
                    }
                    
                    let hasFilms = films != nil && films!.count > 0
                    self._filmographyContainerView.hidden = !hasFilms
                    if hasFilms {
                        self._filmographyCollectionView.reloadData()
                        self._filmographyCollectionView.setContentOffset(CGPointMake(0, 0), animated: false)
                    }
                    
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                })
            })
        }
        
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SimpleImageCollectionViewCell.BaseReuseIdentifier, forIndexPath: indexPath) as! SimpleImageCollectionViewCell
        if collectionView == _filmographyCollectionView {
            cell.imageURL = talent?.films?[indexPath.row].imageURL
        } else {
            cell.imageURL = talent?.additionalImages?[indexPath.row].thumbnailImageURL
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == _galleryCollectionView {
            self.performSegueWithIdentifier(SegueIdentifier.TalentImageGallery, sender: indexPath.row + 1)
        } else if collectionView == _filmographyCollectionView {
            if let film = talent?.films?[indexPath.row], delegate = NextGenHook.delegate {
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                delegate.getUrlForContent(film.title, completion: { [weak self] (url) in
                    if let strongSelf = self {
                        MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true)
                    }
                    
                    url?.promptLaunchBrowser()
                })
            }
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
