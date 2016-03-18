//
//  WebViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 3/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "onDone")
        self.view.backgroundColor = UIColor.blackColor()
        
        let configuration = WKWebViewConfiguration()
        configuration.mediaPlaybackRequiresUserAction = false
        _webView = WKWebView(frame: self.view.frame, configuration: configuration)
        self.view.addSubview(_webView)
        
        _webView.navigationDelegate = self
        _webView.loadRequest(NSURLRequest(URL: _url))
    }

    // MARK: Actions
    func onDone() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: WKNavigationDelegate
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.Allow)
    }

}
