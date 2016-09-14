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
                productImageView.af_setImage(withURL: imageURL, completion: { [weak self] (response) in
                    if let strongSelf = self {
                        strongSelf.productImageView.backgroundColor = response.result.value?.getPixelColor(CGPoint.zero)
                    }
                })
            } else {
                productImageView.af_cancelImageRequest()
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
    
    @IBOutlet weak var productMatchIcon: UIView!
    @IBOutlet weak var productMatchLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var poweredByLabel: UILabel!
    @IBOutlet weak var disclaimerLabel: UILabel!
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    var products: [TheTakeProduct]?
    private var _closeDetailsViewObserver: NSObjectProtocol!
    
    deinit {
        NotificationCenter.default.removeObserver(_closeDetailsViewObserver)
    }
    
    var currentProduct: TheTakeProduct? {
        didSet {
            productMatchIcon.backgroundColor = currentProduct != nil ? (currentProduct!.exactMatch ? UIColor(netHex: 0x2c97de) : UIColor(netHex: 0xf1c115)) : UIColor.clear
            productMatchLabel.text = currentProduct != nil ? (currentProduct!.exactMatch ? String.localize("shopping.exact_match") : String.localize("shopping.close_match")) : nil
            productBrandLabel.text = currentProduct?.brand
            productNameLabel.text = currentProduct?.name
            productPriceLabel.text = currentProduct?.price
            if let imageURL = currentProduct?.productImageURL {
                productImageView.af_setImage(withURL: imageURL, completion: { [weak self] (response) in
                    if let strongSelf = self {
                        strongSelf.productImageView.backgroundColor = response.result.value?.getPixelColor(CGPoint.zero)
                    }
                })
            } else {
                productImageView.af_cancelImageRequest()
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
        
        productMatchIcon.layer.cornerRadius = productMatchIcon.frame.width / 2
        
        _closeDetailsViewObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ShoppingMenuNotification.ShouldCloseDetails), object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let strongSelf = self {
                strongSelf.close(nil)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let indexPath = IndexPath(row: 0, section: 0)
        productsCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.top)
        collectionView(productsCollectionView, didSelectItemAt: indexPath)
    }
    
    
    // MARK: Actions
    @IBAction func close(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onShop(_ sender: AnyObject) {
        if let product = currentProduct {
            product.theTakeURL.promptLaunchBrowser()
        }
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
