//
//  SceneDetailCellView.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/12/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import MapKit

enum SceneDetailCellViewType {
    case Detail
    case Image
    case Map
    case Shop
}

@IBDesignable class SceneDetailCellView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
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
    
    var viewType: SceneDetailCellViewType = .Detail {
        didSet {
            switch viewType {
            case .Detail:
                mapView?.removeFromSuperview()
                
            case .Image:
                detailLabel.removeFromSuperview()
                mapView?.removeFromSuperview()
                break;
                
            case .Shop:
                mapView?.removeFromSuperview()
                
            default:
                break;
            }
        }
    }
    
    @IBInspectable var title : String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBInspectable var detailText : String = "" {
        didSet {
            detailLabel.text = detailText
        }
    }
    
    @IBInspectable var isMap : Bool = false {
        didSet {
            if !isMap {
                mapView.removeFromSuperview()
            }
        }
    }

}
