//
//  ProfileViewController.swift
//  SIS
//
//  Created by Sasha on 5/10/21.
//

import UIKit
import Firebase

let db = Firestore.firestore()


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var middleNameLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    var userID: String = ""
    var userName: String = ""

        
    override func viewDidLoad() {
        if (firstNameLabel.text == "Имя") {
          //  signOutButton.setTitleTextAttributes("Войти", for: .Normal)

        deleteLabel()
        
        checkAuth()
        } else {
         //   signOutButton.setTitleTextAttributes("Выйти", for: .Normal)
            
        }
    getUID()
    super.viewDidLoad()

    // Do any additional setup after loading the view.
}
    
    @IBAction func signOutPressed(_ sender: Any) {
        print("A")
        signOut()
    }
    @IBAction func а(_ sender: Any) {
     //   signOutButton.titleLabel?.text = "Some text”
        print("B")
        signOut()
        deleteLabel()
        checkAuth()
    }
    

    func getFireBase(){
        let user = Auth.auth().currentUser
        if let user = user {
            let email = user.email
            print(user)
            var docRef = db.collection("users").whereField("email", isEqualTo: email!)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            self.firstNameLabel.text = document.get("firstname") as? String
                            self.lastNameLabel.text = document.get("lastname") as? String
                            self.middleNameLabel.text = document.get("middlename") as? String
                            self.groupLabel.text = document.get("group") as? String
                            self.showLabel()

                        }
                        
                    }
            }
        }
    }
    
func showModalAuth(){
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let newvc = storyBoard.instantiateViewController(withIdentifier: "NavAuth")
        self.present(newvc, animated:true, completion:nil)
}
    
    func showLabel(){
        self.firstNameLabel.alpha = 1
        self.lastNameLabel.alpha = 1
        self.middleNameLabel.alpha = 1
        self.groupLabel.alpha = 1
    }
    func deleteLabel(){
        firstNameLabel.alpha = 0
        lastNameLabel.alpha = 0
        middleNameLabel.alpha = 0
        groupLabel.alpha = 0
    }
    func checkAuth(){
        Auth.auth().addStateDidChangeListener { [self] (auth, user) in
                if user == nil{
                    print("Пользователь не авторизован")
                    self.showModalAuth()
                    
                } else {
                    print("User is auth")
                    getFireBase()
                }
    }
    }
    func signOut(){
        print ("Выход выполнен")
        let firebaseAuth = Auth.auth()
       do {
         try firebaseAuth.signOut()
       } catch let signOutError as NSError {
         print ("Error signing out: %@", signOutError)
       }
         
    }
    func getUID(){
        if let identifierForVendor = UIDevice.current.identifierForVendor {
            print("UID вашего устройства: ",identifierForVendor.uuidString)
        }
    }
}
