//
//  TalentTableViewCell.swift
//  NextGen
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import NextGenDataManager

class TalentTableViewCell: UITableViewCell {
    
    static let ReuseIdentifier = "TalentTableViewCell"
    
    @IBOutlet weak var talentImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var roleLabel: UILabel?
    
    private var _setImageSessionDataTask: NSURLSessionDataTask?
    
    private var _imageURL: NSURL? {
        didSet {
            if let url = _imageURL {
                if url != oldValue {
                    _setImageSessionDataTask = talentImageView.setImageWithURL(url)
                }
            } else {
                talentImageView.image = nil
            }
        }
    }
    
    private var _name: String? {
        didSet {
            nameLabel?.text = _name?.uppercaseString
        }
    }
    
    private var _role: String? {
        didSet {
            roleLabel?.text = _role
        }
    }
    
    var talent: Talent? {
        didSet {
            if let talent = talent {
                if talent != oldValue {
                    _name = talent.name
                    _role = talent.role
                    _imageURL = talent.thumbnailImageURL
                }
            } else {
                _name = nil
                _role = nil
                _imageURL = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        talent = nil
        
        if let task = _setImageSessionDataTask {
            task.cancel()
            _setImageSessionDataTask = nil
        }
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
