//
//  ProfileViewController.swift
//  SIS
//
//  Created by Sasha on 5/10/21.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
let db = Firestore.firestore()
// MARK: - Welcome6
struct UserData: Decodable{
    let student: Student
}

// MARK: - Student
struct Student: Decodable {
    let formLearn, studID, speciality, levelLearn: String
    let secondName, stGroup, lastName: String
    let grade: Int
    let firstName, email: String
    let isTeacher: Int
}


class ProfileViewController: UIViewController, UITableViewDelegate {
    


    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    @IBOutlet weak var UserImage: UIImageView!
    var userID: String = ""
    var userName: String = ""


        
    override func viewDidLoad() {
        UserImage.image = avatar
//        let tableView = UITableView.init(frame: .zero, style: UITableView.Style.grouped)
        if (firstNameLabel.text == "Имя") {

        deleteLabel()
        
        checkAuth()
        } else if (firstNameLabel.text == "Name"){
            
            deleteLabel()
            
            checkAuth()
            

        }
        else {
           //signOutButton.title = "Выйти"

        }
    getUID()
    design()
    super.viewDidLoad()

    // Do any additional setup after loading the view.
}
    func transliterate(nonLatin: String) -> String {
        return nonLatin
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripDiacritics, reverse: false)?
            .lowercased()
            .replacingOccurrences(of: " ", with: "-") ?? nonLatin
    }

    @IBAction func а(_ sender: Any) { //нажимаем на кнопку выхода
        print("B")
        signOut()
        deleteLabel()
        checkAuth()
    }
    

    func getFireBase(){ //Получаем данные с FireBase
        showActivityIndicator()
        if (firstName != nil){
            firstNameLabel.text = firstName! + " " + lastName!
            if (isTeacher! != 1){
            var group1 = levelLearn![(levelLearn?.startIndex)!]
            if (group1 == "Б"){ group1 = "б"}
            if (group1 == "М"){ group1 = "м"}
            if (group1 == "А"){ group1 = "а"}
            if (group1 == "С"){ group1 = "с"}
            //let group2 = formLearn!
            groupLabel.text = "КТ" + "\(group1)" + "о" + grade! + " - " + stGroup!
                showLabel()
                hideActivityIndicator()
        } else {
            groupLabel.text = "Преподаватель"
            showLabel()
            hideActivityIndicator()
        }
            let lang = self.checkLang()
            if (lang != "ru"){
                self.firstNameLabel.text = self.transliterate(nonLatin: self.firstNameLabel.text!)
                self.groupLabel.text = self.transliterate(nonLatin: self.groupLabel.text!)
            }
        }
        else {
            let user = Auth.auth().currentUser
            if let user = user {
                let email = user.email
                print(user)
            db.collection("users").whereField("email", isEqualTo: email!)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                self.firstNameLabel.text = document.get("firstname") as? String
                                self.firstNameLabel.text! += " " + (document.get("lastname") as? String)!
                                self.groupLabel.text = document.get("group") as? String
                                self.showLabel()
                                self.hideActivityIndicator()
                                let lang = self.checkLang()
                                if (lang != "ru"){
                                    self.firstNameLabel.text = self.transliterate(nonLatin: self.firstNameLabel.text!)
                                    self.groupLabel.text = self.transliterate(nonLatin: self.groupLabel.text!)
                                }
                            }
                            
                        }
                }
            }
        }
    }
func checkLang() -> String{
    let preferredLanguage = Locale.preferredLanguages[0] as String
    print (preferredLanguage) //en-US

    let arr = preferredLanguage.components(separatedBy: "-")
    let deviceLanguage = arr.first
    print (deviceLanguage) //en
    return deviceLanguage!
}
func showModalAuth(){ //Показать окно авторизации/регистрации
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let newvc = storyBoard.instantiateViewController(withIdentifier: "AuthInViewController")
        self.present(newvc, animated:true, completion:nil)
}
    
    func showLabel(){ //показываем данные
        self.firstNameLabel.alpha = 1
        self.groupLabel.alpha = 1
        self.UserImage.alpha = 1
    }
    func deleteLabel(){ //скрываем данные
        firstNameLabel.alpha = 0
        groupLabel.alpha = 0
        UserImage.alpha = 0
    }
    func checkAuth(){ //проверяем авторизирован бользователь или нет
        Auth.auth().addStateDidChangeListener { [self] (auth, user) in
                if user == nil{
                    print("Пользователь не авторизован")
                    //signOutButton.title = "Войти"
                    self.showModalAuth()
                    
                } else {
                    print("User is auth")
                    print (firstName)
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
    func getUID() { //получаем UID устройства
        if let identifierForVendor = UIDevice.current.identifierForVendor {
            print("UID вашего устройства: ",identifierForVendor.uuidString)
            UID = identifierForVendor.uuidString
        }
    }
    func showActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicator.backgroundColor = UIColor(red:0.16, green:0.17, blue:0.21, alpha:0.8)
        activityIndicator.layer.cornerRadius = 6
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.startAnimating()
        //UIApplication.shared.beginIgnoringInteractionEvents()

        activityIndicator.tag = 100 // 100 for example

        // before adding it, you need to check if it is already has been added:
        for subview in view.subviews {
            if subview.tag == 100 {
                print("already added")
                return
            }
        }

        view.addSubview(activityIndicator)
    }

    func hideActivityIndicator() {
        let activityIndicator = view.viewWithTag(100) as? UIActivityIndicatorView
        activityIndicator?.stopAnimating()

        // I think you forgot to remove it?
        activityIndicator?.removeFromSuperview()

        //UIApplication.shared.endIgnoringInteractionEvents()
}
    func design(){
        UserImage.frame.size = CGSize(width: 100, height: 100) //размеры новой картинки
        UserImage.layer.cornerRadius = 45
        UserImage.clipsToBounds = true
        UserImage.layer.borderColor = UIColor.white.cgColor // цвет рамки
        UserImage.layer.borderWidth = 1.5 // толщина рамки

    }
}
