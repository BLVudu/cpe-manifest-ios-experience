//
//  CommentaryViewCell.swift
//

import UIKit

class CommentaryViewCell: UITableViewCell {
    
    @IBOutlet weak var option: UILabel!
   
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var radioBtn: RadioButton!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if (selected){
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: kDidSelectCommetaryOption), object: nil, userInfo: ["option":self.radioBtn.index!])
            self.radioBtn.isSelected = true
            self.option.textColor = UIColor.init(red: 255/255, green: 205/255, blue: 77/255, alpha: 1)
            //self.subtitle.textColor = UIColor.init(red: 255/255, green: 205/255, blue: 77/255, alpha: 1)
            
            
            
        } else {
            
            self.radioBtn.isSelected = false
            self.option.textColor = UIColor.white
            //self.subtitle.textColor = UIColor.whiteColor()
            
            
        }
        
        
}
}

   
