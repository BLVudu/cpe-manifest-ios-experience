//
//  TalentImageGalleryViewController.swift
//

import UIKit
import NextGenDataManager

class TalentImageGalleryViewController: SceneDetailViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak private var galleryScrollView: ImageGalleryScrollView!
    @IBOutlet weak private var galleryCollectionView: UICollectionView!
    
    var talent: NGDMTalent!
    var initialPage = 0
    
    private var galleryDidScrollToPageObserver: NSObjectProtocol?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        galleryScrollView.cleanInvisibleImages()
    }

    override func viewDidLoad() {
        self.title = String.localize("talentdetail.gallery")
        
        super.viewDidLoad()
        
        galleryScrollView.currentPage = initialPage
        galleryScrollView.removeToolbar()
        
        galleryDidScrollToPageObserver = NSNotificationCenter.defaultCenter().addObserverForName(ImageGalleryNotification.DidScrollToPage, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self, page = notification.userInfo?["page"] as? Int {
                let pageIndexPath = NSIndexPath(forItem: page, inSection: 0)
                strongSelf.galleryCollectionView.selectItemAtIndexPath(pageIndexPath, animated: false, scrollPosition: .None)
                
                var cellIsShowing = false
                for cell in strongSelf.galleryCollectionView.visibleCells() {
                    if let indexPath = strongSelf.galleryCollectionView.indexPathForCell(cell) where indexPath.row == page {
                        cellIsShowing = true
                        break
                    }
                }
                
                if !cellIsShowing {
                    strongSelf.galleryCollectionView.scrollToItemAtIndexPath(pageIndexPath, atScrollPosition: .CenteredHorizontally, animated: true)
                }
            }
        })
        
        galleryCollectionView.registerNib(UINib(nibName: String(SimpleImageCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: SimpleImageCollectionViewCell.BaseReuseIdentifier)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var imageURLs = [NSURL]()
        if let talentImages = talent.images {
            for talentImage in talentImages {
                if let imageURL = talentImage.imageURL {
                    imageURLs.append(imageURL)
                }
            }
        }
        
        galleryScrollView.loadImageURLs(imageURLs)
        galleryScrollView.gotoPage(initialPage, animated: false)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return talent.images?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SimpleImageCollectionViewCell.BaseReuseIdentifier, forIndexPath: indexPath) as! SimpleImageCollectionViewCell
        cell.showsSelectedBorder = true
        cell.selected = (indexPath.row == galleryScrollView.currentPage)
        cell.imageURL = talent.images?[indexPath.row].thumbnailImageURL
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        galleryScrollView.gotoPage(indexPath.row, animated: true)
    }

}
