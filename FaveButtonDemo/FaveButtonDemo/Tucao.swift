//
//  Tucao.swift
//  FaveButtonDemo
//
//  Created by andy on 24/10/2019.
//  Copyright © 2019 Jansel Valentin. All rights reserved.
//

import UIKit
import WebKit
import Foundation
class Tucao : UIViewController, WKNavigationDelegate{
    var webView: WKWebView!
    override func viewDidLoad() {
        webView = WKWebView()
        webView.navigationDelegate = self
        //webView.delegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var request = URLRequest(url: URL(string: "https://support.qq.com/product/96548")!)
        request.httpMethod = "POST"
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        request.allHTTPHeaderFields = headers
        let postData = NSMutableData(data: "nickname=nihao&avatar=https://www.google.com/url?sa=i&source=images&cd=&cad=rja&uact=8&ved=2ahUKEwjKqfXgvrTlAhUoIbcAHf2QBMUQjRx6BAgBEAQ&url=%2Furl%3Fsa%3Di%26source%3Dimages%26cd%3D%26ved%3D%26url%3Dhttps%253A%252F%252Fwww.stylist.co.uk%252Flife%252Fscientists-have-proven-whether-dogs-or-cats-love-their-owners-more%252F70818%26psig%3DAOvVaw20vARBFEphTnbyY1OskfEE%26ust%3D1571992550271457&psig=AOvVaw20vARBFEphTnbyY1OskfEE&ust=1571992550271457&openid=sdfjdksf22ddds".data(using: String.Encoding.utf8)!)
        let parameters: [String: Any] = [
            "openid": 123213
        ]
        request.httpBody = postData as Data
//         URLSession(configuration: .default).dataTask(with: request) { (data, response, error) in
//            if let data = data {
//                print(String(decoding: data, as: UTF8.self))
//            }
//        }.resume()
        webView.load(request)
              // webView.allowsBackForwardNavigationGestures = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("finish")
//        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
//                                   completionHandler: { (html: Any?, error: Error?) in
//            print(html)
//        })
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("error")
    }
    
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
