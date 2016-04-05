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
    
    struct Constants {
        static let UpdateInterval: Double = 15000.0
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bullseyeView: UIView!
    var productImageType = ProductImageType.Product
    
    private var _imageURL: NSURL!
    var imageURL: NSURL? {
        get {
            return _imageURL
        }
        
        set {
            if _imageURL != newValue {
                _imageURL = newValue
                
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
    }
    
    private var _theTakeProducts: [TheTakeProduct]!
    private var _currentProduct: TheTakeProduct?
    private var _currentProductFrameTime = -1.0
    private var _currentProductSessionDataTask: NSURLSessionDataTask?
    var theTakeProducts: [TheTakeProduct]? {
        get {
            return _theTakeProducts
        }
        
        set {
            _theTakeProducts = newValue
            
            if let products = _theTakeProducts, product = products.first {
                if _currentProduct != product {
                    _currentProduct = product
                    descriptionText = product.brand
                    extraDescriptionText = product.name
                    imageURL = (productImageType == ProductImageType.Scene ? product.sceneImageURL : product.productImageURL)
                }
            } else {
                _currentProduct = nil
                imageURL = nil
                descriptionText = nil
                extraDescriptionText = nil
            }
        }
    }
    
    override var currentTime: Double {
        didSet {
            if timedEvent != nil && timedEvent!.isProduct() {
                let newFrameTime = TheTakeAPIUtil.sharedInstance.closestFrameTime(currentTime)
                if _currentProductFrameTime < 0 || newFrameTime - _currentProductFrameTime >= Constants.UpdateInterval {
                    _currentProductFrameTime = newFrameTime
                    
                    if let currentTask = _currentProductSessionDataTask {
                        currentTask.cancel()
                    }
                    
                    _currentProductSessionDataTask = TheTakeAPIUtil.sharedInstance.getFrameProducts(_currentProductFrameTime, successBlock: { [weak self] (products) -> Void in
                        if let strongSelf = self {
                            dispatch_async(dispatch_get_main_queue(), {
                                strongSelf.theTakeProducts = products
                            })
                            
                            strongSelf._currentProductSessionDataTask = nil
                        }
                    })
                }
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
    
    override func timedEventDidChange() {
        super.timedEventDidChange()
        
        if let timedEvent = timedEvent, experience = experience {
            imageURL = timedEvent.getImageURL(experience)
        } else {
            imageURL = nil
        }
    }
    
}
