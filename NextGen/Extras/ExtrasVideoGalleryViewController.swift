//
//  SecondTemplateViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ExtrasVideoGalleryViewController: StylizedViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var galleryTableView: UITableView!
    
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var mediaTitleLabel: UILabel!
    @IBOutlet weak var mediaDescriptionLabel: UILabel!
    @IBOutlet weak var mediaRuntimeLabel: UILabel!
    
    var experience: NGDMExperience!

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setBackButton(self, action: "close")
        
        galleryTableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: VideoCell.ReuseIdentifier)
        
        let selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        galleryTableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        tableView(galleryTableView, didSelectRowAtIndexPath: selectedIndexPath)

        NSNotificationCenter.defaultCenter().addObserverForName("fullScreen", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            if let userInfo = notification.userInfo {
                if userInfo["toggleFS"] as! Bool {
                    UIView.animateWithDuration(0.25, animations: {
                        self.videoContainerView.frame = self.view.frame
                    }, completion: nil)
                } else {
                    UIView.animateWithDuration(0.25, animations: {
                        
                    }, completion: nil)
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("playNextItem", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            
            if let userInfo = notification.userInfo{
                let index = userInfo["index"]as! Int
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                self.galleryTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
                self.tableView(self.galleryTableView, didSelectRowAtIndexPath: indexPath)
                
                
            }
            
            
        }

    }
    
    func videoPlayerViewController() -> VideoPlayerViewController? {
        for viewController in self.childViewControllers {
            if viewController is VideoPlayerViewController {
                return viewController as? VideoPlayerViewController
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
        cell.experience = experience.childExperiences[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experience.childExperiences.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
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
        let thisExperience = experience.childExperiences[indexPath.row]
        
        mediaTitleLabel.text = thisExperience.metadata?.title
        mediaDescriptionLabel.text = thisExperience.metadata?.description
        let runtime = thisExperience.videoRuntime
        if runtime > 0 {
            mediaRuntimeLabel.hidden = false
            mediaRuntimeLabel.text = "Runtime: " + runtime.timeString()
        } else {
            mediaRuntimeLabel.hidden = true
        }
        
        if let videoURL = thisExperience.videoURL, videoPlayerViewController = videoPlayerViewController() {
            if let player = videoPlayerViewController.player {
                player.removeAllItems()
            }
            videoPlayerViewController.indexMax = Int32(experience.childExperiences.count)
            videoPlayerViewController.isExtras = true
            videoPlayerViewController.playerControlsVisible = false
            videoPlayerViewController.lockTopToolbar = true
            videoPlayerViewController.playVideoWithURL(videoURL)
        }
    }
    
}