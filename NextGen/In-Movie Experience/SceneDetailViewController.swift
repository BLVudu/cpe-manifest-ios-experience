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
        
        self.view.backgroundColor = UIColor.black
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.themeCondensedFont(DeviceType.IS_IPAD ? 25 : 18)
        titleLabel.textColor = UIColor.white
        self.view.addSubview(titleLabel)
        
        closeButton = UIButton(type: UIButtonType.custom)
        closeButton.titleLabel?.font = UIFont.themeCondensedFont(DeviceType.IS_IPAD ? 17 : 15)
        closeButton.setTitle(String.localize("label.close"), for: UIControlState())
        closeButton.setImage(UIImage(named: "Close"), for: UIControlState())
        closeButton.contentEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0)
        closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25)
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, Constants.CloseButtonWidth, 0, 0)
        closeButton.addTarget(self, action: #selector(SceneDetailViewController.close), for: UIControlEvents.touchUpInside)
        self.view.addSubview(closeButton)
        
        if let title = self.title {
            titleLabel.text = title.uppercased()
        } else if let title = experience?.metadata?.title {
            titleLabel.text = title.uppercased()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let viewWidth = self.view.frame.width
        titleLabel.frame = CGRect(x: Constants.ViewMargin, y: 0, width: viewWidth - (2 * Constants.ViewMargin), height: Constants.TitleLabelHeight)
        closeButton.frame = CGRect(x: viewWidth - Constants.CloseButtonWidth - Constants.ViewMargin, y: 0, width: Constants.CloseButtonWidth, height: Constants.TitleLabelHeight)
    }
    
    // MARK: Actions
    internal func close() {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: SceneDetailNotification.WillClose), object: nil)
    }

}
