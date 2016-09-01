//
//  TalentTableViewCell.swift
//

import UIKit
import NextGenDataManager

class TalentTableViewCell: UITableViewCell {
    
    static let ReuseIdentifier = "TalentTableViewCell"
    
    @IBOutlet weak private var talentImageView: RoundImageView!
    @IBOutlet weak private var nameLabel: UILabel?
    @IBOutlet weak private var roleLabel: UILabel?
    
    private var setImageSessionDataTask: NSURLSessionDataTask?
    
    private var imageURL: NSURL? {
        didSet {
            if let task = setImageSessionDataTask {
                task.cancel()
                setImageSessionDataTask = nil
            }
            
            if let url = imageURL {
                if url != oldValue {
                    talentImageView.af_setImageWithURL(url)
                }
            } else {
                talentImageView.af_cancelImageRequest()
                talentImageView.image = nil
            }
        }
    }
    
    private var name: String? {
        set {
            nameLabel?.text = newValue?.uppercaseString
        }
        
        get {
            return nameLabel?.text
        }
    }
    
    private var role: String? {
        set {
            roleLabel?.text = newValue
        }
        
        get {
            return roleLabel?.text
        }
    }
    
    var talent: NGDMTalent? {
        didSet {
            if let talent = talent {
                if talent != oldValue {
                    name = talent.name
                    role = talent.role
                    imageURL = talent.thumbnailImageURL
                }
            } else {
                name = nil
                role = nil
                imageURL = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        talent = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            talentImageView.layer.borderWidth = 2
            talentImageView.layer.borderColor = UIColor.whiteColor().CGColor
            nameLabel?.textColor = UIColor.themePrimaryColor()
            roleLabel?.textColor = UIColor.themePrimaryColor()
        } else {
            talentImageView.layer.borderWidth = 0
            nameLabel?.textColor = UIColor.whiteColor()
            roleLabel?.textColor = UIColor.themeLightGreyColor()
        }
    }

}
