//
//  GalleryDetailViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/29/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class GalleryDetailViewController: UIViewController{
    
    
    
    
    func imageGalleryViewController() -> ImageGalleryViewController? {
        for viewController in self.childViewControllers {
            if viewController is ImageGalleryViewController {
                return viewController as? ImageGalleryViewController
            }
        }
        
        return nil
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let experience = NextGenDataManager.sharedInstance.outOfMovieExperienceCategories()[4]
        print(experience.childExperiences()[0].isImageGallery())
        //let thisExperience = experience.childExperiences()[0]
        //let imageGallery = thisExperience.imageGallery()
        //let imageViewController = imageGalleryViewController()
        
        //imageViewController?.imageGallery = imageGallery
        
        
    }
    
    
    
    @IBAction func close(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
