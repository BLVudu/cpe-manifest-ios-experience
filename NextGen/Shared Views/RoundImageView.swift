//
//  RoundImageView.swift
//  NextGen
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

@IBDesignable class RoundImageView: UIImageView {
    private var _round = false
    @IBInspectable var round: Bool {
        set {
            _round = newValue
            makeRound()
        }
        
        get {
            return _round
        }
    }
    
    override internal var frame: CGRect {
        set {
            super.frame = newValue
            makeRound()
        }
        
        get {
            return super.frame
        }
        
    }
    
    private func makeRound() {
        if self.round {
            self.clipsToBounds = true
            self.layer.cornerRadius = (self.frame.width + self.frame.height) / 4
        } else {
            self.layer.cornerRadius = 0
        }
    }
}