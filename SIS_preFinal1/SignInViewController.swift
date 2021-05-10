//
//  SignInViewController.swift
//  SIS
//
//  Created by Sasha on 5/9/21.
//

import UIKit
import FirebaseAuth
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var groupTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        addTapGestureToHideKeyboard()
            }

            func addTapGestureToHideKeyboard() {
                let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
                view.addGestureRecognizer(tapGesture)
            }

    func checkValid() -> String? {
        if firstNameTextField.text == "" ||
         lastNameTextField.text == "" ||
         emailTextField.text == "" ||
         passwordTextField.text == "" ||
         middleNameTextField.text! == "" ||
         groupTextField.text! == "" ||
         firstNameTextField.text == nil ||
         lastNameTextField.text == nil ||
         emailTextField.text == nil ||
         passwordTextField.text == nil ||
         middleNameTextField.text == nil ||
         groupTextField.text == nil {
            print("All Good")
            return "Проверьте корректность введенных данных"
         }
        return nil
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        
        
        let error = checkValid()
        
        if error != nil {
            errorLabel.alpha = 1
            self.errorLabel.textColor = UIColor.red
            errorLabel.text = error
        } else {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
                if error != nil {
                    self.errorLabel.textColor = UIColor.red
                    self.errorLabel.text = "\(String(describing: error?.localizedDescription))"
                } else {
                    let db = Firestore.firestore()
                    db .collection("users").addDocument(data: [
                        "email": self.emailTextField.text!,
                        "firstname": self.firstNameTextField.text!,
                        "lastname": self.lastNameTextField.text!,
                        "middlename": self.middleNameTextField.text!,
                        "group": self.groupTextField.text!,
                        "uid": result!.user.uid
                    ]) { error in
                        if error != nil {
                            self.errorLabel.textColor = UIColor.red
                            self.errorLabel.text = "Error saving user in database"
                        }
                    }
                    
                    
                    print("Jump to the next screen")
                    self.errorLabel.alpha = 1
                    self.errorLabel.textColor = UIColor.green
                    self.errorLabel.text = "Вы успешно зарегистрированы"
                }
            } //else
                    
                }
            }
        }
