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
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var bullseyeImageView: UIImageView!
    @IBOutlet weak private var extraDescriptionLabel: UILabel!
    
    var productImageType = ProductImageType.Product
    private var setImageSessionDataTask: NSURLSessionDataTask?
    
    private var imageURL: NSURL? {
        set {
            if let task = setImageSessionDataTask {
                task.cancel()
                setImageSessionDataTask = nil
            }
            
            if let url = newValue {
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                setImageSessionDataTask = imageView.setImageWithURL(url, completion: { (image) -> Void in
                    self.imageView.backgroundColor = image?.getPixelColor(CGPoint.zero)
                })
            } else {
                imageView.image = nil
                imageView.backgroundColor = UIColor.clearColor()
            }
        }
        
        get {
            return nil
        }
    }
    
    private var extraDescription: String? {
        set {
            extraDescriptionLabel?.text = newValue
        }
        
        get {
            return extraDescriptionLabel?.text
        }
    }
    
    private var currentProduct: TheTakeProduct?
    private var currentProductFrameTime = -1.0
    private var currentProductSessionDataTask: NSURLSessionDataTask?
    var theTakeProducts: [TheTakeProduct]? {
        didSet {
            if let products = theTakeProducts, product = products.first {
                if currentProduct != product {
                    currentProduct = product
                    descriptionText = product.brand
                    extraDescription = product.name
                    imageURL = (productImageType == ProductImageType.Scene ? product.sceneImageURL : product.productImageURL)
                }
            } else {
                currentProduct = nil
                imageURL = nil
                descriptionText = nil
                extraDescription = nil
                currentProductFrameTime = -1.0
            }
        }
    }
    
    override func currentTimeDidChange() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            if self.timedEvent != nil && self.timedEvent!.isType(.Product) {
                let newFrameTime = TheTakeAPIUtil.sharedInstance.closestFrameTime(self.currentTime)
                if newFrameTime != self.currentProductFrameTime {
                    self.currentProductFrameTime = newFrameTime
                    
                    if let currentTask = self.currentProductSessionDataTask {
                        currentTask.cancel()
                    }
                    
                    self.currentProductSessionDataTask = TheTakeAPIUtil.sharedInstance.getFrameProducts(self.currentProductFrameTime, successBlock: { [weak self] (products) -> Void in
                        if let strongSelf = self {
                            strongSelf.currentProductSessionDataTask = nil
                            dispatch_async(dispatch_get_main_queue(), {
                                strongSelf.theTakeProducts = products
                            })
                        }
                    })
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        theTakeProducts = nil
        bullseyeImageView.hidden = true
        
        if let task = currentProductSessionDataTask {
            task.cancel()
            currentProductSessionDataTask = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if productImageType == ProductImageType.Scene {
            bullseyeImageView.hidden = false
            if let product = currentProduct {
                var bullseyeFrame = bullseyeImageView.frame
                let bullseyePoint = product.getSceneBullseyePoint(imageView.frame)
                bullseyeFrame.origin = CGPointMake(bullseyePoint.x + CGRectGetMinX(imageView.frame) - (CGRectGetWidth(bullseyeFrame) / 2), bullseyePoint.y + CGRectGetMinY(imageView.frame) - (CGRectGetHeight(bullseyeFrame) / 2))
                bullseyeImageView.frame = bullseyeFrame
                
                bullseyeImageView.layer.shadowColor = UIColor.blackColor().CGColor;
                bullseyeImageView.layer.shadowOffset = CGSizeMake(1, 1);
                bullseyeImageView.layer.shadowOpacity = 0.75;
                bullseyeImageView.layer.shadowRadius = 2.0;
                bullseyeImageView.clipsToBounds = false;
            }
        } else {
            bullseyeImageView.hidden = true
        }
    }
    
}
