//
//  CommentaryView.swift
//  
//
//  Created by Sedinam Gadzekpo on 2/18/16.
//
//

import UIKit

class CommentaryObject:NSObject{
    
    var title: String!
    var subtitle: String!
    var selected: Bool!
    
    required init(info: NSDictionary) {
        
        title = info["title"] as! String!
        subtitle = info["subtitle"] as! String!
        selected = info["selected"] as! Bool
    }
    
    
    
}



class CommentaryView: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var sectionData = [CommentaryObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = UIColor.init(red: 29/255, green: 30/255, blue: 34/255, alpha: 1)
        
        
        
        if let path = NSBundle.mainBundle().pathForResource("Commentary", ofType: "plist"), let sections = NSArray(contentsOfFile: path) {
            for section in sections {
                if let sectionInfo = section as? NSDictionary {
                    sectionData.append(CommentaryObject(info: sectionInfo))
                }
            }

        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)

    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentary")as! CommentaryViewCell
        cell.option.text = sectionData[indexPath.row].title
        cell.subtitle.text = sectionData[indexPath.row].subtitle
        cell.radioBtn.index = indexPath.row
        cell.backgroundColor = UIColor.init(red: 17/255, green: 17/255, blue: 19/255, alpha: 1)
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
         return 80
    }
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData.count
    }
    
    //func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
      //  let cell = tableView.cellForRowAtIndexPath(indexPath) as! CommentaryViewCell
        //cell.selected = true
        
        
    //}
 
    @IBAction func selectedRB(sender: RadioButton) {
        
        let indexPath = NSIndexPath(forRow: sender.index!, inSection: 0)
        
        self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)

    }
    
      }
