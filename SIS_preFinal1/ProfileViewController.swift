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
    
    override func viewDidLoad() {
        firstNameLabel.alpha = 0
        lastNameLabel.alpha = 0
        middleNameLabel.alpha = 0
        groupLabel.alpha = 0
    Auth.auth().addStateDidChangeListener { [self] (auth, user) in
                if user == nil{
                    print("AAAAAAAAAAAAAAAAAAAAAA")
                    self.showModalAuth()
                    
                } else {
                    print("BBBBBBBBBBBBBBBBBBB")
                    showUserData()
                    getFireBase()
                }
    }

    super.viewDidLoad()

    // Do any additional setup after loading the view.
}
    
    
    
    
    func showUserData(){
        let user = Auth.auth().currentUser
        if let user = user {
          // The user's ID, unique to the Firebase project.
          // Do NOT use this value to authenticate with your backend server,
          // if you have one. Use getTokenWithCompletion:completion: instead.
          let uid = user.uid
          let email = user.email
            firstNameLabel.alpha = 1
            firstNameLabel.text=email
          let photoURL = user.photoURL
        }
    }
    func getFireBase(){
        let user = Auth.auth().currentUser
        if let user = user {
          // The user's ID, unique to the Firebase project.
          // Do NOT use this value to authenticate with your backend server,
          // if you have one. Use getTokenWithCompletion:completion: instead.
             let uid = user.uid
            print(user)
            let docRef = db.collection("users").document(uid)
            docRef.getDocument(source: .cache) { (document, error) in
              if let document = document {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Cached document data: \(dataDescription)")
              } else {
                print("Document does not exist in cache")
              }
            }
            }
    }
    
func showModalAuth(){
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let newvc = storyBoard.instantiateViewController(withIdentifier: "NavAuth")
        self.present(newvc, animated:true, completion:nil)
}


}
