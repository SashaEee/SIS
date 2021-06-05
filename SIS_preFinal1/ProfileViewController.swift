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
    
    class ExpensiveObjectClass {
        var firstName: String?
        var lastName: String?
        var bio: String = "I ♡ Swift!"
    }


    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var middleNameLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    var userID: String = ""
    var userName: String = ""


        
    override func viewDidLoad() {

        if (firstNameLabel.text == "Имя") {
            //signOutButton.title = "Войти"

        deleteLabel()
        
        checkAuth()
        } else {
           //signOutButton.title = "Выйти"

        }
    getUID()
    super.viewDidLoad()

    // Do any additional setup after loading the view.
}
    

    @IBAction func а(_ sender: Any) { //нажимаем на кнопку выхода
        print("B")
        signOut()
        deleteLabel()
        checkAuth()
    }
    

    func getFireBase(){ //Получаем данные с FireBase
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
    
func showModalAuth(){ //Показать окно авторизации/регистрации
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let newvc = storyBoard.instantiateViewController(withIdentifier: "NavAuth")
        self.present(newvc, animated:true, completion:nil)
}
    
    func showLabel(){ //показываем данные
        self.firstNameLabel.alpha = 1
        self.lastNameLabel.alpha = 1
        self.middleNameLabel.alpha = 1
        self.groupLabel.alpha = 1
    }
    func deleteLabel(){ //скрываем данные
        firstNameLabel.alpha = 0
        lastNameLabel.alpha = 0
        middleNameLabel.alpha = 0
        groupLabel.alpha = 0
    }
    func checkAuth(){ //проверяем авторизирован бользователь или нет
        Auth.auth().addStateDidChangeListener { [self] (auth, user) in
                if user == nil{
                    print("Пользователь не авторизован")
                    //signOutButton.title = "Войти"
                    self.showModalAuth()
                    
                } else {
                    print("User is auth")
                    getFireBase()
                    //signOutButton.title = "Выйти"
                }
    }
    }
    func signOut(){ //выход из аккаунта
        print ("Выход выполнен")
        let firebaseAuth = Auth.auth()
       do {
         try firebaseAuth.signOut()
       } catch let signOutError as NSError {
         print ("Error signing out: %@", signOutError)
       }
         
    }
    func getUID(){ //получаем UID устройства
        if let identifierForVendor = UIDevice.current.identifierForVendor {
            print("UID вашего устройства: ",identifierForVendor.uuidString)
        }
    }
    func cache() {
        let cache = NSCache<NSString, ExpensiveObjectClass>()
        let myObject: ExpensiveObjectClass

        if let cachedVersion = cache.object(forKey: "CachedObject") {
            // use the cached version
            myObject = cachedVersion
        } else {
            // create it from scratch then store in the cache
            myObject = ExpensiveObjectClass()
            cache.setObject(myObject, forKey: "CachedObject")
        }
        //ExpensiveObjectClass.init().firstName
    }

}
