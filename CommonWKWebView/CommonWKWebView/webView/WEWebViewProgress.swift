//
//  WEWebViewProgressView.swift
//  CommonWKWebView
//
//  Created by 姚凤 on 16/9/5.
//  Copyright © 2016年 姚凤. All rights reserved.
//

import UIKit

@objc protocol WEWebViewProgressDelegate :NSObjectProtocol {
    func webViewProgress(_ webViewProgress:WEWebViewProgress, updateProgress:Float) -> ();
}

typealias WEWebViewProgressBlock = (_ value:Float)->()

var completeRPCURLPath = "/njkwebviewprogressproxy/complete";

let NJKInitialProgressValue : Float = 0.1;
let NJKInteractiveProgressValue : Float = 0.5;
let NJKFinalProgressValue : Float = 0.9;

class WEWebViewProgress: NSObject {

    weak var progressDelegate : WEWebViewProgressDelegate?
    var webViewProxyDelegate : UIWebViewDelegate?
    var progressBlock : WEWebViewProgressBlock?
    
    
    var progress: Float{
        set{
            if newValue>progress || newValue==0 {
                self.progress = newValue;
                if ((progressDelegate?.responds(to: #selector(WEWebViewProgressDelegate.webViewProgress(_:updateProgress:)))) != nil) {
                    progressDelegate!.webViewProgress(self, updateProgress: newValue)
                }
                self.progressBlock!(newValue)
            }
        }
        get{
            return self.progress;
        }
    }
    
    
    fileprivate var loadingCount = 0
    fileprivate var maxLoadCount = 0
    fileprivate var currentUrl : URL?
    fileprivate var interactive = false
    
    
   convenience init(webViewProxyDelegate: UIWebViewDelegate ,progressDelegate: WEWebViewProgressDelegate) {
        self.init()
        self.webViewProxyDelegate = webViewProxyDelegate
        self.progressDelegate = progressDelegate
    }
    
    
    func startProgress(){
        if self.progress < NJKInitialProgressValue {
            self.progress = NJKInitialProgressValue
        }
    }
    
    func incrementProgress(){
        var progress = self.progress;
        let maxProgress = (self.interactive ? NJKFinalProgressValue:NJKInteractiveProgressValue);
        let remainPercent = self.loadingCount/self.maxLoadCount;
        let increment = (maxProgress - progress) * Float(remainPercent)
        progress += increment;
        progress = fmin(progress, maxProgress)
        self.progress = progress;
    }

    func compelectProgress(){
        self.progress = 1.0;
    }
    
    func reset() {
        maxLoadCount=0
        loadingCount=0
        interactive = false
        self.progress = 0.0
    }
}

extension WEWebViewProgress:UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.path==completeRPCURLPath {
            self.compelectProgress()
            return false;
        }
        
        var ret = true
        ret = (webViewProxyDelegate?.webView!(webView, shouldStartLoadWith: request, navigationType: navigationType))!
        
        
        var isFragmentJump = false
        if (request.url?.fragment) != nil {
            let nonFragmentUrl = request.url?.absoluteString.replacingOccurrences(of: "#".appending((request.url?.fragment)!), with: "")
            isFragmentJump = nonFragmentUrl==webView.request?.url?.absoluteString
        }
        
        let isTopLevelNavigation = request.mainDocumentURL==request.url
        
        let isHttpOrLocalFile = request.url?.scheme == "http" || request.url?.scheme == "file"
        if ret && !isFragmentJump && isHttpOrLocalFile && isTopLevelNavigation {
            currentUrl = request.url!
            self.reset()
        }

        return ret
    }
}
