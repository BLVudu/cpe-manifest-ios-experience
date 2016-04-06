//
//  SecondTemplateViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ExtrasVideoGalleryViewController: ExtrasExperienceViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var galleryTableView: UITableView!
    
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var mediaTitleLabel: UILabel!
    @IBOutlet weak var mediaDescriptionLabel: UILabel!
    @IBOutlet weak var mediaRuntimeLabel: UILabel!
    
    private var _willPlayNextItemObserver: NSObjectProtocol!
    
    
    // MARK: Initialization
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(_willPlayNextItemObserver)
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryTableView.registerNib(UINib(nibName: String(VideoCell), bundle: nil), forCellReuseIdentifier: VideoCell.ReuseIdentifier)
        
        self.videoContainerView.hidden = true
        self.mediaTitleLabel.hidden = true
        self.mediaDescriptionLabel.hidden = true
        self.mediaRuntimeLabel.hidden = true
        
        _willPlayNextItemObserver = NSNotificationCenter.defaultCenter().addObserverForName(kWBVideoPlayerWillPlayNextItem, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, index = userInfo["index"] as? Int {
                if index < strongSelf.experience.childExperiences.count {
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    strongSelf.galleryTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
                    strongSelf.tableView(strongSelf.galleryTableView, didSelectRowAtIndexPath: indexPath)
                }
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
        
        self.videoContainerView.hidden = false
        self.mediaTitleLabel.hidden = false
        self.mediaDescriptionLabel.hidden = false
        self.mediaRuntimeLabel.hidden = false

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
            
            videoPlayerViewController.curIndex = Int32(indexPath.row)
            videoPlayerViewController.indexMax = Int32(experience.childExperiences.count)
            videoPlayerViewController.playVideoWithURL(videoURL)
        }
    }
    
   }