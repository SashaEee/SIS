//
//  CallendarViewController.swift
//  SIS
//
//  Created by Sasha on 5/11/21.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON



class CallendarViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
        override func viewDidLoad() {
        passcode()
        super.viewDidLoad()
        let url = URL(string: "https://ictis.alex-b.me")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true

    }

    func shortNameFromName (_ fullName: String) -> String
    {
        let lowerCasedName = fullName.lowercased()
        let shortName = lowerCasedName.components(separatedBy: " ")
        return shortName.first! //Make sure shortName is not empty before force unwrapping it
    }
    func passcode(){
        Utilities.openSecurityPinPage()
    }

}
