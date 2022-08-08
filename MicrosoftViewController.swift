import UIKit
import Firebase
import FirebaseAuth

class MicrosoftViewController: UIViewController {
    
    var provider: OAuthProvider?
    var authMicrosoft: Auth?
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func buttonTapped(_ sender: Any) {


         provider = OAuthProvider(providerID: "microsoft.com")


        provider?.customParameters = [
            "prompt": "consent",
            "login_hint": emailTextField.text!,
            "grant_type": passwordTextField.text!,
            "password": passwordTextField.text!
        ]

        provider?.scopes = ["mail.read", "calendars.read"]




        provider?.getCredentialWith(nil ) { credential, error in
            if error != nil {
                print(error)
            }

            print(credential?.provider)
            
            
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: "12345678")

            if let x = credential {
                self.authMicrosoft?.signIn(with: x) { authResult, error in
                    if error != nil {
                        print ("error")
                    }


                    print(authResult?.additionalUserInfo?.profile)
                    print(authResult?.user.providerID)
                    print(error)


                }
            } else{
                print ("else")
            }

        }

    }
}
