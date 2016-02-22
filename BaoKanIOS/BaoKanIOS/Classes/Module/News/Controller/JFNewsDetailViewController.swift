//
//  JFNewsDetailViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFNewsDetailViewController: UIViewController, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    /// 文章详情请求参数
    var articleParam: (classid: String, id: String)? {
        didSet {
            loadNewsDetail(articleParam!.classid, id: articleParam!.id)
        }
    }
    
    /// 详情页面模型
    var model: JFArticleDetailModel? {
        didSet {
            // 更新页面数据
            loadWebViewContent(model!)
        }
    }
    
    /// tableView
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("detailCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "detailCell")
        }
        cell?.contentView.addSubview(webView)
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return webView.height
    }
    
    /**
     加载webView内容
     
     - parameter model: 新闻模型
     */
    func loadWebViewContent(model: JFArticleDetailModel)
    {
        // 内容页html
        var html = ""
        html.appendContentsOf("<html>")
        html.appendContentsOf("<head>")
        html.appendContentsOf("<link rel=\"stylesheet\" href=\"\(NSBundle.mainBundle().URLForResource("style.css", withExtension: nil)!)\">")
        html.appendContentsOf("</head>")
        
        // body开始
        html.appendContentsOf("<body style=\"background:#F6F6F6\">")
        html.appendContentsOf("<div class=\"title\">\(model.title!)</div>")
        html.appendContentsOf("<div class=\"time\">\(model.lastdotime!.timeStampToString())</div>")
        html.appendContentsOf("\(model.newstext!)")
        html.appendContentsOf("</body>")
        
        html.appendContentsOf("</html>")
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    /**
     webView加载完成回调
     
     - parameter webView: 加载完成的webView
     */
    func webViewDidFinishLoad(webView: UIWebView) {
        
        var frame = webView.frame
        frame.size.height = webView.scrollView.contentSize.height
        webView.frame = frame
        webView.scrollView.scrollEnabled = false
        tableView.reloadData()
    }
    
    /**
     加载
     
     - parameter classid: 当前子分类id
     - parameter id:      文章id
     */
    func loadNewsDetail(classid: String, id: String)
    {
        let parameters = [
            "table" : "news",
            "classid" : classid,
            "id" : id,
        ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters) { (success, result, error) -> () in
            if success == true {
                if let successResult = result {
                    
                    print(successResult)
                    let content = successResult["data"]["content"].dictionaryValue
                    
                    let dict = [
                        "title" : content["title"]!.string!,          // 文章标题
                        "username" : content["username"]!.string!,    // 用户名
                        "lastdotime" : content["lastdotime"]!.string!,// 最后编辑时间戳
                        "newstext" : content["newstext"]!.string!,    // 文章内容
                        "titleurl" : "\(BASE_URL)\(content["titleurl"]!.string!)", // 文章url
                        "id" : content["id"]!.string!,                // 文章id
                        "classid" : content["classid"]!.string!,      // 当前子分类id
                    ]
                    
                    self.model = JFArticleDetailModel(dict: dict)
                }
            } else {
                print("error:\(error)")
            }
        }
    }
    
    /// webView
    lazy var webView: UIWebView = {
        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        webView.delegate = self
        return webView
    }()
    
}
