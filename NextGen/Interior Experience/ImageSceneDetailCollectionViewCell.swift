//
//  ImageSceneDetailCollectionViewCell.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

class ImageSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "ImageSceneDetailCollectionViewCellReuseIdentifier"
    
    struct ProductImageType {
        static let Product = "ProductImageTypeProduct"
        static let Scene = "ProductImageTypeScene"
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bullseyeView: UIView!
    var productImageType = ProductImageType.Product
    
    private var _imageURL: NSURL!
    var imageURL: NSURL? {
        get {
            return _imageURL
        }
        
        set(v) {
            _imageURL = v
            
            if let url = _imageURL {
                if _currentProduct != nil {
                    imageView.contentMode = UIViewContentMode.ScaleAspectFit
                    imageView.setImageWithURL(url, completion: { (image) -> Void in
                        self.imageView!.backgroundColor = image?.getPixelColor(CGPoint.zero)
                    })
                } else {
                    imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    imageView.setImageWithURL(url)
                }
            } else {
                imageView.image = nil
                imageView.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    private var _theTakeProducts: [TheTakeProduct]!
    private var _currentProduct: TheTakeProduct?
    var theTakeProducts: [TheTakeProduct]? {
        get {
            return _theTakeProducts
        }
        
        set(v) {
            _theTakeProducts = v
            
            if let products = _theTakeProducts, product = products.first {
                if _currentProduct != product {
                    _currentProduct = product
                    descriptionText = product.brand
                    extraDescriptionText = product.name
                    imageURL = productImageType == ProductImageType.Scene ? product.sceneImageURL : product.productImageURL
                }
            } else {
                _currentProduct = nil
                imageURL = nil
                descriptionText = nil
                extraDescriptionText = nil
            }
        }
    }
    
    override var timedEvent: NGDMTimedEvent? {
        get {
            return super.timedEvent
        }
        
        set(v) {
            super.timedEvent = v
            
            if let event = _timedEvent, experience = experience {
                imageURL = event.getImageURL(experience)
            } else {
                imageURL = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        theTakeProducts = nil
        bullseyeView.hidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if productImageType == ProductImageType.Scene {
            bullseyeView.hidden = false
            if let product = _currentProduct {
                var bullseyeFrame = bullseyeView.frame
                let bullseyePoint = product.getSceneBullseyePoint(imageView.frame)
                bullseyeFrame.origin = CGPointMake(bullseyePoint.x + CGRectGetMinX(imageView.frame), bullseyePoint.y + CGRectGetMinY(imageView.frame))
                bullseyeView.frame = bullseyeFrame
                bullseyeView.layer.cornerRadius = CGRectGetWidth(bullseyeFrame) / 2
            }
        } else {
            bullseyeView.hidden = true
        }
    }
    
}
