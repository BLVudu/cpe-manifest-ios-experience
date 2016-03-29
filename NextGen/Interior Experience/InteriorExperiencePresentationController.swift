//
//  InteriorExperiencePresentationController.swift
//  NextGen
//
//  Created by Alec Ananian on 3/29/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class InteriorExperiencePresentationController: UIPresentationController {
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        if let sourceFrame = containerView?.bounds {
            let sourceWidth = CGRectGetWidth(sourceFrame)
            let videoHeight = sourceWidth / (16 / 9)
            
            return CGRectMake(CGRectGetMinX(sourceFrame), videoHeight, sourceWidth, CGRectGetHeight(sourceFrame) - videoHeight)
        }
        
        return CGRectZero
    }

}
