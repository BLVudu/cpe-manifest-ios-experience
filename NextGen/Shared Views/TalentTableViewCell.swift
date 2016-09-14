//
//  TalentTableViewCell.swift
//

import UIKit
import NextGenDataManager

class TalentTableViewCell: UITableViewCell {
    
    static let ReuseIdentifier = "TalentTableViewCell"
    
    @IBOutlet weak fileprivate var talentImageView: RoundImageView!
    @IBOutlet weak fileprivate var nameLabel: UILabel?
    @IBOutlet weak fileprivate var roleLabel: UILabel?
    
    fileprivate var setImageSessionDataTask: URLSessionDataTask?
    
    fileprivate var imageURL: URL? {
        didSet {
            if let task = setImageSessionDataTask {
                task.cancel()
                setImageSessionDataTask = nil
            }
            
            if let url = imageURL {
                if url != oldValue {
                    talentImageView.af_setImage(withURL: url)
                }
            } else {
                talentImageView.af_cancelImageRequest()
                talentImageView.image = nil
            }
        }
    }
    
    fileprivate var name: String? {
        set {
            nameLabel?.text = newValue?.uppercased()
        }
        
        get {
            return nameLabel?.text
        }
    }
    
    fileprivate var role: String? {
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
        
        self.backgroundColor = UIColor.clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            talentImageView.layer.borderWidth = 2
            talentImageView.layer.borderColor = UIColor.white.cgColor
            nameLabel?.textColor = UIColor.themePrimaryColor()
            roleLabel?.textColor = UIColor.themePrimaryColor()
        } else {
            talentImageView.layer.borderWidth = 0
            nameLabel?.textColor = UIColor.white
            roleLabel?.textColor = UIColor.themeLightGreyColor()
        }
    }

}
