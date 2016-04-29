//
//  ExtrasExperienceViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ExtrasExperienceViewController: UIViewController {
    
    let kHeaderButtonWidth: CGFloat = 250
    let kHeaderIconPadding: CGFloat = 30
    let kTitleImageWidth: CGFloat = 300
    let kTitleImageHeight: CGFloat = 90
    
    var experience: NGDMExperience!
    var appAppearance: NGDMAppearance!
    
    private var _titleImageView: UIImageView!
    private var _homeButton: UIButton!
    private var _backButton: UIButton!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appAppearance = NGDMAppearance()
        _titleImageView = UIImageView(frame: CGRectMake(CGRectGetWidth(self.view.frame) - kTitleImageWidth, 0, kTitleImageWidth, kTitleImageHeight))
        _titleImageView.image = appAppearance.extrasTitleImage
        self.view.addSubview(_titleImageView)
        
        let backgroundImageView = UIImageView(image: appAppearance.backgroundExtrasImage)
        backgroundImageView.frame = self.view.bounds
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
        
        _homeButton = headerButton(String.localize("label.home"), imageName: "Home")
        self.view.addSubview(_homeButton)
        
        _backButton = headerButton(String.localize("label.back"), imageName: "Back Nav")
        self.view.addSubview(_backButton)
        
        showBackButton()
    }
    
    func headerButton(title: String, imageName: String) -> UIButton {
        let button = UIButton.buttonWithImage(UIImage(named: imageName))
        button.hidden = true
        button.frame = CGRectMake(0, 0, kHeaderButtonWidth, kTitleImageHeight)
        button.contentHorizontalAlignment = .Left
        button.titleEdgeInsets = UIEdgeInsetsMake(0, kHeaderIconPadding + 10, 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, kHeaderIconPadding, 0, 0)
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
