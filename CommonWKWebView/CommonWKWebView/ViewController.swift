//
//  ViewController.swift
//  CommonWKWebView
//
//  Created by 姚凤 on 16/9/5.
//  Copyright © 2016年 姚凤. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton.init(frame: CGRect.init(x: 100, y: 100, width: 100, height: 100))
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
        self.view.addSubview(button)
    }

    func clickAction() {
        let  web = CommonWebViewController()
        web.navTitle = "百度"
        web.webUrl = NSURL(string: "http://www.baidu.com") as URL?
        self.navigationController?.pushViewController(web, animated: true)
    }


}

