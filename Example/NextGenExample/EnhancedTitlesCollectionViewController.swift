//
//  EnhancedTitlesCollectionViewController.swift
//

import UIKit
import MBProgressHUD
import NextGenDataManager

class EnhancedTitlesCollectionViewCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "EnhancedTitlesCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = nil
    }
}

class EnhancedTitlesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private struct Constants {
        static let CollectionViewItemSpacing: CGFloat = 12
        static let CollectionViewLineSpacing: CGFloat = 12
        static let CollectionViewPadding: CGFloat = 15
        static let CollectionViewItemAspectRatio: CGFloat = 135 / 240
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.registerNib(UINib(nibName: String(EnhancedTitlesCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: EnhancedTitlesCollectionViewCell.ReuseIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NextGenDataLoader.ManifestData.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EnhancedTitlesCollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! EnhancedTitlesCollectionViewCell
        
        let cid = Array(NextGenDataLoader.ManifestData.keys)[indexPath.row]
        if let data = NextGenDataLoader.ManifestData[cid] {
            cell.titleLabel.text = data["title"]
            if let imageName = data["image"] {
                cell.imageView.image = UIImage(named: imageName)
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            do {
                try NextGenDataLoader.sharedInstance.loadTitle(Array(NextGenDataLoader.ManifestData.keys)[indexPath.row], completionHandler: { [weak self] (success) in
                    if success {
                        dispatch_async(dispatch_get_main_queue()) {
                            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
                            self?.presentViewController(UIStoryboard.getNextGenViewController(HomeViewController), animated: true, completion: nil)
                        }
                    }
                })
            } catch let error {
                print("Error loading title: \(error)")
            }
        }
    }
    
    // MARK: UICollectionViewFlowLayoutDelegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth: CGFloat = (CGRectGetWidth(collectionView.frame) / 4) - (Constants.CollectionViewItemSpacing * 2)
        return CGSizeMake(itemWidth, itemWidth / Constants.CollectionViewItemAspectRatio)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.CollectionViewLineSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.CollectionViewItemSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding)
    }
    
}
