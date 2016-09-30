//
//  WebViewController.swift
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    private struct Constants {
        static let ScriptMessageHandlerName = "microHTMLMessageHandler"
        static let ScriptMessageAppVisible = "AppVisible"
        static let ScriptMessageAppShutdown = "AppShutdown"
        
        static let HeaderButtonWidth: CGFloat = (DeviceType.IS_IPAD ? 125 : 100)
        static let HeaderButtonHeight: CGFloat = (DeviceType.IS_IPAD ? 90 : 50)
        static let HeaderIconPadding: CGFloat = (DeviceType.IS_IPAD ? 30 : 15)
    }
    
    private var _webView: WKWebView!
    private var _title: String?
    private var _url: URL!
    var shouldDisplayFullScreen = false
    
    // MARK: Initialization
    convenience init(title: String?, url: URL) {
        self.init()
        
        _title = title
        _url = url
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = _title
        self.view.backgroundColor = UIColor.black
        
        self.navigationController?.isNavigationBarHidden = shouldDisplayFullScreen
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        configuration.userContentController.add(self, name: Constants.ScriptMessageHandlerName)
        
        if #available(iOS 9.0, *) {
            configuration.requiresUserActionForMediaPlayback = false
        } else {
            configuration.mediaPlaybackRequiresUserAction = false
        }
        
        _webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        self.view.addSubview(_webView)
        
        // Disable caching for now
        if #available(iOS 9.0, *) {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            let date = Date(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date, completionHandler:{ })
        } else {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"
            
            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
                print("error")
            }
            
            URLCache.shared.removeAllCachedResponses()
        }
        
        _webView.navigationDelegate = self
        _webView.load(URLRequest(url: _url))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: self.view.frame.width - Constants.HeaderButtonWidth, y: 0, width: Constants.HeaderButtonWidth, height: Constants.HeaderButtonHeight)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding + 10, 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, Constants.HeaderIconPadding, 0, 0)
        button.titleLabel?.font = UIFont.themeFont(DeviceType.IS_IPAD ? 18 : 14)
        button.setTitle(String.localize("label.exit"), for: UIControlState())
        button.setImage(UIImage(named: "Delete"), for: UIControlState())
        button.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        button.titleLabel?.layer.shadowOpacity = 0.75
        button.titleLabel?.layer.shadowRadius = 2
        button.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.titleLabel?.layer.masksToBounds = false
        button.titleLabel?.layer.shouldRasterize = true
        button.addTarget(self, action: #selector(self.close), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
    }

    // MARK: Actions
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    // MARK: WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Constants.ScriptMessageHandlerName {
            if let messageBody = message.body as? String {
                if messageBody == Constants.ScriptMessageAppVisible {
                    
                } else if messageBody == Constants.ScriptMessageAppShutdown {
                    close()
                }
            }
        }
    }

}
