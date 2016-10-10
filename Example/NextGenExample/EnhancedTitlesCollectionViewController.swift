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
        static let CollectionViewItemsPerRow: CGFloat = (DeviceType.IS_IPAD ? 4 : 2)
        static let CollectionViewItemSpacing: CGFloat = 12
        static let CollectionViewLineSpacing: CGFloat = 12
        static let CollectionViewPadding: CGFloat = 15
        static let CollectionViewItemAspectRatio: CGFloat = 135 / 240
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if DeviceType.IS_IPAD {
            return .landscape
        }
        
        return .all
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(UINib(nibName: "EnhancedTitlesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: EnhancedTitlesCollectionViewCell.ReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MBProgressHUD.hideAllHUDs(for: self.view, animated: false)
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NextGenDataLoader.ManifestData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EnhancedTitlesCollectionViewCell.ReuseIdentifier, for: indexPath as IndexPath) as! EnhancedTitlesCollectionViewCell
        
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
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try NextGenDataLoader.sharedInstance.loadTitle(cid: Array(NextGenDataLoader.ManifestData.keys)[indexPath.row], completionHandler: { [weak self] (success) in
                    if success, let strongSelf = self {
                        DispatchQueue.main.async {
                            NextGenLauncher.sharedInstance?.launchExperience(fromViewController: strongSelf)
                        }
                    }
                })
            } catch let error {
                print("Error loading title: \(error)")
            }
        }
    }

    // MARK: UICollectionViewFlowLayoutDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat = (collectionView.frame.width / Constants.CollectionViewItemsPerRow) - (Constants.CollectionViewItemSpacing * 2)
        return CGSize(width: itemWidth, height: itemWidth / Constants.CollectionViewItemAspectRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.CollectionViewLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.CollectionViewItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding)
    }
    
}
