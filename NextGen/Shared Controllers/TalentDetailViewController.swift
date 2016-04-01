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

class TalentDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    struct StoryboardSegue {
        static let ShowActorGallery = "showActorGallery"
    }
    
    @IBOutlet weak var talentImageView: UIImageView!
    @IBOutlet weak var talentNameLabel: UILabel!
    @IBOutlet weak var talentBiographyHeaderLabel: UILabel!
    @IBOutlet weak var talentBiographyLabel: UITextView!
    
    @IBOutlet weak var filmographyContainerView: UIView!
    @IBOutlet weak var filmographyCollectionView: UICollectionView!
    
    @IBOutlet weak var showGallery: UIButton!
    @IBOutlet weak var twitterButton: SocialButton!
    @IBOutlet weak var facebookButton: SocialButton!
    
    var images = [String]()
    var talent: Talent? = nil {
        didSet {
            talentNameLabel.text = talent?.name?.uppercaseString
            if let imageURL = talent?.fullImageURL {
                talentImageView.setImageWithURL(imageURL)
            } else {
                talentImageView.image = nil
            }
            
            talent?.getBiography({ (biography) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.talentBiographyLabel.text = biography
                })
            })
            
            facebookButton.hidden = true
            twitterButton.hidden = true
            talent?.getSocialAccounts({ (socialAccounts) in
                dispatch_async(dispatch_get_main_queue(), {
                    if let socialAccounts = socialAccounts {
                        for socialAccount in socialAccounts {
                            if socialAccount.type == SocialAccountType.Facebook {
                                self.facebookButton.hidden = false
                                self.facebookButton.socialAccount = socialAccount
                            } else if socialAccount.type == SocialAccountType.Twitter {
                                self.twitterButton.hidden = false
                                self.twitterButton.socialAccount = socialAccount
                            }
                        }
                    }
                })
            })
            
            filmographyContainerView.hidden = true
            talent?.getFilmography({ (films) in
                dispatch_async(dispatch_get_main_queue(), {
                    if films.count > 0 {
                        self.filmographyContainerView.hidden = false
                        self.filmographyCollectionView.reloadData()
                    } else {
                        self.filmographyContainerView.hidden = true
                    }
                })
            })
            
            if talent != nil && talent?.gallery.count > 0{
                images = (talent?.gallery)!
            } else {
                showGallery.userInteractionEnabled = false
            }
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filmographyCollectionView.backgroundColor = UIColor.clearColor()
        filmographyCollectionView.showsHorizontalScrollIndicator = true
        self.showGallery.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    // MARK: Actions
    @IBAction func close() {
        if self.parentViewController is TalentDetailViewPresenter {
            (self.parentViewController as! TalentDetailViewPresenter).talentDetailViewShouldClose()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func displayGallery(sender: AnyObject) {
        self.performSegueWithIdentifier(StoryboardSegue.ShowActorGallery, sender: nil)
    }
    
    @IBAction func openSocialURL(sender: SocialButton) {
        sender.openURL()
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let films = talent?.films {
            return films.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FilmCollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! FilmCollectionViewCell
        if let films = talent?.films {
            cell.film = films[indexPath.row]
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //let film = (collectionView.cellForItemAtIndexPath(indexPath) as! FilmCollectionViewCell).film
        //if film?.externalURL != nil {
        //    film!.externalURL!.promptLaunchBrowser()
        //}
    }
    
    // MARK: Storyboard Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardSegue.ShowActorGallery {
            if let actorGalleryVC = segue.destinationViewController as? ActorGalleryViewController {
                actorGalleryVC.images = (talent?.gallery)!
            }
        }
    }

}
