//
//  MicrosoftView.swift
//  SIS
//
//  Created by Sasha on 8/15/21.
//

import UIKit
import FirebaseAuth
import Firebase

var provider: OAuthProvider?
var authMicrosoft: Auth?


class MicrosoftView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func buttonTapped(_ sender: Any) {


         provider = OAuthProvider(providerID: "microsoft.com")


        provider?.customParameters = [
            "prompt": "consent",
                    "login_hint": "",
        ]

        provider?.scopes = ["mail.read", "calendars.read"]




        provider?.getCredentialWith(nil ) { credential, error in
            if error != nil {
                // Handle error.
            }

            print(credential?.provider)



            if let x = credential {
                authMicrosoft?.signIn(with: x) { authResult, error in
                    if error != nil {
                        // Handle error.
                    }


                    print(authResult?.additionalUserInfo?.profile)
                    print(authResult?.user.providerID)


                }
            } else {

            }

        }

    }
    
}
