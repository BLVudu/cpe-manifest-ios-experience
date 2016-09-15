//
//  ExtrasExperienceViewController.swift
//

import UIKit
import NextGenDataManager
import SDWebImage

class ExtrasExperienceViewController: UIViewController {
    
    fileprivate struct Constants {
        static let HeaderButtonWidth: CGFloat = (DeviceType.IS_IPAD ? 250 : 100)
        static let HeaderIconPadding: CGFloat = (DeviceType.IS_IPAD ? 30 : 15)
        static let TitleImageAspectRatio: CGFloat = 300 / 90
        static let TitleImageHeight: CGFloat = (DeviceType.IS_IPAD ? 90 : 50)
        static let TitleLabelXOffset: CGFloat = -30
        static let TitleLabelYOffset: CGFloat = 5
    }
    
    var experience: NGDMExperience!
    
    fileprivate var _homeButton: UIButton!
    fileprivate var _backButton: UIButton!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if experience == NGDMManifest.sharedInstance.outOfMovieExperience, let titleImageURL = experience.appearance?.titleImageURL {
            let titleImageView = UIImageView()
            titleImageView.translatesAutoresizingMaskIntoConstraints = false
            titleImageView.contentMode = .scaleAspectFill
            titleImageView.sd_setImage(with: titleImageURL)
            self.view.addSubview(titleImageView)
            self.view.sendSubview(toBack: titleImageView)
            
            if #available(iOS 9.0, *) {
                titleImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.28).isActive = true
                titleImageView.heightAnchor.constraint(equalToConstant: Constants.TitleImageHeight).isActive = true
                titleImageView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
                titleImageView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: (DeviceType.IS_IPAD ? -10 : -20)).isActive = true
            }
        } else {
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.themeCondensedBoldFont(DeviceType.IS_IPAD ? 30 : 18)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.5
            titleLabel.numberOfLines = 2
            titleLabel.text = (experience?.title == "out-of-movie" ? String.localize("out_of_movie.extras_title") : experience?.title)?.uppercased()
            titleLabel.textAlignment = .right
            titleLabel.textColor = UIColor(netHex: 0xdddddd)
            self.view.addSubview(titleLabel)
            self.view.sendSubview(toBack: titleLabel)
            
            if #available(iOS 9.0, *) {
                titleLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.28).isActive = true
                titleLabel.heightAnchor.constraint(equalToConstant: Constants.TitleImageHeight).isActive = true
                titleLabel.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
                titleLabel.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: 10).isActive = true
            }
        }
        
        _homeButton = headerButton(String.localize("label.home"), imageName: "Home")
        self.view.addSubview(_homeButton)
        self.view.sendSubview(toBack: _homeButton)
        
        _backButton = headerButton(String.localize("label.back"), imageName: "Back Nav")
        self.view.addSubview(_backButton)
        self.view.sendSubview(toBack: _backButton)
        
        if let titleTreatmentImageURL = NGDMManifest.sharedInstance.mainExperience?.appearance?.titleImageURL {
            let titleTreatmentImageView = UIImageView()
            titleTreatmentImageView.translatesAutoresizingMaskIntoConstraints = false
            titleTreatmentImageView.contentMode = .scaleAspectFit
            titleTreatmentImageView.clipsToBounds = true
            titleTreatmentImageView.sd_setImage(with: titleTreatmentImageURL)
            self.view.addSubview(titleTreatmentImageView)
            self.view.sendSubview(toBack: titleTreatmentImageView)
            
            if #available(iOS 9.0, *) {
                let imageHeight = Constants.TitleImageHeight * (DeviceType.IS_IPAD ? 0.6 : 1)
                titleTreatmentImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4).isActive = true
                titleTreatmentImageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
                titleTreatmentImageView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: (Constants.TitleImageHeight - imageHeight) / 2).isActive = true
                titleTreatmentImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            }
        }
        
        if let backgroundImageURL = NGDMManifest.sharedInstance.outOfMovieExperience?.appearance?.backgroundImageURL {
            let backgroundImageView = UIImageView()
            backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
            backgroundImageView.sd_setImage(with: backgroundImageURL)
            backgroundImageView.contentMode = .scaleAspectFill
            self.view.addSubview(backgroundImageView)
            self.view.sendSubview(toBack: backgroundImageView)
            
            if #available(iOS 9.0, *) {
                backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            }
        }
        
        showBackButton()
    }
    
    func headerButton(_ title: String, imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.frame = CGRect(x: 0, y: 0, width: Constants.HeaderButtonWidth, height: Constants.TitleImageHeight)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding + 10, 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding, 0, 0)
        button.titleLabel?.font = UIFont.themeFont(DeviceType.IS_IPAD ? 18 : 14)
        button.setTitle(title, for: UIControlState())
        button.setImage(UIImage(named: imageName), for: UIControlState())
        button.addTarget(self, action: #selector(self.close), for: UIControlEvents.touchUpInside)
        return button
    }
    
    func showHomeButton() {
        _homeButton.isHidden = false
        _backButton.isHidden = true
    }
    
    func showBackButton() {
        _homeButton.isHidden = true
        _backButton.isHidden = false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if let presentedViewController = self.presentedViewController , presentedViewController.classForCoder != UIAlertController.self {
            return presentedViewController.supportedInterfaceOrientations
        }
        
        return (DeviceType.IS_IPAD ? .landscape : .portrait)
    }
    
    // MARK: Actions
    func close() {
        self.dismiss(animated: true, completion: nil)
    }

}
