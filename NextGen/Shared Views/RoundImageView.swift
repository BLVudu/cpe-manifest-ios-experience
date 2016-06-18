//
//  RoundImageView.swift
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