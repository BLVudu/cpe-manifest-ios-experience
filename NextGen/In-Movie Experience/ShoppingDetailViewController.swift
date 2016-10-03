//
//  ShoppingDetailViewController.swift
//

import UIKit

class ShoppingDetailCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "ShoppingDetailCellReuseIdentifier"
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    var product: TheTakeProduct? {
        didSet {
            productBrandLabel.text = product?.brand
            productNameLabel.text = product?.name
            if let imageURL = product?.productImageURL {
                productImageView.sd_setImage(with: imageURL, completed: { [weak self] (image, _, _, _) in
                    self?.productImageView.backgroundColor = image?.getPixelColor(CGPoint.zero)
                })
            } else {
                productImageView.sd_cancelCurrentImageLoad()
                productImageView.image = nil
                productImageView.backgroundColor = UIColor.clear
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = (self.isSelected ? 2 : 0)
        }
    }
    
}

class ShoppingDetailViewController: SceneDetailViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak private var productMatchIcon: UIView!
    @IBOutlet weak private var productMatchLabel: UILabel!
    @IBOutlet weak private var productImageView: UIImageView!
    @IBOutlet weak private var productBrandLabel: UILabel!
    @IBOutlet weak private var productNameLabel: UILabel!
    @IBOutlet weak private var productPriceLabel: UILabel!
    @IBOutlet weak private var shopButton: UIButton!
    @IBOutlet weak private var emailButton: UIButton!
    @IBOutlet weak private var poweredByLabel: UILabel!
    @IBOutlet weak private var disclaimerLabel: UILabel!
    @IBOutlet weak private var productsCollectionView: UICollectionView?
    
    var products: [TheTakeProduct]?
    private var closeDetailsViewObserver: NSObjectProtocol?
    
    deinit {
        if let observer = closeDetailsViewObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    var currentProduct: TheTakeProduct? {
        didSet {
            if let product = currentProduct {
                productMatchIcon.backgroundColor = (product.exactMatch ? UIColor(netHex: 0x2c97de) : UIColor(netHex: 0xf1c115))
                productMatchLabel.text = (product.exactMatch ? String.localize("shopping.exact_match") : String.localize("shopping.close_match"))
            } else {
                productMatchIcon.backgroundColor = UIColor.clear
                productMatchLabel.text = nil
            }
            
            productBrandLabel.text = currentProduct?.brand
            productNameLabel.text = currentProduct?.name
            productPriceLabel.text = currentProduct?.price
            if let imageURL = currentProduct?.productImageURL {
                productImageView.sd_setImage(with: imageURL, completed: { [weak self] (image, _, _, _) in
                    self?.productImageView.backgroundColor = image?.getPixelColor(CGPoint.zero)
                })
            } else {
                productImageView.sd_cancelCurrentImageLoad()
                productImageView.image = nil
                productImageView.backgroundColor = UIColor.clear
            }
        }
    }
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localizations
        shopButton.setTitle(String.localize("shopping.shop_button").uppercased(), for: UIControlState())
        emailButton.setTitle(String.localize("shopping.send_button").uppercased(), for: UIControlState())
        poweredByLabel.text = String.localize("shopping.powered_by")
        disclaimerLabel.text = String.localize("shopping.disclaimer").uppercased()
        
        closeDetailsViewObserver = NotificationCenter.default.addObserver(forName: .shoppingShouldCloseDetails, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let strongSelf = self {
                strongSelf.close()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if products != nil && products!.count > 1, let productsCollectionView = productsCollectionView {
            let indexPath = IndexPath(row: 0, section: 0)
            productsCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.top)
            collectionView(productsCollectionView, didSelectItemAt: indexPath)
        } else {
            productsCollectionView?.removeFromSuperview()
            currentProduct = products?.first
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        productMatchIcon.layer.cornerRadius = productMatchIcon.frame.width / 2
    }
    
    
    // MARK: Actions
    @IBAction func onShop(_ sender: AnyObject) {
        currentProduct?.theTakeURL?.promptLaunchBrowser()
    }
    
    @IBAction func onSendLink(_ sender: AnyObject) {
        if let button = sender as? UIButton, let product = currentProduct {
            let activityViewController = UIActivityViewController(activityItems: [product.shareText], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = button
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShoppingDetailCell.ReuseIdentifier, for: indexPath) as! ShoppingDetailCell
        cell.product = products?[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let product = products?[(indexPath as NSIndexPath).row] , product != currentProduct {
            currentProduct = product
        }
    }
    
}
