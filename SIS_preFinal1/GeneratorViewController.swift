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
import CryptoSwift

var second: Int = 0
var isVertical : Bool = false


class GeneratorViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var correctionLevelSegmentControl: UISegmentedControl!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var Ractangle: UIImageView!
    @IBOutlet weak var reButton: UIBarButtonItem!
    @IBOutlet weak var UserImage: UIImageView!
    
    var textUser: String = "Пользователь не авторизован"
    var myTimer: Timer!
    @objc func refresh() {
        second -= 1
        self.timerLabel.text = "Код будет обновлен через: " + "\n" + "\(second)" +  " секунд"
        if (second <= 0){
            resetTimer()
            getFireBase()
         }
       }
    func resetTimer(){
        second = 15
        self.timerLabel.text = "Код будет обновлен через: " + "\n" + "\(second)" +  " секунд"
    }
    
    override func viewDidLoad() {
        UserImage.image = avatar
        design()
        designUserImage()
        //ScreenGuardManager.shared.screenRecordDelegate = self //защита от скринов
       // ScreenGuardManager.shared.listenForScreenRecord() //защита от скринов
       // ScreenGuardManager.shared.guardScreenshot(for: self.view) //защита от скринов
        getFireBase()
        resetTimer()
        self.refreshQRCode()
        brightness()
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didTakeScreenshot(notification:)), name: UIApplication.userDidTakeScreenshotNotification, object: nil) //уведомления от скринов
        self.myTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(refresh),  userInfo: nil, repeats: true)
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
    
    // MARK: - Генерация QR-кода
    
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
    
    
    
    // MARK: - Получение данных из Firebase

    func getFireBase(){
        showActivityIndicator()
        if (firstName != nil){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
            let salt = self.getTime()
            self.textUser = "\(salt)" + " " + firstName! + " " + lastName! + " id: " + studID!
            print(self.textUser)
                self.encode()
            self.textView.text = self.textUser
            print (self.textUser)
            self.refreshQRCode()
            self.hideActivityIndicator()
            }
        }
        else {//Получаем данные с FireBase
        let user = Auth.auth().currentUser
        if let user = user {
            let email = user.email
            print(user)
            let salt = getTime() //получаем соль :))
            db.collection("users").whereField("email", isEqualTo: email!)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        self.timerLabel.text = "Пользователь не авторизован"
                        self.hideActivityIndicator()
                    } else {
                        for document in querySnapshot!.documents {
                            self.textUser=""
                            let space = " "
                            let id = document.get("studID") as! String
                            self.textUser = salt + space + id
                            self.textView.text = self.textUser
                            print (self.textUser)
                            self.refreshQRCode()
                            self.hideActivityIndicator()
                        }
                    }
            }
        }
    }
    }
    // MARK: - Кнопка обновления

    @IBAction func reButtonPressed(_ sender: Any) {
        //кнопка обновления QR-кода
        Auth.auth().addStateDidChangeListener { [self] (auth, user) in
                if user == nil{
                    print("Пользователь не авторизован")
                    self.timerLabel.text = "Пользователь не авторизован"
                    refreshQRCode()
                    hideActivityIndicator()
                    
                } else {
                    print("User is auth")
                    getFireBase()
                    refreshQRCode()
                    resetTimer()
                }
        }
    }
// MARK: - Получаем соль

    func brightness(){
        UIScreen.main.brightness = CGFloat(1.0)
    }
    // MARK: - Индикатор загрузки

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
    // MARK: - Получение даты и времени

    func getTime() -> String {
//        let dateTime = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        let dateTime = "\(Int(Date().timeIntervalSince1970))"
        return dateTime
    }
    func design(){
        Ractangle.layer.cornerRadius = 15
    }
    func designUserImage(){
        //let UserImage = UIImageView(
        //            image: UIImage(named: "input") // исходная картинка
         //       )
                UserImage.frame.size = CGSize(width: 100, height: 100) //размеры новой картинки
                UserImage.layer.cornerRadius = 35
                UserImage.clipsToBounds = true
        UserImage.layer.borderColor = UIColor.white.cgColor // цвет рамки
        UserImage.layer.borderWidth = 1.5 // толщина рамки
    }
    func encode(){
        do {
            let aes = try AES(key: "passwordpassword", iv: "drowssapdrowssap")
            let ciphertext = try aes.encrypt(Array(self.textUser.utf8))
            print(ciphertext)
        } catch { }
        
    }

}
// MARK: - Защита от скриншотов

extension GeneratorViewController: ScreenRecordDelegate {
    func screen(_ screen: UIScreen, didRecordStarted isRecording: Bool) {
        showAlert(with: "Думал самый умный?)", title: "Ненене")
    }
    
    func screen(_ screen: UIScreen, didRecordEnded isRecording: Bool) {
        showAlert(with: "Всё равно не получится обойти", title: "Молодец!")
    }
    
}
// MARK: - Уведомления
extension GeneratorViewController {
    
    func showAlert(with message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Понял, принял!", style: .default) { _ in
            alertController.dismiss(animated: true)
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
