//
//  ImageGalleryViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 2/11/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MWPhotoBrowser

class ImageGalleryViewController: MWPhotoBrowser, MWPhotoBrowserDelegate {
    
    private var _photos = [MWPhoto]()
    var gallery: NGDMGallery? {
        didSet {
            _photos.removeAll()
            
            if let gallery = gallery, pictures = gallery.pictures {
                for picture in pictures {
                    _photos.append(MWPhoto(URL: picture.imageURL))
                }
            }
            
            self.setCurrentPhotoIndex(0)
            self.reloadData()
        }
    }
    
    var audioVisual: NGDMAudioVisual? {
        didSet {
            _photos.removeAll()
            
            if let audioVisual = audioVisual, presentation = audioVisual.presentation {
                var video: MWPhoto!
                if let imageURL = audioVisual.imageURL {
                    video = MWPhoto(URL: imageURL)
                } else {
                    video = MWPhoto()
                }
                
                if let videoURL = presentation.videoURL {
                    video.videoURL = videoURL
                }
                
                _photos.append(video)
                //self.autoPlayOnAppear = true
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
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, didDisplayPhotoAtIndex index: UInt) {
        NSNotificationCenter.defaultCenter().postNotificationName("updateControl", object: nil, userInfo: ["index": self.currentIndex])
    }
    
}
