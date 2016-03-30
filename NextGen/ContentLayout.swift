//
//  ContentLayout.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/20/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


protocol ContentLayoutDelegate {
    
    func collectionView(collectionView:UICollectionView, widthForPhotoAtIndexPath indexPath:NSIndexPath , withHeight:CGFloat) -> CGFloat

    
}


class ContentLayoutAttributes:UICollectionViewLayoutAttributes {
    
    
    var photoWidth: CGFloat = 0.0
    
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! ContentLayoutAttributes
        copy.photoWidth = photoWidth
        return copy
    }
    
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributtes = object as? ContentLayoutAttributes {
            if( attributtes.photoWidth == photoWidth ) {
                return super.isEqual(object)
            }
        }
        return false
    }
}


class ContentLayout: UICollectionViewFlowLayout{
    
    
    var delegate:ContentLayoutDelegate!
    
    
    var numberOfColumns = 1
    var cellPadding: CGFloat = 30.0
    
    
    private var cache = [ContentLayoutAttributes]()
    
    
    
//    private var contentHeight:CGFloat  = 0.0
//    private var contentWidth: CGFloat
    
    private var contentWidth:CGFloat  = 0.0
    private var contentHeight: CGFloat
        
        
         {
            let insets = collectionView!.contentInset
            return CGRectGetHeight(collectionView!.bounds) - (insets.top + insets.bottom)
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return ContentLayoutAttributes.self
    }
    
    
    override func prepareLayout() {
        
        
        if cache.isEmpty {
            
            
            let columnHeight = contentHeight / CGFloat(numberOfColumns)
            var yOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                yOffset.append(CGFloat(column) * columnHeight )
            }
            var column = 0
            var xOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)
            
            for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                
                let height = columnHeight - cellPadding*2
                let photoWidth = delegate.collectionView(collectionView!, widthForPhotoAtIndexPath: indexPath , withHeight:height)
                let width = cellPadding +  photoWidth +  cellPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: width, height: height)
                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                
                
                let attributes = ContentLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.photoWidth = photoWidth
                attributes.frame = insetFrame
                cache.append(attributes)
                
                contentWidth = max(contentWidth, CGRectGetMaxX(frame))
                xOffset[column] = xOffset[column] + width
                
                column = column >= (numberOfColumns - 1) ? 0 : column + 1
            }
        }
    }

    
    override func collectionViewContentSize() -> CGSize {
        
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes  in cache {
            if CGRectIntersectsRect(attributes.frame, rect ) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

    
    

    
    
}