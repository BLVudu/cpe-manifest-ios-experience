//
//  SecondTemplateViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class SecondTemplateViewController:UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var videoView: UIImageView!
    

    @IBOutlet weak var tableView: UITableView!
    let extraImages = ["extras_bts.jpg","extras_galleries.jpg","extras_krypton.jpg","extras_legacy.jpg","extras_places.jpg","extras_scenes.jpg","extras_shopping.jpg","extras_universe.jpg"]
    let extrasCaption =  ["Behind The Scenes","Galleries","Explore Krypton","Legacy","Places","Scenes","Shopping", "DC Universe"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "video")

    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("video", forIndexPath: indexPath) as! VideoCell
        cell.backgroundColor = UIColor.blackColor()
        cell.thumbnail.image = UIImage(named: self.extraImages[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.extraImages.count
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        return 200
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
  
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        headerView.backgroundColor = UIColor.blackColor()
        let title = UILabel(frame: CGRectMake(10, 0, tableView.frame.size.width, 40))
        title.text = "Behind The Scenes"
        title.textColor = UIColor.whiteColor()
        headerView.addSubview(title)
        
        return headerView
        
    }
    


    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        self.videoView.image = UIImage(named: self.extraImages[indexPath.row])
    }
    
}
