//
//  CommonWebViewController.swift
//  CommonWKWebView
//
//  Created by 姚凤 on 16/9/5.
//  Copyright © 2016年 姚凤. All rights reserved.
//

import UIKit

enum WebViewConfig{
    case scrollUnable            //禁止滑动
    case showProgress
    case jsInteractiveEnable
    case bounceUnable
}

class CommonWebViewController: UIViewController {

    var navTitle = String()
    var webUrl : URL?
    var htmlString : NSString?
    
    var wenbConfig : WebViewConfig?
    var dataDetectorTypes : UIDataDetectorTypes?{
        set{
            self.webView.dataDetectorTypes = (newValue)!
        }
        get{
            return self.dataDetectorTypes
        }
    }
    
    lazy var progressView : WEWebViewProgressView = {
        let progressBarHeight : CGFloat = 2.0
        let navigationBarBounds = self.navigationController?.navigationBar.bounds
        let barFrame = CGRect.init(x: 0, y: (navigationBarBounds?.size.height)! - progressBarHeight, width: (navigationBarBounds?.size.width)!, height: progressBarHeight)
        let progressView = WEWebViewProgressView.init(frame: barFrame)
         progressView.autoresizingMask = [.flexibleWidth,.flexibleTopMargin]
        return progressView
    }()
    
    private lazy var progressProxy : WEWebViewProgress = {
        let progressProxy = WEWebViewProgress.init(webViewProxyDelegate: self as UIWebViewDelegate, progressDelegate: self as WEWebViewProgressDelegate)
        return progressProxy
    }()
    
    private lazy var closeItem : UIBarButtonItem = {
        let closeItem = UIBarButtonItem.init(title: "关闭", style: .plain, target: self, action: #selector(rightItemAction))
        closeItem.tintColor = UIColor.white
        closeItem.setTitleTextAttributes([NSFontAttributeName:UIFont.boldSystemFont(ofSize: 16)], for: .normal)
        return closeItem
    }()
    
    private lazy var backItem : UIBarButtonItem = {
        let backItem = UIBarButtonItem.init(title: "返回", style: .plain, target: self, action: #selector(backItemAction))
        backItem.tintColor = UIColor.white
        backItem.setTitleTextAttributes([NSFontAttributeName:UIFont.boldSystemFont(ofSize: 16)], for: .normal)
        return backItem
    }()
    
    lazy var webView : UIWebView = {
        let webView = UIWebView.init(frame: self.view.bounds)
        webView.delegate = self
        return webView
    }()

    private var canReload : Bool?
    private var firstReload : Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = self.navTitle
        self.view.addSubview(self.webView)
        
        self.initConfigs()
        self.loadNavgationItem()
        if self.webUrl != nil {
            let requset = NSURLRequest(url: self.webUrl!)
            self.webView.loadRequest(requset as URLRequest)
        }else if (self.htmlString != nil) {
            self.webView.loadHTMLString(self.htmlString as! String, baseURL: nil)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.canReload == true {
            self.webView.reload()
            self.firstReload = !self.firstReload!
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if progressView != nil {
            self.progressView.removeFromSuperview()
        }
    }
    
    func rightItemAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func backItemAction() {
        if self.webView.canGoBack {
            self.webView.goBack()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func loadNavgationItem() {
        if self.presentationController != nil && (self.navigationController?.viewControllers.count)!<=1 {
            self.configNavigationCloseItem()
        }else{
            self.navigationItem.leftBarButtonItems = self.webView.canGoBack == true ? [self.backItem,self.closeItem] : [self.backItem]
        }
    }
    
    
    func initConfigs() {
        if self.wenbConfig == WebViewConfig.showProgress {
            self.webView.delegate = self.progressProxy
            self.navigationController?.navigationBar.addSubview(self.progressView)
        }
        
        if self.wenbConfig == WebViewConfig.bounceUnable {
            self.webView.scrollView.bounces = false
        }
        
        if self.wenbConfig == WebViewConfig.scrollUnable {
            self.webView.scrollView.isScrollEnabled = false
        }
    }
    
    func reloadSwitch() {
        self.canReload = true
    }
    
    func configNavigationCloseItem(){
        let closeItem = UIBarButtonItem.init(title: "关闭", style: .plain, target: self, action: #selector(rightItemAction))
        closeItem.tintColor = UIColor.white
        closeItem.setTitleTextAttributes([NSFontAttributeName:UIFont.boldSystemFont(ofSize: 16)], for: .normal)
        self.navigationController?.navigationItem.leftBarButtonItem = closeItem
    }
    
}

// MARK: 代理方法

extension CommonWebViewController : WEWebViewProgressDelegate,UIWebViewDelegate{
    func webViewProgress(_ webViewProgress: WEWebViewProgress, updateProgress: Float) {
        progressView.setProgressWithAnimated(progress: CGFloat(updateProgress), animated: true)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.loadNavgationItem()
        self.progressView.setProgressWithAnimated(progress: 1.0, animated: false)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.progressView.setProgressWithAnimated(progress: 1.0, animated: false)
    }
}
