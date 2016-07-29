//
//  ExtrasExperienceViewController.swift
//

import UIKit
import NextGenDataManager

class ExtrasExperienceViewController: UIViewController {
    
    private struct Constants {
        static let HeaderButtonWidth: CGFloat = (DeviceType.IS_IPAD ? 250 : 100)
        static let HeaderIconPadding: CGFloat = (DeviceType.IS_IPAD ? 30 : 15)
        static let TitleImageAspectRatio: CGFloat = 300 / 90
        static let TitleImageHeight: CGFloat = (DeviceType.IS_IPAD ? 90 : 50)
        static let TitleLabelXOffset: CGFloat = -30
        static let TitleLabelYOffset: CGFloat = 5
    }
    
    var experience: NGDMExperience!
    
    private var _homeButton: UIButton!
    private var _backButton: UIButton!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleWidth = Constants.TitleImageAspectRatio * Constants.TitleImageHeight
        var titleFrame = CGRectMake(CGRectGetWidth(self.view.frame) - titleWidth, 0, titleWidth, Constants.TitleImageHeight)
        if experience == NGDMManifest.sharedInstance.outOfMovieExperience, let titleImageURL = experience.appearance?.titleImageURL {
            let titleImageView = UIImageView(frame: titleFrame)
            titleImageView.setImageWithURL(titleImageURL, completion: nil)
            self.view.addSubview(titleImageView)
            self.view.sendSubviewToBack(titleImageView)
        } else {
            titleFrame.origin.x += Constants.TitleLabelXOffset
            titleFrame.origin.y += Constants.TitleLabelYOffset
            let titleLabel = UILabel(frame: titleFrame)
            titleLabel.textAlignment = NSTextAlignment.Right
            titleLabel.textColor = UIColor(netHex: 0xdddddd)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.font = UIFont.themeCondensedBoldFont(DeviceType.IS_IPAD ? 30 : 20)
            titleLabel.minimumScaleFactor = 0.5
            titleLabel.text = (experience?.title == "out-of-movie" ? String.localize("out_of_movie.extras_title") : experience?.title)?.uppercaseString
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
            backgroundImageView.setImageWithURL(backgroundImageURL, completion: nil)
            backgroundImageView.contentMode = .ScaleAspectFill
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
        button.titleLabel?.font = UIFont.themeFont(DeviceType.IS_IPAD ? 18 : 14)
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
        return (DeviceType.IS_IPAD ? .Landscape : .All)
    }

}
