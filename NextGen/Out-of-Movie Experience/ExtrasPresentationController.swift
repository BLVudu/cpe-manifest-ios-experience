//
//  ExtrasPresentationController.swift
//  NextGen
//
//  Created by Alec Ananian on 4/12/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ExtrasPresentationController: UIPresentationController {
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        if let sourceFrame = containerView?.bounds, extrasViewController = presentingViewController as? ExtrasViewController {
            let startX = CGRectGetMinX(extrasViewController.extrasCollectionView.frame)
            let startY = CGRectGetMinY(extrasViewController.extrasCollectionView.frame)
            
            return CGRectMake(startX, startY, CGRectGetWidth(sourceFrame) - startX, CGRectGetHeight(sourceFrame) - startY)
        }
        
        return CGRectZero
    }

}
