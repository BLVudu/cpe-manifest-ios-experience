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
    
    
    private func initialize() {
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        self.layer.borderWidth = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.size.width / 2
    }
    
    func openURL() {
        socialAccount.url.promptLaunchBrowser()
    }
    
}
