//
//  CallendarViewController.swift
//  SIS
//
//  Created by Sasha on 5/11/21.
//

import UIKit
import WebKit

class CallendarViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://ictis.alex-b.me")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    }

