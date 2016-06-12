//
//  EnhancedTitlesCollectionViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 5/24/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD
import NextGenDataManager
import NextGen

class EnhancedTitlesCollectionViewCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "EnhancedTitlesCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = nil
    }
}

class EnhancedTitlesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let ManifestData = [[
        "title": "Man of Steel",
        "image": "MOS-Onesheet",
        "manifest": "Data/mos_hls_manifest_r60-v0.4",
        "appdata": "Data/mos_appdata_locations_r60-v0.4"
    ], [
        "title": "Sisters",
        "image": "Sisters-Onesheet",
        "manifest": "Data/sisters_hls_manifest_v2-R60-generated-spec1.5"
    ], [
        "title": "Sisters (Unrated)",
        "image": "SistersUnrated-Onesheet",
        "manifest": "Data/sisters_extended_hls_manifest_v3-generated-spec1.5"
    ], [
        "title": "Minions",
        "image": "Minions-Onesheet",
        "manifest": "Data/minions_hls_manifest_v6-R60-generated-spec1.5"
    ]]
    
    private struct Constants {
        static let CollectionViewItemSpacing: CGFloat = 12
        static let CollectionViewLineSpacing: CGFloat = 12
        static let CollectionViewPadding: CGFloat = 15
        static let CollectionViewItemAspectRatio: CGFloat = 135 / 240
    }
    
    override func viewDidLoad() {
        collectionView?.registerNib(UINib(nibName: "EnhancedTitleCell", bundle: nil), forCellWithReuseIdentifier: EnhancedTitlesCollectionViewCell.ReuseIdentifier)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    func loadTitle(titleData: [String: String]) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // Load current Manifest file
        if let manifestXMLPath = NSBundle.mainBundle().pathForResource(titleData["manifest"], ofType: "xml") {
            do {
                try NGDMManifest.sharedInstance.loadManifestXMLFile(manifestXMLPath)
                CurrentManifest.mainExperience = NGDMManifest.sharedInstance.mainExperience
                CurrentManifest.mainExperience.appearance = NGDMAppearance(type: .Main)
                CurrentManifest.inMovieExperience = try CurrentManifest.mainExperience.getInMovieExperience()
                CurrentManifest.inMovieExperience.appearance = NGDMAppearance(type: .InMovie)
                CurrentManifest.outOfMovieExperience = try CurrentManifest.mainExperience.getOutOfMovieExperience()
                CurrentManifest.outOfMovieExperience.appearance = NGDMAppearance(type: .OutOfMovie)
                
                TheTakeAPIUtil.sharedInstance.mediaId = CurrentManifest.mainExperience.customIdentifier(Namespaces.TheTake)
                BaselineAPIUtil.sharedInstance.projectId = CurrentManifest.mainExperience.customIdentifier(Namespaces.Baseline)
                ConfigManager.sharedInstance.loadConfigs()
                CurrentManifest.mainExperience.loadTalent()
            } catch NGDMError.MainExperienceMissing {
                print("Error loading Manifest file: no main Experience found")
                abort()
            } catch NGDMError.InMovieExperienceMissing {
                print("Error loading Manifest file: no in-movie Experience found")
                abort()
            } catch NGDMError.OutOfMovieExperienceMissing {
                print("Error loading Manifest file: no out-of-movie Experience found")
                abort()
            } catch {
                print("Error loading Manifest file: unknown error")
                abort()
            }
        }
        
        // Load current AppData file
        if let appDataXMLPath = NSBundle.mainBundle().pathForResource(titleData["appdata"], ofType: "xml") {
            do {
                CurrentManifest.allAppData = try NGDMManifest.sharedInstance.loadAppDataXMLFile(appDataXMLPath)
            } catch {
                print("Error loading AppData file")
            }
        }
        
        self.performSegueWithIdentifier("FullExperienceSegue", sender: nil)
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ManifestData.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EnhancedTitlesCollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! EnhancedTitlesCollectionViewCell
        cell.titleLabel.text = ManifestData[indexPath.row]["title"]
        if let imageName = ManifestData[indexPath.row]["image"] {
            cell.imageView.image = UIImage(named: imageName)
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        loadTitle(ManifestData[indexPath.row])
    }
    
    // MARK: UICollectionViewFlowLayoutDelegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth: CGFloat = (CGRectGetWidth(collectionView.frame) / 4) - (Constants.CollectionViewItemSpacing * 2)
        return CGSizeMake(itemWidth, itemWidth / Constants.CollectionViewItemAspectRatio)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.CollectionViewLineSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.CollectionViewItemSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding)
    }
    
}
