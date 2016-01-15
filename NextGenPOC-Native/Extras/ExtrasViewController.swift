//
//  ExtrasViewController.swift
//  NextGenPOC-Native
//
//  Created by Sedinam Gadzekpo on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//


import UIKit
import AVFoundation

class ExtrasCell: UICollectionViewCell {
    
    @IBOutlet var extraImg: UIImageView!
    
    @IBOutlet weak var extrasTitle: UILabel!
}

class ExtrasViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, TalentDetailViewPresenter {
    
    var isPresented = true
    
    
    @IBOutlet var extrasView: UICollectionView!
    @IBOutlet weak var talentDetailView: UIView!
    @IBOutlet weak var talentTableView: TalentTableView!
    
    var selectedIndexPath: NSIndexPath?
    
    let extraImages = ["extras_bts.jpg","extras_galleries.jpg","extras_krypton.jpg","extras_legacy.jpg","extras_places.jpg","extras_scenes.jpg","extras_shopping.jpg","extras_universe.jpg"]
    let extrasCaption =  ["Behind The Scenes","Galleries","Explore Krypton","Legacy","Places","Scenes","Shopping", "DC Universe"]
    
    var talentData = [
        [
            "thumbnailImage": "cavill_thumb.jpg",
            "fullImage": "cavill_full.jpg",
            "name": "Henry Cavill",
            "role": "Clark Kent/Kal-El"
        ],
        [
            "thumbnailImage": "adams.jpg",
            "fullImage": "adams.jpg",
            "name": "Amy Adams",
            "role": "Lois Lane"
        ],
        [
            "thumbnailImage": "shannon_thumb.jpg",
            "fullImage": "shannon_full.jpg",
            "name": "Michael Shannon",
            "role": "General Zod"
        ],
        [
            "thumbnailImage": "lane_thumb.jpg",
            "fullImage": "lane_full.jpg",
            "name": "Diane Lane",
            "role": "Martha Kent"
        ],
        [
            "thumbnailImage": "crowe_thumb.jpg",
            "fullImage": "crowe_full.jpg",
            "name": "Russell Crowe",
            "role": "Jor-El"
        ],
        [
            "thumbnailImage": "traue_thumb.jpg",
            "fullImage": "traue_full.jpg",
            "name": "Antje Traue",
            "role": "Faora-Ul"
        ],
        [
            "thumbnailImage": "lennix_thumb.jpg",
            "fullImage": "lennix_full.jpg",
            "name": "Harry Lennix",
            "role": "General Swanwick"
        ],
        [
            "thumbnailImage": "schiff_thumb.jpg",
            "fullImage": "schiff_full.jpg",
            "name": "Richard Schiff",
            "role": "Dr. Emil Hamilton"
        ],
        [
            "thumbnailImage": "meloni_thumb.jpg",
            "fullImage": "meloni_full.jpg",
            "name": "Christopher Meloni",
            "role": "Colonel Nathan Hardy"
        ],
        [
            "thumbnailImage": "costner_thumb.jpg",
            "fullImage": "costner_full.jpg",
            "name": "Kevin Costner",
            "role": "Jonathan Kent"
        ],
        [
            "thumbnailImage": "zurer_thumb.jpg",
            "fullImage": "zurer_full.jpg",
            "name": "Ayelet Zurer",
            "role": "Lara Lor-Van"
        ],
        [
            "thumbnailImage": "fishburne_thumb.jpg",
            "fullImage": "fishburne_full.jpg",
            "name": "Laurence Fishburne",
            "role": "Perry White"
        ]
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extrasView.delegate = self
        self.extrasView.dataSource = self
        
        self.talentTableView.registerNib(UINib(nibName: "TalentTableViewCell", bundle: nil), forCellReuseIdentifier: "TalentTableViewCell")
        
        if let layout = extrasView?.collectionViewLayout as? ExtrasLayout {
            layout.delegate = self
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func talentDetailViewController() -> TalentDetailViewController? {
        for viewController in self.childViewControllers {
            if viewController is TalentDetailViewController {
                return viewController as? TalentDetailViewController
            }
        }
        
        return nil
    }
    
    func showTalentDetailView() {
        if talentDetailView.hidden {
            talentDetailView.alpha = 0
            talentDetailView.hidden = false
            
            UIView.animateWithDuration(0.25, animations: {
                self.talentDetailView.alpha = 1
            }, completion: { (Bool) -> Void in
                    
            })
        }
    }
    
    func hideTalentDetailView() {
        if selectedIndexPath != nil {
            talentTableView.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
            selectedIndexPath = nil
        }
        
        UIView.animateWithDuration(0.25, animations: {
            self.talentDetailView.alpha = 0
        }, completion: { (Bool) -> Void in
                self.talentDetailView.hidden = true
        })
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
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talentData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCellIdentifier) as! TalentTableViewCell
        cell.talent = Talent(info: talentData[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ACTORS"
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath == selectedIndexPath {
            hideTalentDetailView()
            return nil
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        talentDetailViewController()?.talent = (tableView.cellForRowAtIndexPath(indexPath) as! TalentTableViewCell).talent
        showTalentDetailView()
    }
    
    // MARK: TalentDetailViewPresenter
    func talentDetailViewShouldClose() {
        hideTalentDetailView()
    }
    
}

extension ExtrasViewController: ExtrasLayoutDelegate{
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath,
        withWidth width: CGFloat) -> CGFloat {
            
            return 250.0
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
