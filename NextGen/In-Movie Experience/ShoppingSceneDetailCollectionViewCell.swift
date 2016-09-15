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
    
    @IBOutlet weak fileprivate var imageView: UIImageView!
    @IBOutlet weak fileprivate var bullseyeImageView: UIImageView!
    @IBOutlet weak fileprivate var extraDescriptionLabel: UILabel!
    
    var productImageType = ProductImageType.Product
    
    fileprivate var imageURL: URL? {
        set {
            if let url = newValue {
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                imageView.sd_setImage(with: url, completed: { [weak self] (image, _, _, _) in
                    self?.imageView.backgroundColor = image?.getPixelColor(CGPoint.zero)
                })
            } else {
                imageView.sd_cancelCurrentImageLoad()
                imageView.image = nil
                imageView.backgroundColor = UIColor.clear
            }
        }
        
        get {
            return nil
        }
    }
    
    fileprivate var extraDescription: String? {
        set {
            extraDescriptionLabel?.text = newValue
        }
        
        get {
            return extraDescriptionLabel?.text
        }
    }
    
    fileprivate var currentProduct: TheTakeProduct?
    fileprivate var currentProductFrameTime = -1.0
    fileprivate var currentProductSessionDataTask: URLSessionDataTask?
    var theTakeProducts: [TheTakeProduct]? {
        didSet {
            if let products = theTakeProducts, let product = products.first {
                if currentProduct != product {
                    currentProduct = product
                    descriptionText = product.brand
                    extraDescription = product.name
                    imageURL = (productImageType == ProductImageType.Scene ? product.sceneImageURL : product.productImageURL as URL?)
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
        DispatchQueue.global(qos: .userInitiated).async {
            if self.timedEvent != nil && self.timedEvent!.isType(.product) {
                let newFrameTime = TheTakeAPIUtil.sharedInstance.closestFrameTime(self.currentTime)
                if newFrameTime != self.currentProductFrameTime {
                    self.currentProductFrameTime = newFrameTime
                    
                    if let currentTask = self.currentProductSessionDataTask {
                        currentTask.cancel()
                    }
                    
                    self.currentProductSessionDataTask = TheTakeAPIUtil.sharedInstance.getFrameProducts(self.currentProductFrameTime, successBlock: { [weak self] (products) -> Void in
                        if let strongSelf = self {
                            strongSelf.currentProductSessionDataTask = nil
                            DispatchQueue.main.async {
                                strongSelf.theTakeProducts = products
                            }
                        }
                    })
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        theTakeProducts = nil
        bullseyeImageView.isHidden = true
        
        if let task = currentProductSessionDataTask {
            task.cancel()
            currentProductSessionDataTask = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if productImageType == ProductImageType.Scene {
            bullseyeImageView.isHidden = false
            if let product = currentProduct {
                var bullseyeFrame = bullseyeImageView.frame
                let bullseyePoint = product.getSceneBullseyePoint(imageView.frame)
                bullseyeFrame.origin = CGPoint(x: bullseyePoint.x + imageView.frame.minX - (bullseyeFrame.width / 2), y: bullseyePoint.y + imageView.frame.minY - (bullseyeFrame.height / 2))
                bullseyeImageView.frame = bullseyeFrame
                
                bullseyeImageView.layer.shadowColor = UIColor.black.cgColor;
                bullseyeImageView.layer.shadowOffset = CGSize(width: 1, height: 1);
                bullseyeImageView.layer.shadowOpacity = 0.75;
                bullseyeImageView.layer.shadowRadius = 2.0;
                bullseyeImageView.clipsToBounds = false;
            }
        } else {
            bullseyeImageView.isHidden = true
        }
    }
    
}
