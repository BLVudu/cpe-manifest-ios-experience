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
    
    @IBOutlet weak var talentTypeLabel: UILabel!
    @IBOutlet weak var talentImageView: UIImageView!
    @IBOutlet weak var talentNameLabel: UILabel!
    @IBOutlet weak var talentRoleLabel: UILabel!
    @IBOutlet weak var talentBiographyHeaderLabel: UILabel!
    @IBOutlet weak var talentBiographyLabel: UITextView!
    
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var filmographyContainerView: UIView!
    @IBOutlet weak var filmographyCollectionView: UICollectionView!
    
    @IBOutlet weak var showGallery: UIButton!
    @IBOutlet weak var twProfile: SocialButton!
    @IBOutlet weak var fbProfile: SocialButton!
    var images = [String]()
    var talent: Talent? = nil {
        didSet {
            talentNameLabel.text = talent?.name.uppercaseString
            talentRoleLabel.text = talent?.role
            if let imageURL = talent?.fullImageURL {
                talentImageView.setImageWithURL(imageURL)
            } else {
                talentImageView.image = nil
            }
            
            talentBiographyLabel.text = talent?.biography
            fbProfile.profileFB = talent?.facebook
            fbProfile.profileFBID = talent?.facebookID
            twProfile.profileTW = talent?.twitter
            if talent != nil && talent!.films.count > 0 {
                filmographyContainerView.hidden = false
                filmographyCollectionView.reloadData()
               

            } else {
                filmographyContainerView.hidden = true
            }
            
            if talent != nil && talent?.gallery.count > 0{
                images = (talent?.gallery)!
            } else {
                self.showGallery.userInteractionEnabled = false
            }
        }
    }
    
    // MARK: View Lifecycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.performSelector(("showIndicators"), withObject: nil, afterDelay: 0.0)
       
        

    }
    
    func showIndicators(){
            filmographyCollectionView.flashScrollIndicators()
            talentBiographyLabel.flashScrollIndicators()
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filmographyCollectionView.backgroundColor = UIColor.clearColor()
        filmographyCollectionView.showsHorizontalScrollIndicator = true
        self.twProfile.backgroundColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1.0)
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
        
               
        self.performSegueWithIdentifier("showActorGallery", sender: nil)
       
    }
    @IBAction func loadTwitter(sender: SocialButton) {
        
        
        sender.loadProfile("TW")
    }
    
    
    @IBAction func loadFacebook(sender: SocialButton) {
        
        sender.loadProfile("FB")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         if segue.identifier == "showActorGallery"{
            
            let actorGalleryVC = segue.destinationViewController as! ActorGalleryViewController
            
            actorGalleryVC.images = (talent?.gallery)!
        }
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if talent != nil {
            return talent!.films.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilmCollectionViewCell", forIndexPath: indexPath) as! FilmCollectionViewCell
        cell.film = talent?.films[indexPath.row]
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //let film = (collectionView.cellForItemAtIndexPath(indexPath) as! FilmCollectionViewCell).film
        //if film?.externalURL != nil {
        //    film!.externalURL!.promptLaunchBrowser()
        //}
    }

}
