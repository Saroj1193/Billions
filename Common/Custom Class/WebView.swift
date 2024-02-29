//
//  Webview.swift
//  URfeed
//
//  Created by Tristate on 3/3/20.
//  Copyright © 2020 Tristate Technology. All rights reserved.
//

import Foundation

import UIKit
import WebKit

class WebView: UIView {
    
    @objc var webKit = WKWebView()
    var delegate : webViewDataLoaded?
    var vc = BaseViewController()
    
    var url : String = ""{
        didSet{
            guard let urlForLoad : URL = URL(string: url) else{
                return
            }
            webKit.load(URLRequest(url: urlForLoad))
        }
    }
    
    var htmlContent : String = ""{
        didSet{
            webKit.loadHTMLString(htmlContent, baseURL: nil)
        }
    }
    var finishCompletion = {() -> Void in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        webKit.uiDelegate = self
        webKit.navigationDelegate = self
        self.addSubview(webKit)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        webKit.frame = self.bounds
    }
    
    func complationOnLoadingFinish(_ complation:@escaping (() -> Void)) {
        self.finishCompletion = complation
    }
    
    func styledHTMLwithHTML(_ HTML: String) -> String {
//        \(GlobalFunction.overrideFontSize(fontSize:30))
        let style: String = "<meta charset=\"UTF-8\"><style> body { font-family: 'Roboto-Regular'; font-size: 40; color: #FFFFFFF} b {font-family: 'MarkerFelt-Wide'; }</style>"
        return "\(style)\(HTML)"
       
    }
}

@objc protocol webViewDataLoaded : NSObjectProtocol{
    func webViewDataLoaded(webview:WKWebView)
    @objc optional func webViewRequestLoad(shouldStartLoadWith request: URLRequest,requestData : Dictionary<String,Any>)
}

extension WebView {
    
    func getUrlParameters(_ url: String) -> [String : Any] {
        var url = url
        var params: [String : Any] = [:]
        let arrUrlData = url.components(separatedBy: "?")
        if arrUrlData.count >= 2{
            url = arrUrlData.last ?? ""
            let arr = url.components(separatedBy: "&")
            for param: String? in  arr{
                if let param = param{
                    let arrData = param.components(separatedBy: "=")
                    if let key = arrData.first,let value = arrData.last{
                        params[key] = value
                    }else{
                        
                    }
                }else{
                    break
                }
            }
        }else{
            
            
        }
        return params
    }
}

@objc protocol webVideDataLoaded : NSObjectProtocol{
    func webViewDataLoaded(webview:UIWebView)
    @objc optional func webViewRequestLoad(shouldStartLoadWith request: URLRequest,requestData : Dictionary<String,Any>)
}

extension WebView : WKUIDelegate,WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        vc.hideSpinner()
        guard let delegate = delegate else {
            return
        }
        delegate.webViewDataLoaded(webview: self.webKit)
    }
    
    
    func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation!){
        vc.showSpinner()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlRquest = navigationAction.request
        guard let url = urlRquest.url else {
            return
        }
        if let isValid = (delegate?.responds(to: #selector(delegate?.webViewRequestLoad(shouldStartLoadWith:requestData:)))),isValid {
            delegate?.webViewRequestLoad!(shouldStartLoadWith: urlRquest, requestData: getUrlParameters("\(url)"))
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        vc.hideSpinner()
        if (navigation != nil) {
            let urlWebView = NSURL(string: url)
            if let domain = urlWebView?.host{
                let subStrings = domain.components(separatedBy: ".")
                           var domainName = ""
                           let count = subStrings.count
                           if count > 2 {
                               domainName = subStrings[count - 2] + "." + subStrings[count - 1]
                               let replaced = domain.replacingOccurrences(of: domainName, with: "com")
                            let urlForLoad:URL = URL(string: replaced)!
                               webKit.load(URLRequest(url: urlForLoad))

                           } else if count == 2 {
                               domainName = domain
                           }
            }
        }else{
          vc.view.makeToast(error.localizedDescription)
        }
    }
}

