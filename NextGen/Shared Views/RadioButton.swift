//
//  RadioButton.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/11/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class RadioButton: UIButton{
    
    var section:Int?
    var index:Int?
    
    
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
        self.layer.cornerRadius = 0.5*40
        self.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    

    
    func toggleButon() {
        if self.selected {
            highlight()
            print("highlight")
 
        } else{
            removeHighlight()

    }
    }
    
    func highlight(){
        //self.selected = !self.selected
        self.highlighted = true
        self.backgroundColor = UIColor.yellowColor()
        
        
    }
    
    func removeHighlight(){
        //self.selected = !self.selected
        self.highlighted = false
        self.backgroundColor = UIColor.clearColor()
        
    }
    
    
}
