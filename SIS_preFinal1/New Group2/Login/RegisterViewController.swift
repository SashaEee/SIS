//
//  RegisterViewController.swift
//  SIS
//
//  Created by Sasha on 7/15/21.

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import SwiftyJSON
import Alamofire

class RegisterViewController: UIViewController{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToHideKeyboard()
        photoImageView.layer.cornerRadius = 40
        photoImageView.layer.borderWidth = 0.5
    }
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
    }

    
    func upload(currentUserId: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = Storage.storage().reference().child("avatars").child(currentUserId)
        
        guard let imageData = photoImageView.image?.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            ref.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
    func authSfedu(emailUser: String){
        let user = "projectoffice"
        let password = "q90h5ju4"
        let usr = Auth.auth().currentUser
        

        let headers: HTTPHeaders = [.authorization(username: user, password: password)]
        
        //AF.request("https://httpbin.org/basic-auth/user/password", headers: headers)
        let url = "http://api.sync.ictis.sfedu.ru/find/student/email?email=" + emailUser
        //let url = "http://api.sync.ictis.sfedu.ru/find/student/email?email=azenkovskii@sfedu.ru"
        print ("url \(url)")
        AF.request(url,
                   headers: headers)
            .responseData { response in
                //debugPrint(response)
                //print(response["Welcome3"][1])
            }
            .responseJSON { response in

                let json = JSON(response.data as Any)
                print(json)
                guard let data = response.data else {return}
                do
                {
                    let student = try JSONDecoder().decode(UserData.self, from: data)
                    firstName = student.student.firstName
                    lastName = student.student.lastName
                    secondName = student.student.secondName
                    stGroup = student.student.stGroup
                    studID = student.student.studID
                    grade = String(student.student.grade)
                    isTeacher = student.student.isTeacher
                    levelLearn = student.student.levelLearn
                    print (UserData.self)
                    print(student)
                    AppDelegate().requestParse()
                }
                catch {
                    print("1")
                }
            }
        

    }
    
    func register(email: String?, password: String?, completion: @escaping (AuthResult) -> Void) {
        email2 = emailTextField.text
        
        guard Validators.isFilled(email: emailTextField.text,
                                  password: passwordTextField.text) else {
                                    completion(.failure(AuthError.notFilled))
                                    return
        }
        guard let email = email, let password = password else {
            completion(.failure(AuthError.unknownError))
            return
        }
        
        guard Validators.isSimpleEmail(email) else {
            completion(.failure(AuthError.invalidEmail))
            return
        }
        
        if (firstName != nil){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            self.upload(currentUserId: result.user.uid, photo: self.photoImageView.image!) { (myresult) in
                switch myresult {
                case .success(let url):
                    self.urlString = url.absoluteString
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: [
                        "firstname": firstName!,
                        "lastname": lastName!,
                        "studID": studID!,
                        "avatarURL": url.absoluteString,
                        "uid": result.user.uid,
                        "email": self.emailTextField.text!,
                        "uidDevice": UID!
                    ]) { (error) in
                        if let error = error {
                            completion(.failure(error))
                        }
                        completion(.success)
                        
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
            }

            
        }
        } else {self.showAlert(with: "Ошибка", and: "Неправильно введена почта sfedu")}
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        authSfedu(emailUser: emailTextField.text!)
        ProfileViewController().getUID()
        register(email: emailTextField.text, password: passwordTextField.text) { (result) in
            switch result {
            case .success:
                self.errorLabel.text = "Вы успешно зарегистрированы"
        
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
    @IBAction func photoButtonPressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
}
// MARK: - UIImagePickerControllerDelegate
extension RegisterViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        photoImageView.image = image
    }
}


