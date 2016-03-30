//
//  ExtrasImageGalleryListCollectionViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 3/19/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ExtrasImageGalleryListCollectionViewController: StylizedCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let kExtrasImageGallerySegueIdentifier = "ExtrasImageGallerySegueIdentifier"
    
    var experience: NGDMExperience!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.registerNib(UINib(nibName: TitledImageCell.NibName, bundle: nil), forCellWithReuseIdentifier: TitledImageCell.ReuseIdentifier)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return experience.childExperiences.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TitledImageCell.ReuseIdentifier, forIndexPath: indexPath) as! TitledImageCell
        cell.experience = experience.childExperiences[indexPath.row]
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TitledImageCell {
            self.performSegueWithIdentifier(kExtrasImageGallerySegueIdentifier, sender: cell.experience)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 15, 15, 15)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(CGRectGetWidth(collectionView.frame) / 3 - 20, 225)
    }
    
    // MARK: Storyboard
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kExtrasImageGallerySegueIdentifier {
            if let imageGalleryViewController = segue.destinationViewController as? ExtrasImageGalleryViewController, experience = sender as? NGDMExperience, gallery = experience.galleries.values.first  {
                imageGalleryViewController.gallery = gallery
            }
        }
    }

}
