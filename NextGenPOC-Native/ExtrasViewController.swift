//
//  ExtrasViewController.swift
//  NextGenPOC-Native
//
//  Created by Sedinam Gadzekpo on 1/8/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//


import UIKit
import AVFoundation

class ExtrasCell: UICollectionViewCell {
    
    @IBOutlet var extraImg: UIImageView!
    
    @IBOutlet weak var extrasTitle: UILabel!
}


class ActorsCell: UITableViewCell {
    
    @IBOutlet var actorImg: UIImageView!
    @IBOutlet var actorName: UILabel!
    @IBOutlet var actorCharacter: UILabel!
    
    override func layoutSubviews() {
        actorImg.layer.cornerRadius = actorImg.bounds.height / 2
        actorImg.clipsToBounds = true
    }
    
    
}


class ExtrasViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UITableViewDelegate, UITableViewDataSource{
    
    var isPresented = true
    
    
    @IBOutlet var extrasView: UICollectionView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var actorsView: UITableView!
    
    let extraImages = ["extras_bts.jpg","extras_galleries.jpg","extras_krypton.jpg","extras_legacy.jpg","extras_places.jpg","extras_scenes.jpg","extras_shopping.jpg","extras_universe.jpg"]
    let extrasCaption =  ["Behind The Scenes","Galleries","Explore Krypton","Legacy","Places","Scenes","Shopping", "DC Universe"]
    
    let actorImgs = ["henry.jpg","adams.jpg","micheal.jpg","russell.jpg","diane.jpg","kevin.jpg"]
    
    let actorNames = ["Henry Cavill","Amy Adams","Micheal Shannon","Russell Crowe","Diane Lane","Kevin Costner"]
    
    let actorCharacters = ["ClarkKent/Kal-El","Lois Lane","General Zod","Jor-El","Martha Kent","Jonathan Kent"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.extrasView.delegate = self
        self.extrasView.dataSource = self
        
        let nib = UINib(nibName: "ActorsCell", bundle: nil)
        
        self.actorsView.delegate = self
        self.actorsView.registerNib(nib, forCellReuseIdentifier: "actors")
        self.actorsView.backgroundColor = UIColor(patternImage: UIImage(named: "menu_bg.jpg")!)
        
        
        if let layout = extrasView?.collectionViewLayout as? ExtrasLayout {
            layout.delegate = self
        }
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return self.extraImages.count
    }
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("extrasItem", forIndexPath: indexPath)as! ExtrasCell
        
        cell.extraImg.image = UIImage (named: self.extraImages[indexPath.row])
        cell.extrasTitle.text = self.extrasCaption[indexPath.row]
        
        
        
        return cell
        
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actorCharacters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:ActorsCell = self.actorsView.dequeueReusableCellWithIdentifier("actors") as! ActorsCell
        
        

        
        cell.actorImg.image = UIImage(named: self.actorImgs[indexPath.row])
        cell.actorName.text = self.actorNames[indexPath.row]
        cell.actorCharacter.text = self.actorCharacters[indexPath.row]
        
        
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "menu_bg.jpg")!)

        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200.0
    }
    
}

extension ExtrasViewController: ExtrasLayoutDelegate{
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath,
        withWidth width: CGFloat) -> CGFloat {
            
            return 500.0
    }
    
    func collectionView(collectionView: UICollectionView,
    heightForLabelAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
    {
        return 100.0
    }
    
    
    @IBAction func dismissExtras(sender: AnyObject) {
        
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil);
        
    }
    
}
