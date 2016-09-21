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

class TalentDetailViewController: SceneDetailViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private struct SegueIdentifier {
        static let TalentImageGallery = "TalentImageGallerySegueIdentifier"
    }
    
    private struct Constants {
        static let GalleryCollectionViewItemSpacing: CGFloat = 10
        static let GalleryCollectionViewItemAspectRatio: CGFloat = 8 / 10
        static let FilmographyCollectionViewItemSpacing: CGFloat = 10
        static let FilmographyCollectionViewItemAspectRatio: CGFloat = 27 / 41
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
        _talentBiographyHeaderLabel.text = String.localize("talentdetail.biography").uppercased()
        _galleryHeaderLabel?.text = String.localize("talentdetail.gallery").uppercased()
        _filmographyHeaderLabel.text = String.localize("talentdetail.filmography").uppercased()
        
        if mode == .Extras {
            titleLabel.removeFromSuperview()
            closeButton.removeFromSuperview()
            _containerViewTopConstraint.constant = (DeviceType.IS_IPAD ? 20 : 10)
            
            _talentGalleryButton?.removeFromSuperview()
            _galleryCollectionView?.register(UINib(nibName: "SimpleImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SimpleImageCollectionViewCell.BaseReuseIdentifier)
        } else {
            _biographyToFilmographyConstraint?.isActive = true
            _biographyToGalleryConstraint?.isActive = false
            _biographyToGalleryConstraint = nil
            _galleryHeaderLabel?.removeFromSuperview()
            _galleryCollectionView?.removeFromSuperview()
            _galleryContainerView?.removeFromSuperview()
        }
        
        let launchGalleryTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onLaunchGallery))
        launchGalleryTapGestureRecognizer.numberOfTapsRequired = 1
        _talentImageView.addGestureRecognizer(launchGalleryTapGestureRecognizer)
        
        _filmographyCollectionView.register(UINib(nibName: "SimpleImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SimpleImageCollectionViewCell.BaseReuseIdentifier)
        
        loadTalent(talent)
    }
    
    func loadTalent(_ talent: NGDMTalent) {
        self.talent = talent
        
        _talentNameLabel.text = talent.name?.uppercased()
        if let imageURL = talent.fullImageURL {
            _talentImageView.sd_setImage(with: imageURL)
        } else {
            _talentImageView.sd_cancelCurrentImageLoad()
            _talentImageView.image = nil
        }
        
        _twitterButton.isHidden = true
        _facebookButton.isHidden = true
        _instagramButton.isHidden = true
        
        
        let talentHasGallery = talent.images != nil && talent.images!.count > 1
        _talentImageView.isUserInteractionEnabled = talentHasGallery
        if mode == .Extras {
            _galleryContainerView?.isHidden = !talentHasGallery
            _biographyToFilmographyConstraint?.isActive = !talentHasGallery
            _biographyToGalleryConstraint?.isActive = talentHasGallery
        } else {
            _talentGalleryButton?.isHidden = !talentHasGallery
        }
        
        _talentBiographyLabel.text = nil
        
        _filmographyCollectionView.backgroundColor = UIColor.clear
        _filmographyContainerView.isHidden = true
        
        if !talent.detailsLoaded {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            talent.getTalentDetails({ (biography, socialAccounts, films) in
                DispatchQueue.main.async(execute: {
                    self._talentBiographyLabel.text = biography
                    self._talentBiographyLabel.scrollRectToVisible(CGRect.zero, animated: false)
                    self._talentBiographyLabel.scrollRangeToVisible(NSMakeRange(0, 0))
                    
                    if let socialAccounts = socialAccounts {
                        for socialAccount in socialAccounts {
                            switch (socialAccount.type) {
                            case .facebook:
                                self._facebookButton.isHidden = false
                                self._facebookButton.socialAccount = socialAccount
                                break
                                
                            case .twitter:
                                self._twitterButton.isHidden = false
                                self._twitterButton.socialAccount = socialAccount
                                break
                                
                            case .instagram:
                                self._instagramButton.isHidden = false
                                self._instagramButton.socialAccount = socialAccount
                                break
                                
                            default:
                                break
                            }
                        }
                    }
                    
                    if self._twitterNoFacebookNoInstagramConstraint != nil {
                        self._twitterNoFacebookNoInstagramConstraint!.isActive = self._facebookButton.isHidden && self._instagramButton.isHidden
                        self._twitterNoFacebookConstraint!.isActive = self._facebookButton.isHidden && !self._instagramButton.isHidden
                        self._twitterMainConstraint!.isActive = !self._twitterNoFacebookNoInstagramConstraint!.isActive && !self._twitterNoFacebookConstraint!.isActive
                        self._facebookNoInstagramConstraint!.isActive = self._instagramButton.isHidden
                        self._facebookMainConstraint!.isActive = !self._facebookNoInstagramConstraint!.isActive
                    }
                    
                    let hasFilms = films != nil && films!.count > 0
                    self._filmographyContainerView.isHidden = !hasFilms
                    if hasFilms {
                        self._filmographyCollectionView.reloadData()
                        self._filmographyCollectionView.setContentOffset(CGPoint(), animated: false)
                    }
                    
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                })
            })
        }
        
        _galleryCollectionView?.reloadData()
    }
    
    // MARK: Actions
    override func close() {
        if self.parent is TalentDetailViewPresenter {
            (self.parent as! TalentDetailViewPresenter).talentDetailViewShouldClose()
        } else {
            super.close()
        }
    }
    
    @IBAction func openSocialURL(_ sender: SocialButton) {
        sender.openURL()
    }
    
    @IBAction func onLaunchGallery() {
        self.performSegue(withIdentifier: SegueIdentifier.TalentImageGallery, sender: nil)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == _filmographyCollectionView {
            return talent?.films?.count ?? 0
        }
        
        return talent?.additionalImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimpleImageCollectionViewCell.BaseReuseIdentifier, for: indexPath) as! SimpleImageCollectionViewCell
        if collectionView == _filmographyCollectionView {
            cell.imageURL = talent?.films?[indexPath.row].imageURL
        } else {
            cell.imageURL = talent?.additionalImages?[indexPath.row].thumbnailImageURL
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == _galleryCollectionView {
            self.performSegue(withIdentifier: SegueIdentifier.TalentImageGallery, sender: (indexPath as NSIndexPath).row + 1)
        } else if collectionView == _filmographyCollectionView {
            if let film = talent?.films?[indexPath.row], let delegate = NextGenHook.delegate {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                delegate.getUrlForContent(film.title, completion: { [weak self] (url) in
                    if let strongSelf = self {
                        MBProgressHUD.hideAllHUDs(for: strongSelf.view, animated: true)
                    }
                    
                    url?.promptLaunchBrowser()
                })
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        var width: CGFloat
        if collectionView == _filmographyCollectionView {
            width = height * Constants.FilmographyCollectionViewItemAspectRatio
        } else {
            width = height * Constants.GalleryCollectionViewItemAspectRatio
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == _filmographyCollectionView {
            return Constants.FilmographyCollectionViewItemSpacing
        }
        
        return Constants.GalleryCollectionViewItemSpacing
    }
    
    // MARK: Storyboard Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.TalentImageGallery, let talentImageGalleryViewController = segue.destination as? TalentImageGalleryViewController {
            talentImageGalleryViewController.talent = talent
            talentImageGalleryViewController.initialPage = (sender as? Int) ?? 0
        }
    }

}
