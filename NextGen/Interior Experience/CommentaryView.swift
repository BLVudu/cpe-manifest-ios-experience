//
//  CommentaryView.swift
//  
//
//  Created by Sedinam Gadzekpo on 2/18/16.
//
//

import UIKit



class CommentaryView: UITableViewController{
    
    var options = ["Off","Director Commentary","Actor Commentary"]
    var subtitiles = ["Turn commentary off","Hear from the director in his own words about the decisions he made","Henry Cavill walks through his approach in various scenes as the Man of Steel"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentary")as! CommentaryViewCell
        cell.option.text = self.options[indexPath.row]
        cell.subtitle.text = self.subtitiles[indexPath.row]
        cell.selectionStyle = .None
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
         return 100
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    //override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    //}
   
    
      }
