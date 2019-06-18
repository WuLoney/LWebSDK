//
//  AgreementViewController.swift
//  CJWebSDK
//
//  Created by maiGit on 2019/5/31.
//  Copyright © 2019 上海麦广互娱文化传媒股份有限公司. All rights reserved.
//

import UIKit
import WebKit

public class AgreementViewController: UIViewController {
    
    //    MARK: - 懒加载 UI元素
    public lazy var loadWebView: WKWebView = {
        let configuration = WKWebViewConfiguration.init()
        let webView = WKWebView.init(frame: .zero, configuration: configuration)
        webView.backgroundColor = UIColor.white
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView.init(progressViewStyle: UIProgressView.Style.default)
        view.progressTintColor = UIColor.white
        view.trackTintColor = UIColor.black
        return view
    }()
    
    //    MARK: - 页面加载元素
    private let keyPath = "estimatedProgress"
    private var isObserver = false
    
    //    MARK: - ["消息标识"] 多个消息标识，中间用逗号隔开
    public var userContents: [String: Selector?] = [:]
    
    //    MARK: - 加载URL
    public var loadURL: String!
    
    
    override public func loadView() {
        super.loadView()
        self.view = loadWebView
        loadWebView.frame = self.view.frame
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(progressView)
        loadWebView.uiDelegate = self
        loadWebView.navigationDelegate = self
        progressView.frame = CGRect(x: 0, y: 0, width:  self.view.frame.width, height: 2)
        
        //        userContents["copyH5"] = ""
        //        userContents["openPageH5"] = ""
        //        userContents["shareUrlByH5"] = ""
        //        userContents["openDialogH5"] = ""
        //        userContents["openWechatH5"] = ""
        //        userContents["openPageByH5"] = ""
        //
        //        userContents["getUserDataH5"] = "getUserDataCallBack"
        
        
        // 添加原生与H5交互事件
        for(_, value) in userContents.enumerated() {
            loadWebView.configuration.userContentController.add(self, name: value.key)
        }
        
        
        // 1. 判断链接中是否存在中文，如果存在中文，则将链接进行编码
        for (_, url) in loadURL.enumerated() {
            // 链接存在中文
            if url >= "\u{4E00}" && url <= "\u{9FA5}" {
                let charSet = CharacterSet.urlQueryAllowed
                if let encodingURL = loadURL.addingPercentEncoding(withAllowedCharacters: charSet) {
                    self.loadURL = encodingURL
                }
            }
        }
        
        if let url = URL.init(string: self.loadURL) {
            let request = URLRequest.init(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
            loadWebView.load(request)
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isObserver = true
        loadWebView.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isObserver {
            loadWebView.removeObserver(self, forKeyPath: keyPath)
            isObserver = false
        }
    }
    
    /// 监听进度条
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == self.keyPath {
            progressView.alpha = 1.0
            progressView.setProgress(Float(loadWebView.estimatedProgress), animated: true)
            if self.loadWebView.estimatedProgress >= 1.0 {
                self.hideProgressView()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func hideProgressView(_ duration: TimeInterval = 0.3, delay: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
            self.progressView.alpha = 0.0
        }, completion: { (finished) in
            self.progressView.setProgress(0.0, animated: false)
        })
    }
}


// MARK: - WKNavigationDelegateWKUIDelegate H5网页导航加载协议
extension AgreementViewController: WKNavigationDelegate, WKUIDelegate {
    
    //    MARK: - 链接开始加载调用
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //开始加载的时候，让进度条显示
        progressView.isHidden = false
        progressView.progress = 0
        progressView.alpha = 1.0
    }
    
    //    MARK: - 链接加载完成调用
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    //    MARK: - 链接加载报错调用
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    //    MARK: - 网页是否允许被跳转
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let requestURL = navigationAction.request.url?.absoluteString {
            if requestURL.isURLTransform() {
                if UIApplication.shared.canOpenURL(navigationAction.request.url!) {
                    if #available(iOS 10.0, *)  {
                        UIApplication.shared.open(navigationAction.request.url!, completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(navigationAction.request.url!)
                    }
                    decisionHandler(.cancel)
                }
            }
        }
        decisionHandler(.allow)
    }
    
    //   MARK: -  打开新窗口委托
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        //如果目标主视图不为空,则允许导航
        if navigationAction.targetFrame?.isMainFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}


// MARK: - WKScriptMessageHandler 原生与JS交互协议
extension AgreementViewController: WKScriptMessageHandler {
    //    MARK: - JS与原生产生交互时，调用
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 获取到JS发送的消息，每一条消息在 userContents 数组中只会存在一条匹配
        let jsMessage = userContents.map { (key, value) -> String? in
            if key == message.name {  return key  };  return nil  }.first!
        if jsMessage != nil {
            if let sel = userContents[jsMessage!], sel != nil {
                if self.loadWebView.responds(to: sel!) {
                    self.loadWebView.perform(sel!, with: message.body)
                }
            }
        }
    }
}



extension String {
    
    // 判断URl链接是否应该重新打开一个页面
    func isURLTransform() -> Bool {
        if self.starts(with: "alipays://") ||
            self.starts(with: "alipay://") ||
            self.contains("action=download") ||
            self.contains("itunes.apple.com") ||
            self.contains("download") ||
            self.contains("provision")  {
            return true
        }
        return false
    }
}
