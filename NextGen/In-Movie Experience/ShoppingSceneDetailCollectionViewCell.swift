//
//  ShoppingSceneDetailCollectionViewCell.swift
//

import Foundation
import UIKit

class ShoppingSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "ShoppingSceneDetailCollectionViewCellReuseIdentifier"
    
    struct ProductImageType {
        static let Product = "ProductImageTypeProduct"
        static let Scene = "ProductImageTypeScene"
    }
    
    @IBOutlet weak private var _imageView: UIImageView!
    @IBOutlet weak private var _bullseyeImageView: UIImageView!
    @IBOutlet weak private var _extraDescriptionLabel: UILabel!
    
    var productImageType = ProductImageType.Product
    private var _setImageSessionDataTask: NSURLSessionDataTask?
    
    private var _extraDescriptionText: String? {
        didSet {
            _extraDescriptionLabel?.text = _extraDescriptionText
        }
    }
    
    private var _imageURL: NSURL? {
        didSet {
            if let url = _imageURL {
                if url != oldValue {
                    _imageView.contentMode = UIViewContentMode.ScaleAspectFit
                    _setImageSessionDataTask = _imageView.setImageWithURL(url, completion: { (image) -> Void in
                        self._imageView.backgroundColor = image?.getPixelColor(CGPoint.zero)
                    })
                }
            } else {
                _imageView.image = nil
                _imageView.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    private var _currentProduct: TheTakeProduct?
    private var _currentProductFrameTime = -1.0
    private var _currentProductSessionDataTask: NSURLSessionDataTask?
    var theTakeProducts: [TheTakeProduct]? {
        didSet {
            if let products = theTakeProducts, product = products.first {
                if _currentProduct != product {
                    _currentProduct = product
                    _descriptionText = product.brand
                    _extraDescriptionText = product.name
                    _imageURL = (productImageType == ProductImageType.Scene ? product.sceneImageURL : product.productImageURL)
                }
            } else {
                _currentProduct = nil
                _imageURL = nil
                _descriptionText = nil
                _extraDescriptionText = nil
            }
        }
    }
    
    override func currentTimeDidChange() {
        if timedEvent != nil && timedEvent!.isType(.Product) {
            let newFrameTime = TheTakeAPIUtil.sharedInstance.closestFrameTime(currentTime)
            if newFrameTime != _currentProductFrameTime {
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        theTakeProducts = nil
        _bullseyeImageView.hidden = true
        
        if let task = _currentProductSessionDataTask {
            task.cancel()
            _currentProductSessionDataTask = nil
        }
        
        if let task = _setImageSessionDataTask {
            task.cancel()
            _setImageSessionDataTask = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if productImageType == ProductImageType.Scene {
            _bullseyeImageView.hidden = false
            if let product = _currentProduct {
                var bullseyeFrame = _bullseyeImageView.frame
                let bullseyePoint = product.getSceneBullseyePoint(_imageView.frame)
                bullseyeFrame.origin = CGPointMake(bullseyePoint.x + CGRectGetMinX(_imageView.frame) - (CGRectGetWidth(bullseyeFrame) / 2), bullseyePoint.y + CGRectGetMinY(_imageView.frame) - (CGRectGetHeight(bullseyeFrame) / 2))
                _bullseyeImageView.frame = bullseyeFrame
                
                _bullseyeImageView.layer.shadowColor = UIColor.blackColor().CGColor;
                _bullseyeImageView.layer.shadowOffset = CGSizeMake(1, 1);
                _bullseyeImageView.layer.shadowOpacity = 0.75;
                _bullseyeImageView.layer.shadowRadius = 2.0;
                _bullseyeImageView.clipsToBounds = false;
            }
        } else {
            _bullseyeImageView.hidden = true
        }
    }
    
}
