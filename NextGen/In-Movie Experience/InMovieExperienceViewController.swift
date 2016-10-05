//
//  InMovieExperienceViewController.swift
//

import UIKit

class InMovieExperienceViewController: UIViewController {
    
    struct SegueIdentifier {
        static let PlayerViewController = "PlayerViewControllerSegue"
    }
    
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var extrasContainerView: UIView!
    @IBOutlet var playerToExtrasConstarint: NSLayoutConstraint!
    @IBOutlet var playerToSuperviewConstraint: NSLayoutConstraint!
    
    var playerCurrentTime: Double? {
        var videoPlayerViewController: VideoPlayerViewController?
        for viewController in self.childViewControllers {
            if let viewController = viewController as? VideoPlayerViewController {
                videoPlayerViewController = viewController
                break
            }
        }
        
        if let currentTime = videoPlayerViewController?.player.currentTime() {
            return currentTime.seconds
        }
        
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        extrasContainerView.isHidden = UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)
        updatePlayerConstraints()
    }
    
    func updatePlayerConstraints() {
        playerToExtrasConstarint.isActive = !extrasContainerView.isHidden
        playerToSuperviewConstraint.isActive = !playerToExtrasConstarint.isActive
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        extrasContainerView.isHidden = size.width > size.height
        updatePlayerConstraints()
        
        var videoPlayerTime: String?
        if let currentTime = playerCurrentTime, !currentTime.isNaN {
            videoPlayerTime = String(Int(currentTime))
        }
        
        NextGenHook.logAnalyticsEvent(.imeAction, action: (extrasContainerView.isHidden ? .rotateHideExtras : .rotateShowExtras), itemName: videoPlayerTime)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.PlayerViewController, let playerViewController = segue.destination as? VideoPlayerViewController {
            playerViewController.mode = VideoPlayerMode.mainFeature
        }
    }

}
