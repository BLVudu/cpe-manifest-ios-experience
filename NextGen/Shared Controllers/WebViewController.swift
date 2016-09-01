//
//  WebViewController.swift
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    private struct Constants {
        static let HeaderButtonWidth: CGFloat = (DeviceType.IS_IPAD ? 125 : 100)
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
        
        // Disable caching for now
        if #available(iOS 9.0, *) {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            let date = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.defaultDataStore().removeDataOfTypes(websiteDataTypes as! Set<String>, modifiedSince: date, completionHandler:{ })
        } else {
            var libraryPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, false).first!
            libraryPath += "/Cookies"
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(libraryPath)
            } catch {
                print("error")
            }
            
            NSURLCache.sharedURLCache().removeAllCachedResponses()
        }
        
        _webView.navigationDelegate = self
        _webView.loadRequest(NSURLRequest(URL: _url))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(CGRectGetWidth(self.view.frame) - Constants.HeaderButtonWidth, 0, Constants.HeaderButtonWidth, Constants.HeaderButtonHeight)
        button.contentHorizontalAlignment = .Left
        button.titleEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding + 10, 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding, 0, 0)
        button.titleLabel?.font = UIFont.themeFont(DeviceType.IS_IPAD ? 18 : 14)
        button.setTitle(String.localize("label.exit"), forState: .Normal)
        button.setImage(UIImage(named: "Delete"), forState: .Normal)
        button.titleLabel?.layer.shadowColor = UIColor.blackColor().CGColor
        button.titleLabel?.layer.shadowOpacity = 0.75
        button.titleLabel?.layer.shadowRadius = 2
        button.titleLabel?.layer.shadowOffset = CGSizeMake(0, 1)
        button.titleLabel?.layer.masksToBounds = false
        button.titleLabel?.layer.shouldRasterize = true
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
