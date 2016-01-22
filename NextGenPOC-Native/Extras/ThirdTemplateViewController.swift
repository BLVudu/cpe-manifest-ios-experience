//
//  ThirdTemplateViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ThirdTemplateViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var thirdView: UICollectionView!
    let extraImages = ["extras_bts.jpg","extras_galleries.jpg","extras_krypton.jpg","extras_legacy.jpg","extras_places.jpg","extras_scenes.jpg","extras_shopping.jpg","extras_universe.jpg"]
    let extrasCaption =  ["Behind The Scenes","Galleries","Explore Krypton","Legacy","Places","Scenes","Shopping", "DC Universe"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.thirdView.dataSource = self
        self.thirdView.delegate = self
        
        self.thirdView.registerNib(UINib(nibName: "ContentCell", bundle: nil), forCellWithReuseIdentifier: "content")
        
        if let layout = thirdView?.collectionViewLayout as? ThirdTemplateLayout {
            layout.delegate = self
        }
        
        
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return self.extraImages.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("content", forIndexPath: indexPath)as! ContentCell
        
        cell.extraImg.image = UIImage (named: self.extraImages[indexPath.row])
        cell.extrasTitle.text = self.extrasCaption[indexPath.row]
        
        return cell
    }
}


extension ThirdTemplateViewController: ThirdTemplateLayoutDelegate{
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath,
        withWidth width: CGFloat) -> CGFloat {
            
            
            return 250
            
    }
}

