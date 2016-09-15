//
//  VideoCell.swift
//

import UIKit
import NextGenDataManager
import SDWebImage

class VideoCell: UITableViewCell {
    
    static let ReuseIdentifier = "VideoCellReuseIdentifier"
    static let NibName = "VideoCell" + (DeviceType.IS_IPAD ? "" : "_iPhone")
    
    @IBOutlet weak fileprivate var thumbnailContainerView: UIView!
    @IBOutlet weak fileprivate var thumbnailImageView: UIImageView!
    @IBOutlet weak fileprivate var playIconImageView: UIImageView!
    @IBOutlet weak fileprivate var runtimeLabel: UILabel!
    @IBOutlet weak fileprivate var captionLabel: UILabel!
    
    fileprivate var didPlayVideoObserver: NSObjectProtocol?
    
    var experience: NGDMExperience? {
        didSet {
            captionLabel.text = experience?.title
            if !DeviceType.IS_IPAD {
                captionLabel.sizeToFit()
            }
            
            if let videoURL = experience?.videoURL {
                if let runtime = experience?.videoRuntime , runtime > 0 {
                    runtimeLabel.isHidden = false
                    runtimeLabel.text = SettingsManager.didWatchVideo(videoURL) ? String.localize("label.watched") : runtime.formattedTime()
                } else {
                    runtimeLabel.isHidden = true
                }
                
                didPlayVideoObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: VideoPlayerNotification.DidPlayVideo), object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
                    if let strongSelf = self, let playingVideoURL = (notification as NSNotification).userInfo?[VideoPlayerNotification.UserInfoVideoURL] as? URL , playingVideoURL == videoURL {
                        strongSelf.runtimeLabel.text = String.localize("label.playing")
                    }
                })
            } else {
                runtimeLabel.isHidden = true
            }
            
            if let imageURL = experience?.imageURL {
                thumbnailImageView.sd_setImage(with: imageURL)
            } else {
                thumbnailImageView.sd_cancelCurrentImageLoad()
                thumbnailImageView.image = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        experience = nil
        
        if let observer = didPlayVideoObserver {
            NotificationCenter.default.removeObserver(observer)
            didPlayVideoObserver = nil
        }
        
        runtimeLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCellStyle()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        updateCellStyle()
        
        if selected {
            UIView.animate(withDuration: 0.25, animations: {
                self.thumbnailImageView.alpha = 1
                self.captionLabel.alpha = 1
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.thumbnailImageView.alpha = 0.5
                self.captionLabel.alpha = 0.5
                if let videoURL = self.experience?.videoURL {
                    self.runtimeLabel.text = SettingsManager.didWatchVideo(videoURL) ? String.localize("label.watched") : self.experience?.videoRuntime.formattedTime()
                } else {
                    self.runtimeLabel.text = self.experience?.videoRuntime.formattedTime()
                }
            }, completion: nil)
        }
    }
    
    func updateCellStyle() {
        thumbnailContainerView.layer.borderColor = UIColor.white.cgColor
        thumbnailContainerView.layer.borderWidth = (self.isSelected ? 2 : 0)
        captionLabel.textColor = (self.isSelected ? UIColor.themePrimaryColor() : UIColor.white)
        playIconImageView.isHidden = (experience == nil || experience!.isType(.gallery)) || self.isSelected
    }
    
    func setWatched() {
        self.runtimeLabel.text = String.localize("label.watched")
    }
    
}
