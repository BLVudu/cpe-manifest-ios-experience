//
//  TalentTableViewCell.swift
//

import UIKit
import NextGenDataManager

class TalentTableViewCell: UITableViewCell {
    
    static let ReuseIdentifier = "TalentTableViewCell"
    
    @IBOutlet weak private var talentImageView: UIImageView!
    @IBOutlet weak private var talentInitialLabel: UILabel!
    @IBOutlet weak private var nameLabel: UILabel?
    @IBOutlet weak private var roleLabel: UILabel?
    
    private var imageURL: URL? {
        didSet {
            talentImageView.alpha = 1
            talentImageView.backgroundColor = UIColor.clear
            talentInitialLabel.isHidden = true
            
            if let url = imageURL {
                
                if url != oldValue {
                    talentImageView.sd_setImage(with: url)
                }
            } else {
                talentImageView.sd_cancelCurrentImageLoad()
                talentImageView.image = nil
                
                if let name = name {
                    talentImageView.alpha = 0.9
                    talentImageView.backgroundColor = UIColor.themePrimary
                    talentInitialLabel.isHidden = false
                    talentInitialLabel.text = name[0]
                }
            }
        }
    }
    
    private var name: String? {
        set {
            nameLabel?.text = newValue?.uppercased()
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
        
        self.contentView.layoutIfNeeded()
        self.backgroundColor = UIColor.clear
        talentImageView.layer.cornerRadius = talentImageView.frame.width / 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            talentImageView.layer.borderWidth = 2
            talentImageView.layer.borderColor = UIColor.white.cgColor
            nameLabel?.textColor = UIColor.themePrimary
            roleLabel?.textColor = UIColor.themePrimary
        } else {
            talentImageView.layer.borderWidth = 0
            nameLabel?.textColor = UIColor.white
            roleLabel?.textColor = UIColor.themeLightGray
        }
    }

}
