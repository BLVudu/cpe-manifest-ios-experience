//
//  SecondTemplateViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import Social
import MWPhotoBrowser



class ExtrasContentViewController: StylizedViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    
    @IBOutlet weak var mediaTitleLabel: UILabel!
    @IBOutlet weak var mediaDescriptionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    
    var experience: NGEExperienceType!
    
    var share: NSURL!

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setBackButton(self, action: "close")
        
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: VideoCell.ReuseIdentifier)
        
        let selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        self.tableView(self.tableView, didSelectRowAtIndexPath: selectedIndexPath)
        
        //let defaults = NSUserDefaults.standardUserDefaults()
        //print(defaults.objectForKey("currentIndex"))

            }
    
    func videoPlayerViewController() -> VideoPlayerViewController? {
        for viewController in self.childViewControllers {
            if viewController is VideoPlayerViewController {
                return viewController as? VideoPlayerViewController
            }
        }
        
        return nil
    }
    
    func imageGalleryViewController() -> ImageGalleryViewController? {
        for viewController in self.childViewControllers {
            if viewController is ImageGalleryViewController {
                return viewController as? ImageGalleryViewController
            }
        }
        
        return nil
    }
    
    
    // MARK: Actions
    func close() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(VideoCell.ReuseIdentifier, forIndexPath: indexPath) as! VideoCell
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        
        let thisExperience = experience.childExperiences()[indexPath.row]
        cell.caption.text = thisExperience.metadata()?.fullTitle()
        if let thumbnailPath = thisExperience.thumbnailImagePath() {
            cell.thumbnail.setImageWithURL(NSURL(string: thumbnailPath)!)
        } else {
            cell.thumbnail.image = nil
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experience.childExperiences().count
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        
        let title = UILabel(frame: CGRectMake(10, 10, tableView.frame.size.width, 40))
        title.text = experience.metadata()?.fullTitle()
        title.textColor = UIColor.whiteColor()
        title.font = UIFont(name: "Helvetica", size: 25.0)
        headerView.addSubview(title)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if !cell.selected {
                return indexPath
            }
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thisExperience = experience.childExperiences()[indexPath.row]
        
        mediaTitleLabel.text = thisExperience.metadata()?.fullTitle()
        mediaDescriptionLabel.text = thisExperience.metadata()?.fullSummary()
        
        if thisExperience.isVideoGallery() {
            videoContainerView.hidden = false
            imageContainerView.hidden = true
            
            if let videoURL = thisExperience.videoURL(), videoPlayerViewController = videoPlayerViewController() {
                if let player = videoPlayerViewController.player {
                    player.removeAllItems()
                }
                
                videoPlayerViewController.playerControlsVisible = false
                videoPlayerViewController.lockTopToolbar = true
                videoPlayerViewController.playVideoWithURL(videoURL)
                self.share = videoURL
            }
        } else {
            videoContainerView.hidden = true
            imageContainerView.hidden = false
            
            if let imageGallery = thisExperience.imageGallery(), imageGalleryViewController = imageGalleryViewController() {
                
                imageGalleryViewController.imageGallery = imageGallery
                
                self.share = imageGallery.pictures()[0].imageURL()
                if let title = imageGallery.metadata()?.fullTitle() {
                    mediaTitleLabel.text = title
                }
                
                if let description = imageGallery.metadata()?.fullSummary() {
                    mediaDescriptionLabel.text = description
                }

            }
        }
    }
    
    
    @IBAction func shareToFacebook(sender: UIButton) {
       
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let fb:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fb.completionHandler = {
                result -> Void in
                let getResult = result as SLComposeViewControllerResult;
                switch(getResult.rawValue)
                {
                case SLComposeViewControllerResult.Done.rawValue:
                    let success = UIAlertView(title: "Success", message: "Your content has been shared!", delegate: nil, cancelButtonTitle: "OK")
                        success.show()
                default: break
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            fb.setInitialText("Man of Steel")
            fb.addURL(self.share)
            self.presentViewController(fb, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Not logged in", message: "Please login to Facebook via Settings.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func shareToTwitter(sender: UIButton) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let tw:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tw.completionHandler = {
                result -> Void in
                let getResult = result as SLComposeViewControllerResult;
                switch(getResult.rawValue)
                {
                case SLComposeViewControllerResult.Done.rawValue:
                    let success = UIAlertView(title: "Success", message: "Your content has been shared!", delegate: nil, cancelButtonTitle: "OK")
                    success.show()
                default: break
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            tw.setInitialText("Man of Steel")
            tw.addURL(self.share)
            self.presentViewController(tw, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Not logged in", message: "Please login to Twitter via Settings.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    /*
    @IBAction func saveBookmark(sender: AnyObject) {
        
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        

        let entity =  NSEntityDescription.entityForName("Bookmark",
            inManagedObjectContext:managedContext)
        
        let bookmark = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        bookmark.setValue(self.imageCaption.text, forKey: "caption")
        bookmark.setValue(self.imgData, forKey: "thumbnail")
        bookmark.setValue("image", forKey: "mediaType")

        do {
            try managedContext.save()

        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
*/
    
}






