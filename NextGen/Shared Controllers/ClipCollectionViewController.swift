//
//  ClipCollectionViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/28/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ClipCollectionViewController: UICollectionViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.collectionView!.registerNib(UINib(nibName: "ClipCell", bundle: nil), forCellWithReuseIdentifier: "clipCell")
        
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
        
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCellWithReuseIdentifier("clip", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.redColor()
        
        return cell
    }
    
    
    
}
