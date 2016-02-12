//
//  SceneDetailCollectionViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit
import RFQuiltLayout

enum SceneDetailItemType: Int {
    case Location = 0
    case Trivia
    case Gallery
    case DeletedScene
    case Shop
}

class SceneDetailCollectionViewController: UICollectionViewController, RFQuiltLayoutDelegate {
    
    let cellDetails = [
        ["location.jpg", "Kent family farm", "YORKVILLE, ILLINOIS, USA"],
        ["trivia.jpg", "Kryptonian plasma is left on Earth when the escape pod crashes in the cornfield"],
        ["scene.jpg", "Henry Cavill getting some scene direction"],
        ["deleted_scene.jpg", "Behind the scenes Flying in IL cornfield"],
        ["shop.jpg", "Shop this scene"]
    ]
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.registerNib(UINib(nibName: String(MapSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: MapSceneDetailCollectionViewCell.ReuseIdentifier)
        self.collectionView?.registerNib(UINib(nibName: String(ImageSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: ImageSceneDetailCollectionViewCell.ReuseIdentifier)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        let layout = self.collectionView?.collectionViewLayout as! RFQuiltLayout
        layout.direction = UICollectionViewScrollDirection.Vertical
        layout.blockPixels = CGSizeMake((CGRectGetWidth(self.collectionView!.bounds) / 4), 250)
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var reuseIdentifier = ImageSceneDetailCollectionViewCell.ReuseIdentifier
        if indexPath.row == SceneDetailItemType.Location.rawValue {
            reuseIdentifier = MapSceneDetailCollectionViewCell.ReuseIdentifier
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SceneDetailCollectionViewCell
        switch indexPath.row {
        case SceneDetailItemType.Location.rawValue:
            cell.title = "Scene Location"
            break
            
        case SceneDetailItemType.Trivia.rawValue:
            cell.title = "Scene Trivia"
            break
            
        case SceneDetailItemType.Gallery.rawValue:
            cell.title = "Scene Gallery"
            break
            
        case SceneDetailItemType.DeletedScene.rawValue:
            cell.title = "Deleted Scene"
            break
            
        case SceneDetailItemType.Shop.rawValue:
            cell.title = "Shop This Scene"
            break
            
        default:
            cell.title = nil
            break
        }
        
        cell.imageView.image = UIImage(named: cellDetails[indexPath.row][0])
        cell.descriptionLabel.text = cellDetails[indexPath.row][1]
        
        return cell
    }
    
    // MARK: RFQuiltLayoutDelegate
    func blockSizeForItemAtIndexPath(indexPath: NSIndexPath!) -> CGSize {
        switch indexPath.row {
        case SceneDetailItemType.Shop.rawValue:
            return CGSizeMake(4, 1)
            
        default:
            return CGSizeMake(2, 1)
        }
    }
    
    func insetsForItemAtIndexPath(indexPath: NSIndexPath!) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }

}
