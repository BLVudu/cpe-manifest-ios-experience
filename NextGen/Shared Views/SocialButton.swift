//
//  SocialButton.swift
//

import UIKit
import NextGenDataManager

class SocialButton: UIButton {
    
    var socialAccount: TalentSocialAccount!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    
    func initialize() {
        self.userInteractionEnabled = true
        self.clipsToBounds = true
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 0.5*40
    }
    
    func openURL() {
        socialAccount.url.promptLaunchBrowser()
    }
    
}
