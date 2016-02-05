//
//  SecondTemplateViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import CoreData

class ExtrasContentViewController: StylizedViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var videoView: UIImageView!
    

    @IBOutlet weak var imageCaption: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    var imgData = NSData()
    let btsImages = ["bts_1.jpg","bts_2.jpg","bts_3.jpg","bts_4.jpg","bts_5.jpg",]
    let btsCaption =  ["Director Zack Snyder","Zack Snyder and Kevin Costner","Zack Snyder with some members of cast","Zack Snyder on location","Zack Snyder and Christopher Nolan"]
    
    var bookmarks = [NSManagedObject]()
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "video")
        
        self.navigationItem.setBackButton(self, action: "close")
    }
    
    // MARK: Actions
    func close() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("video", forIndexPath: indexPath) as! VideoCell
        cell.backgroundColor = UIColor.darkGrayColor()
        cell.thumbnail.image = UIImage(named: self.btsImages[indexPath.row])
        cell.caption.text = self.btsCaption[indexPath.row]
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.btsImages.count
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        return 200
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
  
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        headerView.backgroundColor = UIColor.darkGrayColor()
        let title = UILabel(frame: CGRectMake(10, 10, tableView.frame.size.width, 40))
        title.text = "Behind The Scenes"
        title.textColor = UIColor.whiteColor()
        title.font = UIFont(name: "Helvetica", size: 25.0)
        headerView.addSubview(title)
        
        return headerView
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    


    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.videoView.hidden = true
        self.imageCaption.hidden = true
        self.saveBtn.hidden = true
        
        if(self.videoView.hidden == true && self.imageCaption.hidden == true){
            
            
            self.videoView.alpha = 0
            self.imageCaption.alpha = 0
            self.videoView.hidden = false
            self.imageCaption.hidden = false
            self.saveBtn.hidden = false
            
            
        }
        
        UIView.animateWithDuration(0.25, animations:{
            
            
            self.videoView.alpha = 1
            self.imageCaption.alpha = 1
            self.saveBtn.alpha = 1
         }, completion: { (Bool) -> Void in
            
             })

        self.videoView.image = UIImage(named: self.btsImages[indexPath.row])
        self.imageCaption.text = self.btsCaption[indexPath.row]
        self.imgData = UIImageJPEGRepresentation(self.videoView.image!, 1)!
        
    }
    
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

    
}
