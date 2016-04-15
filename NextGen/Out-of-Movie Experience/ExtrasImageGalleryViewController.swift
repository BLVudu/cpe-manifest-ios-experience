//
//  ExtrasImageGalleryViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 3/19/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ExtrasImageGalleryViewController: ExtrasExperienceViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var galleryScrollView: UIScrollView!
    @IBOutlet weak var thumbnailCollectionView: UICollectionView!
    
    var gallery: NGDMGallery!
    private var _scrollViewPageWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = gallery.metadata?.title
        thumbnailCollectionView.backgroundColor = UIColor.clearColor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let numPictures = gallery.pictures != nil ? gallery.pictures!.count : 0
        var imageViewX: CGFloat = 0
        _scrollViewPageWidth = CGRectGetWidth(galleryScrollView.bounds)
        for i in 0 ..< numPictures {
            let imageView = UIImageView()
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            imageView.frame = CGRectMake(imageViewX, 0, _scrollViewPageWidth, CGRectGetHeight(galleryScrollView.bounds))
            imageView.clipsToBounds = true
            imageView.tag = i + 1
            galleryScrollView.addSubview(imageView)
            imageViewX += _scrollViewPageWidth
        }
        
        galleryScrollView.contentSize = CGSizeMake(CGRectGetWidth(galleryScrollView.bounds) * CGFloat(numPictures), CGRectGetHeight(galleryScrollView.bounds))
        thumbnailCollectionView.collectionViewLayout.invalidateLayout()
        
        let selectedIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        thumbnailCollectionView.selectItemAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.Top)
        collectionView(thumbnailCollectionView, didSelectItemAtIndexPath: selectedIndexPath)
    }
    
    func loadImageForPage(page: Int) {
        if let imageView = galleryScrollView.viewWithTag(page + 1) as? UIImageView, pictures = gallery.pictures {
            if imageView.image == nil {
                if let imageURL = pictures[page].imageURL {
                    imageView.setImageWithURL(imageURL)
                }
            }
        }
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / _scrollViewPageWidth)
        loadImageForPage(page)
        thumbnailCollectionView.selectItemAtIndexPath(NSIndexPath(forItem: page, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.Top)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let pictures = gallery.pictures {
            return pictures.count
        }
        
        return 0
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ExtrasImageThumbnailCollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! ExtrasImageThumbnailCollectionViewCell
        if let pictures = gallery.pictures {
            cell.picture = pictures[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            return !cell.selected
        }
        
        return false
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        loadImageForPage(indexPath.row)
        galleryScrollView.setContentOffset(CGPointMake(CGFloat(indexPath.row) * _scrollViewPageWidth, 0), animated: true)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let numItems = gallery.pictures != nil ? CGFloat(gallery.pictures!.count) : 0
        let cellsWidth = (numItems * ExtrasImageThumbnailCollectionViewCell.Width) + ((numItems - 1) * ExtrasImageThumbnailCollectionViewCell.Spacing)
        return UIEdgeInsetsMake(0, max(0, (CGRectGetWidth(collectionView.frame) - cellsWidth) / 2), 0, 0);
    }

}

class ExtrasImageThumbnailCollectionViewCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "ExtrasImageThumbnailCollectionViewCellReuseIdentifier"
    static let Width: CGFloat = 75
    static let Spacing: CGFloat = 10
    
    @IBOutlet weak var imageView: UIImageView!
    
    var picture: NGDMPicture? {
        didSet {
            if let imageURL = picture?.thumbnailImageURL {
                imageView.setImageWithURL(imageURL)
            } else {
                imageView.image = nil
            }
        }
    }
    
    override var selected: Bool {
        didSet {
            updateCellStyle()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        picture = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCellStyle()
    }
    
    func updateCellStyle() {
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.borderWidth = (self.selected ? 2 : 0)
    }
    
}