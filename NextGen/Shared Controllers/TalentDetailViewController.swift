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
        static let FilmographyCollectionViewItemAspectRatio: CGFloat = 27 / 40
    }
    
    @IBOutlet private var containerViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var talentImageView: UIImageView?
    @IBOutlet weak private var talentGalleryButton: UIButton?
    @IBOutlet weak private var talentNameLabel: UILabel!
    @IBOutlet weak private var talentBiographyContainerView: UIView?
    @IBOutlet weak private var talentBiographyHeaderLabel: UILabel?
    @IBOutlet weak private var talentBiographyLabel: UITextView?
    
    @IBOutlet weak private var galleryContainerView: UIView?
    @IBOutlet weak private var galleryHeaderLabel: UILabel?
    @IBOutlet weak private var galleryCollectionView: UICollectionView?
    
    @IBOutlet weak private var filmographyContainerView: UIView?
    @IBOutlet weak private var filmographyHeaderLabel: UILabel!
    @IBOutlet weak private var filmographyCollectionView: UICollectionView!
    
    @IBOutlet weak private var twitterButton: SocialButton?
    @IBOutlet weak private var facebookButton: SocialButton?
    @IBOutlet weak private var instagramButton: SocialButton?
    
    var images = [String]()
    var talent: NGDMTalent!
    var mode = TalentDetailMode.Extras
    
    var currentAnalyticsEvent: NextGenAnalyticsEvent {
        return (mode == .Synced ? .imeTalentAction : .extrasTalentAction)
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localizations
        talentBiographyHeaderLabel?.text = String.localize("talentdetail.biography").uppercased()
        galleryHeaderLabel?.text = String.localize("talentdetail.gallery").uppercased()
        filmographyHeaderLabel.text = String.localize("talentdetail.filmography").uppercased()
        
        // Mode Layout
        let talentHasGallery = talent.images != nil && talent.images!.count > 1
        if mode == .Extras {
            titleLabel.removeFromSuperview()
            closeButton.removeFromSuperview()
            containerViewTopConstraint.constant = (DeviceType.IS_IPAD ? 20 : 10)
            talentGalleryButton?.removeFromSuperview()
            galleryCollectionView?.register(UINib(nibName: "SimpleImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SimpleImageCollectionViewCell.BaseReuseIdentifier)
            if !talentHasGallery {
                galleryContainerView?.removeFromSuperview()
            }
        } else {
            galleryHeaderLabel?.removeFromSuperview()
            galleryCollectionView?.removeFromSuperview()
            galleryContainerView?.removeFromSuperview()
            if talentHasGallery {
                talentGalleryButton?.isHidden = false
            }
        }
        
        if talentHasGallery {
            let launchGalleryTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onLaunchGallery))
            launchGalleryTapGestureRecognizer.numberOfTapsRequired = 1
            talentImageView?.addGestureRecognizer(launchGalleryTapGestureRecognizer)
            talentImageView?.isUserInteractionEnabled = true
        }
        
        // Fill data
        talentNameLabel.text = talent.name?.uppercased()
        if let imageURL = talent.fullImageURL {
            talentImageView?.sd_setImage(with: imageURL)
        } else {
            talentImageView?.removeFromSuperview()
        }
        
        filmographyCollectionView.register(UINib(nibName: "SimpleImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SimpleImageCollectionViewCell.BaseReuseIdentifier)
        
        if !talent.detailsLoaded {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.talent.getTalentDetails({ (biography, socialAccounts, films) in
                DispatchQueue.main.async(execute: {
                    if let biography = biography {
                        self.talentBiographyContainerView?.isHidden = false
                        self.talentBiographyLabel?.text = biography
                        self.talentBiographyLabel?.scrollRectToVisible(CGRect.zero, animated: false)
                    } else {
                        self.talentBiographyContainerView?.removeFromSuperview()
                    }
                    
                    if let socialAccounts = socialAccounts {
                        for socialAccount in socialAccounts {
                            switch (socialAccount.type) {
                            case .facebook:
                                self.facebookButton?.isHidden = false
                                self.facebookButton?.socialAccount = socialAccount
                                break
                                
                            case .twitter:
                                self.twitterButton?.isHidden = false
                                self.twitterButton?.socialAccount = socialAccount
                                break
                                
                            case .instagram:
                                self.instagramButton?.isHidden = false
                                self.instagramButton?.socialAccount = socialAccount
                                break
                                
                            default:
                                break
                            }
                        }
                    }
                    
                    if let button = self.facebookButton, button.isHidden {
                        button.removeFromSuperview()
                    }
                    
                    if let button = self.twitterButton, button.isHidden {
                        button.removeFromSuperview()
                    }
                    
                    if let button = self.instagramButton, button.isHidden {
                        button.removeFromSuperview()
                    }
                    
                    let hasFilms = films != nil && films!.count > 0
                    if hasFilms {
                        self.filmographyContainerView?.isHidden = false
                        self.filmographyCollectionView.reloadData()
                        self.filmographyCollectionView.setContentOffset(CGPoint(), animated: false)
                    } else {
                        self.filmographyContainerView?.removeFromSuperview()
                    }
                    
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                })
            })
        }
        
        galleryCollectionView?.reloadData()
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
        NextGenHook.logAnalyticsEvent(currentAnalyticsEvent, action: .selectSocial, itemId: talent.id, itemName: sender.socialAccount.type.rawValue)
    }
    
    @IBAction func onLaunchGallery() {
        self.performSegue(withIdentifier: SegueIdentifier.TalentImageGallery, sender: nil)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == filmographyCollectionView {
            return talent?.films?.count ?? 0
        }
        
        return talent?.additionalImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimpleImageCollectionViewCell.BaseReuseIdentifier, for: indexPath) as! SimpleImageCollectionViewCell
        if collectionView == filmographyCollectionView {
            cell.imageURL = talent?.films?[indexPath.row].imageURL
        } else {
            cell.imageURL = talent?.additionalImages?[indexPath.row].thumbnailImageURL
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == galleryCollectionView {
            self.performSegue(withIdentifier: SegueIdentifier.TalentImageGallery, sender: (indexPath as NSIndexPath).row + 1)
        } else if collectionView == filmographyCollectionView {
            if let film = talent?.films?[indexPath.row], let delegate = NextGenHook.delegate {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                delegate.urlForTitle(film.title, completion: { [weak self] (url) in
                    if let strongSelf = self {
                        MBProgressHUD.hideAllHUDs(for: strongSelf.view, animated: true)
                    }
                    
                    url?.promptLaunchBrowser()
                })
                
                NextGenHook.logAnalyticsEvent(currentAnalyticsEvent, action: .selectFilm, itemId: talent.id, itemName: film.title)
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        var width: CGFloat
        if collectionView == filmographyCollectionView {
            width = height * Constants.FilmographyCollectionViewItemAspectRatio
        } else {
            width = height * Constants.GalleryCollectionViewItemAspectRatio
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == filmographyCollectionView {
            return Constants.FilmographyCollectionViewItemSpacing
        }
        
        return Constants.GalleryCollectionViewItemSpacing
    }
    
    // MARK: Storyboard Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.TalentImageGallery, let talentImageGalleryViewController = segue.destination as? TalentImageGalleryViewController {
            talentImageGalleryViewController.talent = talent
            talentImageGalleryViewController.initialPage = (sender as? Int) ?? 0
            NextGenHook.logAnalyticsEvent(currentAnalyticsEvent, action: .selectGallery, itemId: talent.id)
        }
    }

}
