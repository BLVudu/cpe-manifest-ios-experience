//
//  HomeViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/7/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import AVKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var backgroundContainerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var animatedBackgroundView: UIView!
    
    @IBOutlet weak var titleTreatmentImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var extrasButton: UIButton!
    
    private var didFinishPlayingObserver: NSObjectProtocol!
    private var didFadeButtons = false
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(didFinishPlayingObserver)
    }
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundContainerView.sendSubviewToBack(backgroundImageView)
        
        if let appearance = CurrentManifest.mainExperience.appearance {
            if let titleTreatmentOrigin = appearance.titleImageOrigin, titleTreatmentSize = appearance.titleImageSize {
                titleTreatmentImageView.frame = CGRectMake(titleTreatmentOrigin.x, titleTreatmentOrigin.y, titleTreatmentSize.width, titleTreatmentSize.height)
            }
            
            if let backgroundVideoURL = appearance.backgroundVideoURL {
                let animatedItem = AVPlayerItem(URL: backgroundVideoURL)
                let animatedPlayer = AVPlayer(playerItem: animatedItem)
                let animatedLayer = AVPlayerLayer(player: animatedPlayer)
                animatedLayer.frame = animatedBackgroundView.frame
                animatedBackgroundView.layer.addSublayer(animatedLayer)
                animatedPlayer.play()
                
                titleTreatmentImageView.hidden = true
                playButton.hidden = true
                extrasButton.hidden = true
                
                animatedPlayer.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1, Int32(NSEC_PER_SEC)), queue: dispatch_get_main_queue(), usingBlock: { [weak self] (time) in
                    if let strongSelf = self where !strongSelf.didFadeButtons && round(time.seconds) > appearance.backgroundVideoFadeTime {
                        strongSelf.didFadeButtons = true
                        
                        strongSelf.titleTreatmentImageView.alpha = 0
                        strongSelf.playButton.alpha = 0
                        strongSelf.extrasButton.alpha = 0
                        strongSelf.titleTreatmentImageView.hidden = false
                        strongSelf.playButton.hidden = false
                        strongSelf.extrasButton.hidden = false
                        
                        UIView.animateWithDuration(0.5, animations: {
                            strongSelf.titleTreatmentImageView.alpha = 1
                            strongSelf.playButton.alpha = 1
                            strongSelf.extrasButton.alpha = 1
                        })
                    }
                })
                
                didFinishPlayingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) in
                    animatedPlayer.muted = true
                    animatedPlayer.seekToTime(CMTimeMakeWithSeconds(appearance.backgroundVideoLoopTime, Int32(NSEC_PER_SEC)))
                    animatedPlayer.play()
                })
            }
        }
        
        if let appearance = CurrentManifest.inMovieExperience.appearance, playButtonOrigin = appearance.buttonOrigin, playButtonSize = appearance.buttonSize {
            playButton.frame = CGRectMake(playButtonOrigin.x, playButtonOrigin.y, playButtonSize.width, playButtonSize.height)
        }
        
        if let appearance = CurrentManifest.outOfMovieExperience.appearance, extrasButtonOrigin = appearance.buttonOrigin, extrasButtonSize = appearance.buttonSize {
            extrasButton.frame = CGRectMake(extrasButtonOrigin.x, extrasButtonOrigin.y, extrasButtonSize.width, extrasButtonSize.height)
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
}

