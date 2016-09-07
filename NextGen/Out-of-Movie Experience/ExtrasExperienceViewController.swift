//
//  ExtrasExperienceViewController.swift
//

import UIKit
import NextGenDataManager
import AlamofireImage

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
        
        if experience == NGDMManifest.sharedInstance.outOfMovieExperience, let titleImageURL = experience.appearance?.titleImageURL {
            let titleImageView = UIImageView()
            titleImageView.translatesAutoresizingMaskIntoConstraints = false
            titleImageView.contentMode = .ScaleAspectFill
            titleImageView.af_setImageWithURL(titleImageURL)
            self.view.addSubview(titleImageView)
            self.view.sendSubviewToBack(titleImageView)
            
            if #available(iOS 9.0, *) {
                titleImageView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor, multiplier: 0.25).active = true
                titleImageView.heightAnchor.constraintEqualToConstant(Constants.TitleImageHeight).active = true
                titleImageView.topAnchor.constraintEqualToAnchor(self.view.layoutMarginsGuide.topAnchor).active = true
                titleImageView.trailingAnchor.constraintEqualToAnchor(self.view.layoutMarginsGuide.trailingAnchor, constant: (DeviceType.IS_IPAD ? -10 : -20)).active = true
            }
        } else {
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.themeCondensedBoldFont(DeviceType.IS_IPAD ? 30 : 18)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.5
            titleLabel.numberOfLines = 2
            titleLabel.text = (experience?.title == "out-of-movie" ? String.localize("out_of_movie.extras_title") : experience?.title)?.uppercaseString
            titleLabel.textAlignment = .Right
            titleLabel.textColor = UIColor(netHex: 0xdddddd)
            self.view.addSubview(titleLabel)
            self.view.sendSubviewToBack(titleLabel)
            
            if #available(iOS 9.0, *) {
                titleLabel.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor, multiplier: 0.25).active = true
                titleLabel.heightAnchor.constraintEqualToConstant(Constants.TitleImageHeight).active = true
                titleLabel.topAnchor.constraintEqualToAnchor(self.view.layoutMarginsGuide.topAnchor).active = true
                titleLabel.trailingAnchor.constraintEqualToAnchor(self.view.layoutMarginsGuide.trailingAnchor, constant: 10).active = true
            }
        }
        
        _homeButton = headerButton(String.localize("label.home"), imageName: "Home")
        self.view.addSubview(_homeButton)
        self.view.sendSubviewToBack(_homeButton)
        
        _backButton = headerButton(String.localize("label.back"), imageName: "Back Nav")
        self.view.addSubview(_backButton)
        self.view.sendSubviewToBack(_backButton)
        
        if let titleTreatmentImageURL = NGDMManifest.sharedInstance.mainExperience?.appearance?.titleImageURL {
            let titleTreatmentImageView = UIImageView()
            titleTreatmentImageView.translatesAutoresizingMaskIntoConstraints = false
            titleTreatmentImageView.contentMode = .ScaleAspectFit
            titleTreatmentImageView.clipsToBounds = true
            titleTreatmentImageView.af_setImageWithURL(titleTreatmentImageURL)
            self.view.addSubview(titleTreatmentImageView)
            self.view.sendSubviewToBack(titleTreatmentImageView)
            
            if #available(iOS 9.0, *) {
                let imageHeight = Constants.TitleImageHeight * (DeviceType.IS_IPAD ? 0.6 : 1)
                titleTreatmentImageView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor, multiplier: 0.45).active = true
                titleTreatmentImageView.heightAnchor.constraintEqualToConstant(imageHeight).active = true
                titleTreatmentImageView.topAnchor.constraintEqualToAnchor(self.view.layoutMarginsGuide.topAnchor, constant: (Constants.TitleImageHeight - imageHeight) / 2).active = true
                titleTreatmentImageView.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
            }
        }
        
        if let backgroundImageURL = NGDMManifest.sharedInstance.outOfMovieExperience?.appearance?.backgroundImageURL {
            let backgroundImageView = UIImageView()
            backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
            backgroundImageView.af_setImageWithURL(backgroundImageURL)
            backgroundImageView.contentMode = .ScaleAspectFill
            self.view.addSubview(backgroundImageView)
            self.view.sendSubviewToBack(backgroundImageView)
            
            if #available(iOS 9.0, *) {
                backgroundImageView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
                backgroundImageView.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
                backgroundImageView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
                backgroundImageView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true
            }
        }
        
        showBackButton()
    }
    
    func headerButton(title: String, imageName: String) -> UIButton {
        let button = UIButton(type: .Custom)
        button.hidden = true
        button.frame = CGRectMake(0, 0, Constants.HeaderButtonWidth, Constants.TitleImageHeight)
        button.contentHorizontalAlignment = .Left
        button.titleEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding + 10, 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding, 0, 0)
        button.titleLabel?.font = UIFont.themeFont(DeviceType.IS_IPAD ? 18 : 14)
        button.setTitle(title, forState: .Normal)
        button.setImage(UIImage(named: imageName), forState: .Normal)
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
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let presentedViewController = self.presentedViewController where presentedViewController.classForCoder != UIAlertController.self {
            return presentedViewController.supportedInterfaceOrientations()
        }
        
        return (DeviceType.IS_IPAD ? .Landscape : .Portrait)
    }
    
    // MARK: Actions
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
