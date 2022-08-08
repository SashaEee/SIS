//
//  AuthInViewController.swift
//  SIS
//
//  Created by Sasha on 7/15/21.
//

import UIKit
import FirebaseAuth
import Firebase


class AuthInViewController: UIViewController {
    
        var window: UIWindow?
        var provider: OAuthProvider?
        var authMicrosoft: Auth?


        @IBOutlet weak var emailTextField: UITextField!
        @IBOutlet weak var passwordTextField: UITextField!
        @IBOutlet weak var loginButton: UIButton!
        @IBOutlet weak var errorLabel: UILabel!
        @IBOutlet weak var questionButton: UIButton!
    

        override func viewDidLoad() {
            super.viewDidLoad()
//            errorLabel.alpha = 0
            addTapGestureToHideKeyboard()
            emailTextField.delegate = self
            passwordTextField.delegate = self
                }

                func addTapGestureToHideKeyboard() {
                    let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
                    view.addGestureRecognizer(tapGesture)
                }
        
        func checkValid() -> String? {
            if emailTextField.text == "" ||
             passwordTextField.text == "" ||
             emailTextField.text == nil ||
             passwordTextField.text == nil {
                print("All Good")
                return "Проверьте корректность введенных данных"
             }
            return nil
        }
        
        @IBAction func loginButtonPressed(_ sender: Any) {
            let error = checkValid()
            
            if error != nil {
                self.errorLabel.textColor = UIColor.red
                errorLabel.text = error
            } else {
                authMicro()
            }
        }
    func openView(id: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                  let nextVC = storyboard.instantiateViewController(identifier: id)
                  nextVC.modalPresentationStyle = .fullScreen
                  nextVC.modalTransitionStyle = .crossDissolve

        self.present(nextVC, animated: true, completion: nil)

    }
    @IBAction func closeButton(_ sender: Any) {
        openView(id: "AUTH")
    }
    @IBAction func questionPressed(_ sender: Any) {
        SlideCollectionViewCell().rootView(name: "RegisterViewController")
    }
    @IBAction func questionButton(_ sender: Any) {
        openView(id: "RegisterViewController")
    }
    
    func authMicro(){
        
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
               print("Error 2")
               print (error)
           }

           print(credential?.provider)
           print (error)

           Auth.auth().signIn(withEmail: self.emailTextField.text!, password: "12345678"){ result, error in
               if error != nil,
                  self.emailTextField.text != "",
                  self.passwordTextField.text != ""

                  {
                   self.errorLabel.textColor = UIColor.red
                   self.errorLabel.text = "Неправильный логин или пароль"
               } else {
                   email2 = self.emailTextField.text!
                   AppDelegate().getFireBase()
                   print("Jump to the next screen")
                   self.errorLabel.textColor = UIColor.green
                   self.errorLabel.text = "Вы успешно авторизовались"
                   AppDelegate().authSfedu()
                   self.openView(id: "tabbar")
               }
           }

           if let x = credential {
               self.authMicrosoft?.signIn(with: x) { authResult, error in
                   if error != nil {
                       print("Error 1")
                       print (error)
                   }


                   print(authResult?.additionalUserInfo?.profile)
                   print(authResult?.user.providerID)
                   print(authResult?.user.email)


               }
           } else{

           }

       }

    }
}
extension AuthInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if (emailTextField.text?.isEmpty ?? true) {
            passwordTextField.isEnabled = false
            textField.resignFirstResponder()
        }
        else if textField == emailTextField {
            passwordTextField.isEnabled = true
            passwordTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            loginButtonPressed((Any).self)

        }

        return true
    }
}
