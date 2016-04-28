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
    
    @IBOutlet weak var logoTreatment: UIImageView!
 
    @IBOutlet weak var playMovie: UIButton!
    
    @IBOutlet weak var extras: UIButton!
    @IBOutlet weak var animatedBackground: UIView!
    
    var appAppearance: NGDMAppearance!
    
        
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)

    }
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundContainerView.sendSubviewToBack(backgroundImageView)
        
        appAppearance = NGDMAppearance()
        
        self.logoTreatment.frame = appAppearance.titleLogoRect!
        self.playMovie.frame = appAppearance.playButtonRect!
        self.extras.frame = appAppearance.extrasButtonRect!
        
        let background = appAppearance!.animatedBackground
        let animatedItem = AVPlayerItem(URL: background!)
        let animatedPlayer = AVPlayer(playerItem: animatedItem)
        let animatedLayer = AVPlayerLayer(player: animatedPlayer)
        
        animatedLayer.frame = self.animatedBackground.frame
        
        self.animatedBackground.layer.addSublayer(animatedLayer)
        animatedPlayer.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.playerDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: animatedItem)
        
        
            }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    func playerDidFinishPlaying(notification: NSNotification) {
        
        
        UIView.animateWithDuration(2.0, animations: {
            self.animatedBackground.alpha = 0.0
            self.backgroundImageView.image = self.appAppearance!.backgroundImage
            self.logoTreatment.image = self.appAppearance!.titleLogoImage
            self.playMovie.setImage(self.appAppearance!.playButtonImage, forState: .Normal)
            self.extras.setImage(self.appAppearance!.extrasButtonImage, forState: .Normal)
            }, completion: {(Bool) -> Void in
                self.animatedBackground.removeFromSuperview()
                
        })
    }
    
}

