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
    
    @IBOutlet weak var talentImageView: UIImageView!
    @IBOutlet weak var talentNameLabel: UILabel!
    @IBOutlet weak var talentRoleLabel: UILabel!
    
    @IBOutlet weak var filmographyCollectionView: UICollectionView!
    
    let filmData = [
        [
            "name": "Batman v Superman: Dawn of Justice",
            "imageURL": "http://orig00.deviantart.net/b7c2/f/2014/209/b/f/batman_v_superman_dawn_of_justice___trinity_poster_by_lamboman7-d7sesun.png",
            "externalURL": "http://www.flixster.com/movie/batman-v-superman-dawn-of-justice/"
        ],
        [
            "name": "The Man From U.N.C.L.E.",
            "imageURL": "http://cdn1-www.superherohype.com/assets/uploads/gallery/the-man-from-uncle/manfromuncleposterlarge.jpg",
            "externalURL": "https://video.flixster.com/movies/the-man-from-u-n-c-l-e/urn:dece:cid:eidr-s:AA29-CCC8-B64E-9647-6627-N"
        ],
        [
            "name": "Whatever Works",
            "imageURL": "http://i.jeded.com/i/whatever-works.9213.jpg",
            "externalURL": "https://video.flixster.com/movies/whatever-works/urn:dece:cid:eidr-s:2653-F7B7-1F65-BE16-306C-S"
        ],
        [
            "name": "Stardust",
            "imageURL": "http://goldbergblog.com/movies/posters/stardust.jpg",
            "externalURL": "https://video.flixster.com/movies/stardust/urn:dece:cid:org:ppc:000003475600100003753"
        ]
    ]
    
    var talent: Talent? = nil {
        didSet {
            talentNameLabel.text = talent?.name
            talentRoleLabel.text = talent?.role
            talentImageView.image = talent?.fullImage != nil ? UIImage(named: talent!.fullImage!) : nil
        }
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        return filmData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilmCollectionViewCell", forIndexPath: indexPath) as! FilmCollectionViewCell
        cell.film = Film(info: filmData[indexPath.row])
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
