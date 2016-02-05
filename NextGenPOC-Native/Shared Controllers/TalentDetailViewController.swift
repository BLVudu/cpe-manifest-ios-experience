//
//  TalentDetailViewController.swift
//  NextGenPOC-Native
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
    @IBOutlet weak var talentBiographyLabel: UILabel!
    
    @IBOutlet weak var filmographyContainerView: UIView!
    @IBOutlet weak var filmographyCollectionView: UICollectionView!
    
    var talent: Talent? = nil {
        didSet {
            talentNameLabel.text = talent?.name.uppercaseString
            talentRoleLabel.text = talent?.role
            talentImageView.image = talent?.fullImage != nil ? UIImage(named: talent!.fullImage!) : nil
            talentBiographyLabel.text = talent?.biography
            
            if talent != nil && talent!.films.count > 0 {
                filmographyContainerView.hidden = false
                filmographyCollectionView.reloadData()
            } else {
                filmographyContainerView.hidden = true
            }
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filmographyCollectionView.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: Actions
    @IBAction func close() {
        if self.parentViewController is TalentDetailViewPresenter {
            (self.parentViewController as! TalentDetailViewPresenter).talentDetailViewShouldClose()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
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
        let film = (collectionView.cellForItemAtIndexPath(indexPath) as! FilmCollectionViewCell).film
        if film?.externalURL != nil {
            film!.externalURL!.promptLaunchBrowser()
        }
    }

}
