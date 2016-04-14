//
//  RoundImageView.swift
//  NextGen
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

@IBDesignable class RoundImageView: UIImageView {
    
    @IBInspectable var round: Bool = false {
        didSet {
            makeRound()
        }
    }
    
    override internal var frame: CGRect {
        didSet {
            makeRound()
        }
    }
    
    private func makeRound() {
        if round {
            self.clipsToBounds = true
            self.layer.cornerRadius = (self.frame.width + self.frame.height) / 4
        } else {
            self.layer.cornerRadius = 0
        }
    }
    
}