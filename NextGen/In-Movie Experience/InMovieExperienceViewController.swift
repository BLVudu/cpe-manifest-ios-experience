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
    
    private var playerCurrentTime: Double? {
        for viewController in self.childViewControllers {
            if let viewController = viewController as? VideoPlayerViewController {
                return viewController.player.currentTime().seconds
            }
        }
        
        return nil
    }
    
    private var extrasContainerViewHidden: Bool = false {
        didSet {
            extrasContainerView.isHidden = extrasContainerViewHidden
            for viewController in self.childViewControllers {
                if let viewController = (viewController as? UINavigationController)?.viewControllers.first as? InMovieExperienceExtrasViewController {
                    viewController.view.isHidden = extrasContainerView.isHidden
                    return
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        extrasContainerViewHidden = UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)
        updatePlayerConstraints()
    }
    
    private func updatePlayerConstraints() {
        playerToExtrasConstarint.isActive = !extrasContainerView.isHidden
        playerToSuperviewConstraint.isActive = !playerToExtrasConstarint.isActive
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        extrasContainerViewHidden = size.width > size.height
        updatePlayerConstraints()
        
        var videoPlayerTime: String?
        if let currentTime = playerCurrentTime, !currentTime.isNaN {
            videoPlayerTime = String(Int(currentTime))
        }
        
        if !extrasContainerView.isHidden, let videoPlayerTime = videoPlayerTime {
            NotificationCenter.default.post(name: .videoPlayerDidChangeTime, object: nil, userInfo: [NotificationConstants.time: Double(videoPlayerTime)])
        }
        
        NextGenHook.logAnalyticsEvent(.imeAction, action: (extrasContainerView.isHidden ? .rotateHideExtras : .rotateShowExtras), itemName: videoPlayerTime)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.PlayerViewController, let playerViewController = segue.destination as? VideoPlayerViewController {
            playerViewController.mode = VideoPlayerMode.mainFeature
        }
    }

}
