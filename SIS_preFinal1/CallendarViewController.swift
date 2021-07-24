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


var rasp: [[String]]?
var JSON1: String?
struct Callendar: Decodable {
    let table: Table
    let weeks: [Int]
}


// MARK: - Table
struct Table: Decodable{
    let type, name: String
    let week: Int
    let group: String
    let table: [[String]]
    let link: String
}
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
