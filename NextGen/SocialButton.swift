//
//  SocialButton.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/23/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class SocialButton: UIButton{
    
    var profileTW: String!
    var profileFB: String!
    var profileFBID: String!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    
    func initialize(){
        
       
        self.userInteractionEnabled = true
        self.clipsToBounds = true
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 0.5*40
    }
    
    
    
    
    func loadProfile(service: String){
        
        if(service == "TW"){
            if(!UIApplication.sharedApplication().openURL(NSURL(string:"twitter://user?screen_name=" + profileTW)!)){
            
            
            UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/" + profileTW)!)
            
            }
        } else if (service == "FB"){
            
            print(profileFBID)
            if(!UIApplication.sharedApplication().openURL(NSURL(string:"fb://profile/" + profileFBID)!)){
                
                
                UIApplication.sharedApplication().openURL(NSURL(string: "https://www.facebook.com/" + profileFB)!)
                
            }

            
            
        }
        
    }
    
    
    
    
    

    
}
