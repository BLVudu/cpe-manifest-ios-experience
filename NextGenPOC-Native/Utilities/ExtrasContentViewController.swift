//
//  ExtrasContentViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/20/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ExtrasContentCell: UICollectionViewCell{
    
    @IBOutlet weak var extCont: UIImageView!
}
    

    
       


class ExtrasContentViewController: UICollectionViewController{
    
    let reuseIdentifier = "Cell"

    
    let extraImages = ["extras_bts.jpg","extras_galleries.jpg","extras_krypton.jpg","extras_legacy.jpg","extras_places.jpg","extras_scenes.jpg","extras_shopping.jpg","extras_universe.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = self.collectionView?.collectionViewLayout as? ContentLayout {
            layout.delegate = self
            
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
       
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.extraImages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ExtrasContentCell
        
        cell.extCont.image = UIImage(named: self.extraImages[indexPath.row])

        
        return cell
    }
    
}
    extension ExtrasContentViewController: ContentLayoutDelegate{
        
        func collectionView(collectionView:UICollectionView, widthForPhotoAtIndexPath indexPath: NSIndexPath,
            withHeight width: CGFloat) -> CGFloat {
                
                print(self.collectionView?.frame.width)
                
                
                return 950
        }
    
    
}

