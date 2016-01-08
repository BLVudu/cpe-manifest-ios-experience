//
//  ExtrasViewController.swift
//  NextGenPOC-Native
//
//  Created by Sedinam Gadzekpo on 1/8/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit


class ExtrasViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    @IBOutlet weak var actorsView: UIImageView!
    @IBOutlet weak var extrasView: UICollectionView!
    let extraImages = ["extras_bts.jpg","extras_galleries.jpg","extras_kyrpton.jpg","extras_legacy.jpg","extras_places.jpg","extras_scenes.jpg","extras_shopping.jpg","extras_universe.jpg"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        self.extrasView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "extrasItem")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
      return self.extraImages.count
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("extrasItem", forIndexPath: indexPath)as UICollectionViewCell
        
        return cell
        
        
        
    }
    
}