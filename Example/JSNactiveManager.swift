//
//  JSNactiveManager.swift
//  WebDemo
//
//  Created by maiGit on 2019/5/31.
//  Copyright © 2019 上海麦广互娱文化传媒股份有限公司. All rights reserved.
//

import UIKit
import WebKit

/**
 Swift中的扩展，只能声明计算属性，不能声明赋值属性
 */
public extension WKWebView {
    @objc  func getUserDataCallBack(_ message: Any?) {
        print("getUserDataCallBack: \(String(describing: message))")
    }
    
    @objc func getPowerCallBack(_ message: Any?) {
        print("getPowerCallBack: \(String(describing: message))")
    }
    
    @objc func needPopCallBack(_ message: Any?) {
        print("needPopCallBack: \(String(describing: message))")
    }
    
    @objc func h5VersionCallBack(_ message: Any?) {
        guard let version = message as? String else {  return }
        UserDefaults.standard.set(version, forKey: "h5_version")
    }
    
    
//    private func
}
