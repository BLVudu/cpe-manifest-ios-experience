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


    let regionRadius: CLLocationDistance = 2000
    var initialLocation = CLLocation(latitude: 0, longitude: 0)
    var locName = ""
    var locImg = ""
    var currentScene: Scene?
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.registerNib(UINib(nibName: String(MapSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: MapSceneDetailCollectionViewCell.ReuseIdentifier)
        self.collectionView?.registerNib(UINib(nibName: String(ImageSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: ImageSceneDetailCollectionViewCell.ReuseIdentifier)
        
        if let allScenes = DataManager.sharedInstance.content?.scenes {
            currentScene = allScenes[0]
        }
        
        let layout = self.collectionView?.collectionViewLayout as! RFQuiltLayout
        layout.direction = UICollectionViewScrollDirection.Vertical
        layout.blockPixels = CGSizeMake((CGRectGetWidth(self.collectionView!.bounds) / 8), 250)
        print(self.collectionView!.bounds)

        
        NSNotificationCenter.defaultCenter().addObserverForName(kSceneDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            if let userInfo = notification.userInfo {
                self.currentScene = userInfo["scene"] as? Scene
                self.initialLocation = CLLocation(latitude: (self.currentScene?.latitude)!, longitude: (self.currentScene?.longitude)!)
                self.locName = (self.currentScene?.locationName)!
                self.locImg = (self.currentScene?.locationImage)!
                self.collectionView?.reloadData()
            }
        }
    }
    
   /*
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        let layout = self.collectionView?.collectionViewLayout as! RFQuiltLayout
        layout.direction = UICollectionViewScrollDirection.Vertical
        layout.blockPixels = CGSizeMake((CGRectGetWidth(self.collectionView!.bounds) / 4), 250)
        print(self.collectionView!.bounds)
    }
*/
    
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
                cell.centerMapOnLocation(initialLocation, region: regionRadius)
                cell.imageView.image = UIImage(named: self.locImg)
                cell.descriptionLabel.text = self.locName
                break
                
            case SceneDetailItemType.Trivia.rawValue:
                cell.title = "Scene Trivia"
                cell.imageView.image = UIImage(named: cellDetails[indexPath.row][0])
                cell.descriptionLabel.text = cellDetails[indexPath.row][1]

                break
                
            case SceneDetailItemType.Gallery.rawValue:
                cell.title = "Scene Gallery"
                cell.imageView.image = UIImage(named: cellDetails[indexPath.row][0])
                cell.descriptionLabel.text = cellDetails[indexPath.row][1]

                break
                
            case SceneDetailItemType.DeletedScene.rawValue:
                cell.title = "Deleted Scene"
                cell.imageView.image = UIImage(named: cellDetails[indexPath.row][0])
                cell.descriptionLabel.text = cellDetails[indexPath.row][1]

                break
                
            case SceneDetailItemType.Shop.rawValue:
                cell.title = "Shop This Scene"
                cell.imageView.image = UIImage(named: cellDetails[indexPath.row][0])
                cell.descriptionLabel.text = cellDetails[indexPath.row][1]

                break
                
            default:
                cell.title = nil
                break
            }
            
            //cell.imageView.image = UIImage(named: cellDetails[indexPath.row][0])
            //cell.descriptionLabel.text = cellDetails[indexPath.row][1]
            
            return cell
        }

    
    
     override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        switch indexPath.row {
            
        case SceneDetailItemType.Location.rawValue:
        self.performSegueWithIdentifier("showMap", sender: nil)
            break
            
        case SceneDetailItemType.Gallery.rawValue:
        self.performSegueWithIdentifier("showGallery", sender: nil)
            break
            
        default:
            break
        }
        
            

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showMap"{
        
        let coordinates = segue.destinationViewController as! MapDetailViewController
        
            coordinates.initialLocation = self.initialLocation
            coordinates.locationName = self.locName
            
    }

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
