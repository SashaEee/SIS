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
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { result, error in
                if error != nil,
                   self.emailTextField.text != "",
                   self.passwordTextField.text != ""

                   {
                    self.errorLabel.textColor = UIColor.red
                    self.errorLabel.text = "Неправильный логин или пароль"
                } else {
                    print("Jump to the next screen")
                    self.errorLabel.textColor = UIColor.green
                    self.errorLabel.text = "Вы успешно авторизовались"
                    SceneDelegate().checkAuth()
                }
            }
            }
        }
    @IBAction func questionPressed(_ sender: Any) {
        SlideCollectionViewCell().rootView(name: "RegisterViewController")
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
