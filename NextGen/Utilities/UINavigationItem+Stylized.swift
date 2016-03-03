//
//  UINavigationItem+Stylized.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

let navigationHeight: CGFloat = 44
let logoImagePadding: CGFloat = 5
let logoImageWidth: CGFloat = 255
let logoImageHeight: CGFloat = navigationHeight - (2 * logoImagePadding)

enum UIBarButtonItemSide {
    case Left
    case Right
}

extension UINavigationItem {
    
    func addTitleStyling() {
        let logoContainerView = UIView(frame: CGRectMake(0, 0, logoImageWidth, navigationHeight))
        
        let logoImageView = UIImageView(image: UIImage(named: "Title Logo"))
        logoImageView.frame = CGRectMake(0, logoImagePadding, logoImageWidth, logoImageHeight)
        logoContainerView.addSubview(logoImageView)
        
        self.titleView = logoContainerView
        
        let rightHeaderImageView = UIImageView(image: UIImage(named: "extras_header.png"))
        rightHeaderImageView.frame = CGRectMake(0, 0, 182, navigationHeight)
        self.rightBarButtonItem = UIBarButtonItem(customView: rightHeaderImageView)
        
    }
    
    func setBarButton(side: UIBarButtonItemSide!, button: UIButton!, target: AnyObject?, action: Selector) {
        let barButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        
        if side == UIBarButtonItemSide.Left {
            self.leftBarButtonItem = barButtonItem
        } else {
            self.rightBarButtonItem = barButtonItem
        }
    }
    
    func setHomeButton(target: AnyObject?, action: Selector) {
        setBarButton(.Left, button: UIButton.homeButton(), target: target, action: action)
    }
    
    func setBackButton(target: AnyObject?, action: Selector) {
        setBarButton(.Left, button: UIButton.backButton(), target: target, action: action)
    }
    
}
