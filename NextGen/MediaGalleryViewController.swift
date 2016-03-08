//
//  MediaGalleryViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/4/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MWPhotoBrowser

class MediaGalleryViewController: MWPhotoBrowser, MWPhotoBrowserDelegate {
    
    var _photos = [MWPhoto]()
    var imageGallery = [String](){
        didSet {
            _photos.removeAll()
            for pictureLink in imageGallery {
                let url = NSURL(string: pictureLink)
                _photos.append(MWPhoto(URL:url))
            }
            
            self.setCurrentPhotoIndex(0)
            self.reloadData()
        }
        
        
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        self.delegate = self
        self.alwaysShowControls = true
        self.displayActionButton = false
        
        super.viewDidLoad()
                
    }
    
    
    override func setNavBarAppearance(animated: Bool) {
        print(currentIndex)
        // Block MWPhotoBrowser's access to navigation bar
    }
    
    override func updateNavigation() {
        // Block MWPhotoBrowser's access to navigation bar
    }
    
    override func setControlsHidden(hidden: Bool, animated: Bool, permanent: Bool) {
        // Block MWPhotoBrowser's access to status bar
    }
    
    
    // MARK: MWPhotoBrowserDelegate
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(_photos.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        
        return _photos[Int(index)]
        
    }
    
    
    
    
}