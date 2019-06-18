//
//  ViewController.swift
//  Example
//
//  Created by maiGit on 2019/5/31.
//  Copyright © 2019 None. All rights reserved.
//

import UIKit
import WebSDK

class ViewController: UIViewController {

    private var tableView: UITableView?
    
    private lazy var urls:[String] = [
        "http://h5.luqianbao.top/wechat/quick_register/web_ldk_lqb_reg22/ldk",
        "http://mbapi.yanyuxuan.cn/cashloan-api/h5/xqd_v68/index.jsp",
        "http://t.cn/AiKIfLBR",
        "http://app.douniusz.com/yqjregister/index.html?channel=ledaik_1",
        "http://th.d2jie.cn/b2aEb2",
        "http://www.yinfangjie.com:8082/saas/index.html?appId=marketentry&marketAppId=com.fmd&extensionWay=0&wayName=MGHY&channelId=201905280000043&appName=%E5%88%86%E7%A7%92%E8%B4%B7",
        "http://www.fabu.pro/dcs/h5/653.html?channel=mghy",
        "http://xfjr.ledaikuan.cn/website/loanShopUpgrade/v2.0/index.html#/checkIn"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView.init(frame: self.view.bounds)
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "defaultsCell")
        tableView?.rowHeight = 50
        tableView?.delegate = self
        tableView?.dataSource = self
        self.view.addSubview(tableView!)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultsCell")
        cell?.textLabel?.text = urls[indexPath.row]
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AgreementViewController()
        vc.loadURL = urls[indexPath.row]
        
        let messages: [String: Selector?] = [
            "retry": nil,
            "share": nil,
            "login": nil,
            "shareTofriends": nil,
            "jsInterface": nil,
            "copyH5": nil,
            "openApp": nil,
            "h5Version": nil,
            "openPage": nil,
            "needPop": #selector(vc.loadWebView.needPopCallBack(_:)),
            "getPower": #selector(vc.loadWebView.getPowerCallBack(_:)),
            "showBarH5": nil,
            "openPageH5": nil,
            "shareUrlByH5": nil,
            "openDialogH5": nil,
            "openWechatH5": nil,
            "openPageByH5": nil,
            "getUserDataH5": #selector(vc.loadWebView.getUserDataCallBack(_:)),
            "shareUrlCallBack": nil
        ]

        vc.userContents = messages
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

