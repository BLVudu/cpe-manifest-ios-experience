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
        
        var webViewUrl = url
        if var components = URLComponents(url: url, resolvingAgainstBaseURL: true), let deviceIdentifier = DeviceType.identifier {
            let deviceModelParam = "iphoneModel=" + deviceIdentifier
            if let query = components.query {
                components.query = query + "&" + deviceModelParam
            } else {
                components.query = deviceModelParam
            }
            
            if let newUrl = components.url {
                webViewUrl = newUrl
            }
        }
        
        _title = title
        _url = webViewUrl
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

    // MARK: Actions
    func close() {
        _webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.ScriptMessageHandlerName)
        _webView.navigationDelegate = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    // MARK: WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Constants.ScriptMessageHandlerName, let messageBody = message.body as? String {
            if messageBody == Constants.ScriptMessageAppVisible {
                
            } else if messageBody == Constants.ScriptMessageAppShutdown {
                close()
            }
        }
    }

}
