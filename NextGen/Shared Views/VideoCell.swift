//
//  VideoCell.swift
//

import UIKit
import NextGenDataManager

class VideoCell: UITableViewCell {
    
    static let ReuseIdentifier = "VideoCellReuseIdentifier"
    
    @IBOutlet weak private var thumbnailContainerView: UIView!
    @IBOutlet weak private var thumbnailImageView: UIImageView!
    @IBOutlet weak private var playIconImageView: UIImageView!
    @IBOutlet weak private var runtimeLabel: UILabel!
    @IBOutlet weak private var captionLabel: UILabel!
    
    private var setImageSessionDataTask: NSURLSessionDataTask?
    private var didPlayVideoObserver: NSObjectProtocol?
    
    var experience: NGDMExperience? {
        didSet {
            captionLabel.text = experience?.title
            
            if let videoURL = experience?.videoURL {
                if let runtime = experience?.videoRuntime where runtime > 0 {
                    runtimeLabel.hidden = false
                    runtimeLabel.text = SettingsManager.didWatchVideo(videoURL) ? String.localize("label.watched") : runtime.formattedTime()
                } else {
                    runtimeLabel.hidden = true
                }
                
                didPlayVideoObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidPlayVideo, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
                    if let strongSelf = self, playingVideoURL = notification.userInfo?[VideoPlayerNotification.UserInfoVideoURL] as? NSURL where playingVideoURL == videoURL {
                        strongSelf.runtimeLabel.text = String.localize("label.playing")
                    }
                })
            } else {
                runtimeLabel.hidden = true
            }
            
            if let imageURL = experience?.imageURL {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
                    if let strongSelf = self {
                        strongSelf.setImageSessionDataTask = strongSelf.thumbnailImageView.setImageWithURL(imageURL, completion: nil)
                    }
                }
            } else {
                thumbnailImageView.image = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        experience = nil
        
        if let task = setImageSessionDataTask {
            task.cancel()
            setImageSessionDataTask = nil
        }
        
        if let observer = didPlayVideoObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            didPlayVideoObserver = nil
        }
        
        runtimeLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCellStyle()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        updateCellStyle()
        
        if selected {
            UIView.animateWithDuration(0.25, animations: {
                self.thumbnailImageView.alpha = 1
                self.captionLabel.alpha = 1
            }, completion: nil)
        } else {
            UIView.animateWithDuration(0.25, animations: {
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
        thumbnailContainerView.layer.borderColor = UIColor.whiteColor().CGColor
        thumbnailContainerView.layer.borderWidth = (self.selected ? 2 : 0)
        captionLabel.textColor = (self.selected ? UIColor.themePrimaryColor() : UIColor.whiteColor())
        playIconImageView.hidden = (experience == nil || experience!.isType(.Gallery)) || self.selected
    }
    
    func setWatched() {
        self.runtimeLabel.text = String.localize("label.watched")
    }
    
}
