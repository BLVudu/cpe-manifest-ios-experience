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


class ExtrasContentViewController: StylizedViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoDescriptionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    
    var experience: NGEExperienceType!
    
    //var bookmarks = [NSManagedObject]()

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setBackButton(self, action: "close")
        
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: VideoCell.ReuseIdentifier)
        
        let selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        self.tableView(self.tableView, didSelectRowAtIndexPath: selectedIndexPath)
    }
    
    func videoPlayerVideController() -> VideoPlayerViewController? {
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
        videoTitleLabel.text = thisExperience.metadata()?.fullTitle()
        if let videoURL = thisExperience.videoURL(), videoPlayerViewController = videoPlayerVideController() {
            if let player = videoPlayerViewController.player {
                player.removeAllItems()
            }
            
            videoPlayerViewController.playerControlsVisible = false
            videoPlayerViewController.lockTopToolbar = true
            videoPlayerViewController.playVideoWithURL(videoURL)
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
