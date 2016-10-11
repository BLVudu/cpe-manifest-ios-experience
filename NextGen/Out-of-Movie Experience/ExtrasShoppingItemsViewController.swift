//
//  ExtrasShoppingItemsViewController.swift
//

import UIKit
import MBProgressHUD

class ExtrasShoppingItemsViewController: ExtrasExperienceViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private struct Constants {
        static let ItemSpacing: CGFloat = 12
        static let LineSpacing: CGFloat = 12
        static let Padding: CGFloat = 15
        static let ItemAspectRatio: CGFloat = 338 / 230
    }
    
    @IBOutlet weak private var productsCollectionView: UICollectionView!
    
    private var products: [TheTakeProduct]?
    private var productListSessionDataTask: URLSessionDataTask?
    private var didSelectCategoryObserver: NSObjectProtocol?
    
    deinit {
        if let observer = didSelectCategoryObserver {
            NotificationCenter.default.removeObserver(observer)
            didSelectCategoryObserver = nil
        }
    }
 
    override func viewDidLoad() {
        productsCollectionView.register(UINib(nibName: "ShoppingSceneDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ShoppingSceneDetailCollectionViewCell.ReuseIdentifier)
        
        didSelectCategoryObserver = NotificationCenter.default.addObserver(forName: .shoppingDidSelectCategory, object: nil, queue: nil, using: { [weak self] (notification) in
            if let strongSelf = self, let categoryId = notification.userInfo?[NotificationConstants.categoryId] as? String {
                DispatchQueue.main.async(execute: {
                    strongSelf.productsCollectionView.isUserInteractionEnabled = false
                    MBProgressHUD.showAdded(to: strongSelf.productsCollectionView, animated: true)
                })
                
                if let currentTask = strongSelf.productListSessionDataTask {
                    currentTask.cancel()
                }
                
                DispatchQueue.global(qos: .userInteractive).async {
                    strongSelf.productListSessionDataTask = TheTakeAPIUtil.sharedInstance.getCategoryProducts(categoryId, successBlock: { (products) in
                        strongSelf.productListSessionDataTask = nil
                        DispatchQueue.main.async {
                            strongSelf.products = products
                            strongSelf.productsCollectionView.reloadData()
                            let newIndex = IndexPath(item: 0, section: 0)
                            strongSelf.productsCollectionView.scrollToItem(at: newIndex, at: .top, animated: false)
                            strongSelf.productsCollectionView.isUserInteractionEnabled = true
                            MBProgressHUD.hideAllHUDs(for: strongSelf.productsCollectionView, animated: true)
                        }
                    })
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        productsCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShoppingSceneDetailCollectionViewCell.ReuseIdentifier, for: indexPath) as! ShoppingSceneDetailCollectionViewCell
        cell.titleLabel?.removeFromSuperview()
        cell.productImageType = .scene
        
        if let product = products?[(indexPath as NSIndexPath).row] {
            cell.theTakeProducts = [product]
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let shoppingDetailViewController = UIStoryboard.getNextGenViewController(ShoppingDetailViewController.self) as? ShoppingDetailViewController, let cell = collectionView.cellForItem(at: indexPath) as? ShoppingSceneDetailCollectionViewCell {
            shoppingDetailViewController.experience = experience
            shoppingDetailViewController.products = cell.theTakeProducts
            shoppingDetailViewController.modalPresentationStyle = (DeviceType.IS_IPAD ? .overCurrentContext : .overFullScreen)
            shoppingDetailViewController.modalTransitionStyle = .crossDissolve
            self.present(shoppingDetailViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemWidth: CGFloat
        if DeviceType.IS_IPAD {
            itemWidth = (collectionView.frame.width / 2) - (Constants.ItemSpacing * 2)
        } else {
            itemWidth = collectionView.frame.width
        }
        
        return CGSize(width: itemWidth, height: itemWidth / Constants.ItemAspectRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.LineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.ItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(Constants.Padding, Constants.Padding, Constants.Padding, Constants.Padding)
    }
    
}
