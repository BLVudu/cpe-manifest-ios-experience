//
//  CommentaryView.swift
//

import UIKit

let kDidSelectCommetaryOption = "kDidSelectCommetaryOption"

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
        
        
        
        if let path = Bundle.main.path(forResource: "Commentary", ofType: "plist"), let sections = NSArray(contentsOfFile: path) {
            for section in sections {
                if let sectionInfo = section as? NSDictionary {
                    sectionData.append(CommentaryObject(info: sectionInfo))
                }
            }

        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let selectedIndexPath = IndexPath(row: 0, section: 0)
        self.tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentary")as! CommentaryViewCell
        cell.option.text = sectionData[(indexPath as NSIndexPath).row].title
        cell.subtitle.text = sectionData[(indexPath as NSIndexPath).row].subtitle
        cell.radioBtn.index = (indexPath as NSIndexPath).row
        cell.backgroundColor = UIColor.init(red: 17/255, green: 17/255, blue: 19/255, alpha: 1)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 80
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData.count
    }
    
    
    @IBAction func selectedRB(_ sender: RadioButton) {
        
        let indexPath = IndexPath(row: sender.index!, section: 0)
        
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kDidSelectCommetaryOption), object: nil, userInfo: ["option":sender.index!])

    }
    
      }
