//
//  EnhancedTitlesCollectionViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 5/24/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class EnhancedTitlesCollectionViewCell: UICollectionViewCell{
    
    static let ReuseIdentifier = "EnhancedTitlesCollectionViewCellReuseIdentifier"
    
    
    
    
    @IBOutlet weak var movieTitle: UILabel!
    
}


class EnhancedTitlesCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var titlesCollectionView: UICollectionView!
    var manifestXMLPath: String!
    override func viewDidLoad() {
        titlesCollectionView.registerNib(UINib(nibName: "EnhancedTitleCell", bundle: nil), forCellWithReuseIdentifier: EnhancedTitlesCollectionViewCell.ReuseIdentifier)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
         let cell = titlesCollectionView.dequeueReusableCellWithReuseIdentifier(EnhancedTitlesCollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! EnhancedTitlesCollectionViewCell
        switch indexPath.row {
        case 0:
            cell.movieTitle.text = "Sisters"
            break
        case 1:
            cell.movieTitle.text = "Minions"
            break
        case 2:
            cell.movieTitle.text = "Man Of Steel"
            break
        default:
            cell.movieTitle.text = "Man Of Steel"
        }
        return cell
    
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            manifestXMLPath = NSBundle.mainBundle().pathForResource("Data/sisters_hls_manifest_v2-R60-generated-spec1.5", ofType: "xml")
            break
        case 1:
            manifestXMLPath = NSBundle.mainBundle().pathForResource("Data/minions_hls_manifest_v6-R60-generated-spec1.5", ofType: "xml")
            break
        case 2:
            manifestXMLPath = NSBundle.mainBundle().pathForResource("Data/mos_hls_manifest_r60-v0.4", ofType: "xml")
            break
        default:
            manifestXMLPath = NSBundle.mainBundle().pathForResource("Data/mos_hls_manifest_r60-v0.4", ofType: "xml")
        }
     
        loadExperience()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((CGRectGetWidth(collectionView.frame) / 3), CGRectGetHeight(collectionView.frame))
    }
    
    func loadExperience(){
        
            do {
                try NextGenDataManager.sharedInstance.loadManifestXMLFile(manifestXMLPath)
                CurrentManifest.mainExperience = NextGenDataManager.sharedInstance.mainExperience
                CurrentManifest.mainExperience.appearance = NGDMAppearance(type: .Main)
                CurrentManifest.inMovieExperience = try CurrentManifest.mainExperience.getInMovieExperience()
                CurrentManifest.inMovieExperience.appearance = NGDMAppearance(type: .InMovie)
                CurrentManifest.outOfMovieExperience = try CurrentManifest.mainExperience.getOutOfMovieExperience()
                CurrentManifest.outOfMovieExperience.appearance = NGDMAppearance(type: .OutOfMovie)
                
                TheTakeAPIUtil.sharedInstance.mediaId = CurrentManifest.mainExperience.customIdentifier(kTheTakeIdentifierNamespace)
                BaselineAPIUtil.sharedInstance.projectId = CurrentManifest.mainExperience.customIdentifier(kBaselineIdentifierNamespace)
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
        
        
        // Load current AppData file
        if let appDataXMLPath = NSBundle.mainBundle().pathForResource("Data/mos_appdata_locations_r60-v0.4", ofType: "xml") {
            do {
                CurrentManifest.allAppData = try NextGenDataManager.sharedInstance.loadAppDataXMLFile(appDataXMLPath)
            } catch {
                print("Error loading AppData file")
            }
        }
        
        self.performSegueWithIdentifier("FullExperienceSegue", sender: nil)
        
    }

    
    
    
    
}
