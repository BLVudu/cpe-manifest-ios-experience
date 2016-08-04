//
//  SceneDetailViewController.swift
//

import UIKit
import NextGenDataManager

struct SceneDetailNotification {
    static let WillClose = "kSceneDetailNotificationWillClose"
}

class SceneDetailViewController: UIViewController {
    
    private struct Constants {
        static let ViewMargin: CGFloat = 10
        static let TitleLabelHeight: CGFloat = (DeviceType.IS_IPAD ? 70 : 50)
        static let CloseButtonWidth: CGFloat = (DeviceType.IS_IPAD ? 110 : 100)
    }
    
    var experience: NGDMExperience?
    var timedEvent: NGDMTimedEvent?
    
    var titleLabel: UILabel!
    var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.themeCondensedFont(DeviceType.IS_IPAD ? 25 : 18)
        titleLabel.textColor = UIColor.whiteColor()
        self.view.addSubview(titleLabel)
        
        closeButton = UIButton(type: UIButtonType.Custom)
        closeButton.titleLabel?.font = UIFont.themeCondensedFont(DeviceType.IS_IPAD ? 17 : 15)
        closeButton.setTitle(String.localize("label.close"), forState: UIControlState.Normal)
        closeButton.setImage(UIImage(named: "Close"), forState: UIControlState.Normal)
        closeButton.contentEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0)
        closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25)
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, Constants.CloseButtonWidth, 0, 0)
        closeButton.addTarget(self, action: #selector(SceneDetailViewController.close), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(closeButton)
        
        if let title = self.title {
            titleLabel.text = title.uppercaseString
        } else if let title = experience?.metadata?.title {
            titleLabel.text = title.uppercaseString
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let viewWidth = CGRectGetWidth(self.view.frame)
        titleLabel.frame = CGRectMake(Constants.ViewMargin, 0, viewWidth - (2 * Constants.ViewMargin), Constants.TitleLabelHeight)
        closeButton.frame = CGRectMake(viewWidth - Constants.CloseButtonWidth - Constants.ViewMargin, 0, Constants.CloseButtonWidth, Constants.TitleLabelHeight)
    }
    
    // MARK: Actions
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(SceneDetailNotification.WillClose, object: nil)
    }

}
