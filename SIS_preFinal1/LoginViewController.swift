//
//  LoginViewController.swift
//  SIS
//
//  Created by Sasha on 5/9/21.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0

    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { result, error in
            if error != nil,
               self.emailTextField.text != "",
               self.passwordTextField.text != ""

               {
                self.errorLabel.alpha = 1
                self.errorLabel.textColor = UIColor.red
                self.errorLabel.text = "Неправильный логин или пароль"
            } else {
                print("Jump to the next screen")
                self.errorLabel.alpha = 1
                self.errorLabel.textColor = UIColor.green
                self.errorLabel.text = "Вы успешно авторизовались"
            }
        }
        }
    }
