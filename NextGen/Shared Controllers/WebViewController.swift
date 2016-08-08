//
//  WebViewController.swift
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    private struct Constants {
        static let HeaderButtonWidth: CGFloat = (DeviceType.IS_IPAD ? 250 : 100)
        static let HeaderButtonHeight: CGFloat = (DeviceType.IS_IPAD ? 90 : 50)
        static let HeaderIconPadding: CGFloat = (DeviceType.IS_IPAD ? 30 : 15)
    }
    
    private var _webView: WKWebView!
    private var _title: String?
    private var _url: NSURL!
    
    // MARK: Initialization
    convenience init(title: String?, url: NSURL) {
        self.init()
        
        _title = title
        _url = url
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = _title
        self.view.backgroundColor = UIColor.blackColor()
        
        let configuration = WKWebViewConfiguration()
        configuration.mediaPlaybackRequiresUserAction = false
        _webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        self.view.addSubview(_webView)
        
        _webView.navigationDelegate = self
        _webView.loadRequest(NSURLRequest(URL: _url))

        let button = UIButton.buttonWithImage(UIImage(named: "Back Nav"))
        button.frame = CGRectMake(0, 0, Constants.HeaderButtonWidth, Constants.HeaderButtonHeight)
        button.contentHorizontalAlignment = .Left
        button.titleEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding + 10, 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding, 0, 0)
        button.titleLabel?.font = UIFont.themeFont(DeviceType.IS_IPAD ? 18 : 14)
        button.setTitle(String.localize("label.back"), forState: .Normal)
        button.addTarget(self, action: #selector(self.onDone), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }

    // MARK: Actions
    func onDone() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: WKNavigationDelegate
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.Allow)
    }

}
