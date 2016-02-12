//
//  RadioButton.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/11/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class RadioButton: UIButton{
    
    override var selected: Bool {
        didSet {
            toggleButon()
        }
    }

    
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
        self.layer.borderWidth = 3
        self.layer.cornerRadius = 0.5*self.bounds.size.width
        self.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    

    
    func toggleButon() {
        if self.selected {
    self.backgroundColor = UIColor.yellowColor()
        } else{
    self.backgroundColor = UIColor.clearColor()
    }
    }
    
    
}
