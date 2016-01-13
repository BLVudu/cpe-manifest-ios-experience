//
//  SceneDetailCellView.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/12/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit

@IBDesignable class SceneDetailCellView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    
    private func setup() {
        let nib = UINib(nibName: "SceneDetailCellView", bundle: NSBundle(forClass: self.dynamicType))
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

}
