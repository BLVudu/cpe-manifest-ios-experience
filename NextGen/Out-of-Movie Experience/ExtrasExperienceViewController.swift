//
//  ExtrasExperienceViewController.swift
//

import UIKit
import NextGenDataManager

class ExtrasExperienceViewController: UIViewController {
    
    private struct Constants {
        static let HeaderButtonWidth: CGFloat = 250
        static let HeaderIconPadding: CGFloat = 30
        static let TitleImageWidth: CGFloat = 300
        static let TitleImageHeight: CGFloat = 90
        static let TitleLabelXOffset: CGFloat = -30
        static let TitleLabelYOffset: CGFloat = 5
    }
    
    var experience: NGDMExperience!
    
    private var _homeButton: UIButton!
    private var _backButton: UIButton!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var titleFrame = CGRectMake(CGRectGetWidth(self.view.frame) - Constants.TitleImageWidth, 0, Constants.TitleImageWidth, Constants.TitleImageHeight)
        if experience == NGDMManifest.sharedInstance.outOfMovieExperience, let titleImageURL = experience.appearance?.titleImageURL {
            let titleImageView = UIImageView(frame: titleFrame)
            titleImageView.setImageWithURL(titleImageURL)
            self.view.addSubview(titleImageView)
            self.view.sendSubviewToBack(titleImageView)
        } else {
            titleFrame.origin.x += Constants.TitleLabelXOffset
            titleFrame.origin.y += Constants.TitleLabelYOffset
            let titleLabel = UILabel(frame: titleFrame)
            titleLabel.textAlignment = NSTextAlignment.Right
            titleLabel.textColor = UIColor(netHex: 0xdddddd)
            titleLabel.font = UIFont.themeCondensedBoldFont(30)
            titleLabel.text = experience.title.uppercaseString
            self.view.addSubview(titleLabel)
            self.view.sendSubviewToBack(titleLabel)
        }
        
        _homeButton = headerButton(String.localize("label.home"), imageName: "Home")
        self.view.addSubview(_homeButton)
        self.view.sendSubviewToBack(_homeButton)
        
        _backButton = headerButton(String.localize("label.back"), imageName: "Back Nav")
        self.view.addSubview(_backButton)
        self.view.sendSubviewToBack(_backButton)
        
        if let backgroundImageURL = NGDMManifest.sharedInstance.outOfMovieExperience?.appearance?.backgroundImageURL {
            let backgroundImageView = UIImageView()
            backgroundImageView.setImageWithURL(backgroundImageURL)
            backgroundImageView.frame = self.view.bounds
            self.view.addSubview(backgroundImageView)
            self.view.sendSubviewToBack(backgroundImageView)
        }
        
        showBackButton()
    }
    
    func headerButton(title: String, imageName: String) -> UIButton {
        let button = UIButton.buttonWithImage(UIImage(named: imageName))
        button.hidden = true
        button.frame = CGRectMake(0, 0, Constants.HeaderButtonWidth, Constants.TitleImageHeight)
        button.contentHorizontalAlignment = .Left
        button.titleEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding + 10, 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding, 0, 0)
        button.titleLabel?.font = UIFont.themeFont(18)
        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: #selector(self.close), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }
    
    func showHomeButton() {
        _homeButton.hidden = false
        _backButton.hidden = true
    }
    
    func showBackButton() {
        _homeButton.hidden = true
        _backButton.hidden = false
    }
    
    // MARK: Actions
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }

}
