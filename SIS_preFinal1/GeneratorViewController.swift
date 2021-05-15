//
//  FirstViewController.swift
//  QR Codes
//
//  Created by Kyle Howells on 31/12/2019.
//  Copyright © 2019 Kyle Howells. All rights reserved.
//

import UIKit
import CoreImage
import Firebase

let dbs = Firestore.firestore()



class GeneratorViewController: UIViewController, UITextViewDelegate {
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UILabel!
	@IBOutlet weak var correctionLevelSegmentControl: UISegmentedControl!
    @IBOutlet weak var reButton: UIButton!
    var textUser: String = "Пользователь не авторизован"
    
    
	override func viewDidLoad() {
        textView.alpha = 0
                    getFireBase()
                    self.refreshQRCode()
                    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.shareImage))
                    self.imageView.addGestureRecognizer(longPress)
                    self.imageView.isUserInteractionEnabled = true // UIImageView is(was?) the only UIView class this defaults to false
                    super.viewDidLoad()
        
		
            }

	
	@IBAction func correctionLevelChanged(_ sender: Any) {
		self.refreshQRCode()
	}
	
	func textViewDidChange(_ textView: UITextView) {
		self.refreshQRCode()
	}
	
	// MARK: - Generate QR Code
	
	func refreshQRCode() {
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
	func createQRCodeForString(_ text: String) -> CIImage?{
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
	
	
	
	
	// MARK: Share Image
	
	@objc func shareImage() {
		guard let image = self.imageView.image else {
			return
		}
		let activityViewController = UIActivityViewController(activityItems: [ self.sharableImage(image) ], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.imageView // so that iPads won't crash
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
	}
	// Lots of the share extensions don't seem to handle UIImage's originating from CoreImage images properly
	// Even though it shouldn't be needed, re-rendering it seems to help reliablity of some sharing options
	func sharableImage(_ image: UIImage) -> UIImage{
		let renderer = UIGraphicsImageRenderer(size: image.size, format: image.imageRendererFormat)
		let img = renderer.image { ctx in
			image.draw(at: CGPoint.zero)
		}
		return img
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
                        self.textUser = "Пользователь не авторизован"
                    } else {
                        for document in querySnapshot!.documents {
                            self.textUser=""
                            let space = " "
                            let firstname = document.get("firstname") as! String
                            let lastname = document.get("lastname") as! String
                            let middlename = document.get("middlename") as! String
                            let group = document.get("group") as! String
                            self.textUser = self.textUser + lastname + space + firstname + space + middlename + space + group
                            self.textView.text = self.textUser
                            print (self.textUser)
                            self.refreshQRCode()
                        }
                        
                    }
            }
        }
    }
    @IBAction func reButtonPressed(_ sender: Any) {
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
    
}

