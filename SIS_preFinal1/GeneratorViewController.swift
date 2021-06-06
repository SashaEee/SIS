//
//  FirstViewController.swift
//  QR Codes
//
//  Created by Sasha
//

import UIKit
import CoreImage
import Firebase
import ScreenGuard


let dbs = Firestore.firestore()



class GeneratorViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var correctionLevelSegmentControl: UISegmentedControl!
    @IBOutlet weak var reButton: UIButton!
    var textUser: String = "Пользователь не авторизован"
    var myTimer: Timer!
    @objc
       func refresh() {
        getFireBase()
       }
    
    override func viewDidLoad() {
        ScreenGuardManager.shared.screenRecordDelegate = self
        ScreenGuardManager.shared.listenForScreenRecord()
        ScreenGuardManager.shared.guardScreenshot(for: self.view)
        textView.alpha = 0
        showActivityIndicator()
        getFireBase()
        self.refreshQRCode()
        brightness()
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didTakeScreenshot(notification:)), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        self.myTimer = Timer(timeInterval: 5.0, target: self, selector: #selector(refresh),  userInfo: nil, repeats: true)
        showActivityIndicator()
                RunLoop.main.add(self.myTimer, forMode: .default)
        
            }

    @objc func didTakeScreenshot(notification:Notification) -> Void {

            print("Screen Shot Taken")
        showAlert(with: "Но так легко это не обойти😈", title: "Хорошая попытка!")
    }
    
    @IBAction func correctionLevelChanged(_ sender: Any) {
        self.refreshQRCode()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.refreshQRCode()
    }
    
    // MARK: - Generate QR Code
    
    func refreshQRCode() { //обновление QR-кода
        self.textView.text = self.textUser
        let text:String = self.textView.text!
        
        // Generate the image
        guard let qrCode:CIImage = self.createQRCodeForString(text) else {
            print("Failed to generate QRCode")
            self.imageView.image = nil
            return
        }
        
        // Rescale to fit the view (otherwise it is only something like 100px)
        let viewWidth = self.imageView.bounds.size.width;
        let scale = viewWidth/qrCode.extent.size.width;
        let scaledImage = qrCode.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        // Display
        self.imageView.image = UIImage(ciImage: scaledImage)
    }
    
    
    /// Generate a CoreImage image for the text passed in.
    /// This string is converted to ISOLatin1 string encoding, not the usual UTF8.
    /// Then the resulting binary data is past as the input to a CIFilter which makes the QRCode for us
    /// - Parameter text: The text to turn into a QRCode
    func createQRCodeForString(_ text: String) -> CIImage?{ //создание QR-кода
        let data = text.data(using: .utf8)
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        // Input text
        qrFilter?.setValue(data, forKey: "inputMessage")
        // Error correction
        let values = ["L", "M", "Q", "H"]
        // Trick to limit the result to the bounds (0, array.maxIndex) - max(_MIN_, min(_value_, _MAX_))
        let index = max(0, min(self.correctionLevelSegmentControl.selectedSegmentIndex, (values.count-1)))
        let correctionLevel = values[index]
        qrFilter?.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        
        return qrFilter?.outputImage
    }
    
    
    
    // MARK: - Получение данных

    func getFireBase(){ //Получаем данные с FireBase
        let user = Auth.auth().currentUser
        if let user = user {
            let email = user.email
            print(user)
            let salt = randomSalt() //получаем соль :))
            var docRef = db.collection("users").whereField("email", isEqualTo: email!)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        self.textUser = "Пользователь не авторизован"
                    } else {
                        for document in querySnapshot!.documents {
                            self.textUser=""
                            let space = " "
                            let firstname = document.get("firstname") as! String
                            let lastname = document.get("lastname") as! String
                            let middlename = document.get("middlename") as! String
                            let group = document.get("group") as! String
                            self.textUser = self.textUser + salt + space + lastname + space + firstname + space + middlename + space + group
                            self.textView.text = self.textUser
                            print (self.textUser)
                            self.refreshQRCode()
                            self.hideActivityIndicator()
                        }
                        
                    }
            }
        }
    }
    @IBAction func reButtonPressed(_ sender: Any) { //кнопка обновления QR-кода
        Auth.auth().addStateDidChangeListener { [self] (auth, user) in
                if user == nil{
                    print("Пользователь не авторизован")
                    self.textUser = "Пользователь не авторизован"
                    refreshQRCode()
                    
                } else {
                    print("User is auth")
                    getFireBase()
                    refreshQRCode()
                }
    }
    }
    
    func randomSalt() -> String{ //получаем соль :))
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let salt = String((0..<15).map{ _ in letters.randomElement()! })
        print("Salt: ",salt)
        return salt
    }
    func brightness(){
        UIScreen.main.brightness = CGFloat(1.0)
    }
        func showActivityIndicator() {
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            activityIndicator.backgroundColor = UIColor(red:0.16, green:0.17, blue:0.21, alpha:1)
            activityIndicator.layer.cornerRadius = 6
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = .whiteLarge
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
}

extension GeneratorViewController: ScreenRecordDelegate {
    func screen(_ screen: UIScreen, didRecordStarted isRecording: Bool) {
        showAlert(with: "Думал самый умный?)", title: "Ненене")
    }
    
    func screen(_ screen: UIScreen, didRecordEnded isRecording: Bool) {
        showAlert(with: "Всё равно не получится обойти", title: "Молодец!")
    }
    
}
extension GeneratorViewController {
    
    func showAlert(with message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            alertController.dismiss(animated: true)
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

