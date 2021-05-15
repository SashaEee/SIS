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
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var correctionLevelSegmentControl: UISegmentedControl!
    var textUser: String = ""
    
    
	override func viewDidLoad() {
		super.viewDidLoad()
        getFireBase()
        self.refreshQRCode()

		self.textView.delegate = self
		self.registerForKeyboardNotifications()
		
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.shareImage))
		self.imageView.addGestureRecognizer(longPress)
		self.imageView.isUserInteractionEnabled = true // UIImageView is(was?) the only UIView class this defaults to false
		
		self.refreshQRCode()
        addTapGestureToHideKeyboard()
            }

            func addTapGestureToHideKeyboard() {
                let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
                view.addGestureRecognizer(tapGesture)
            }
	
	@IBAction func correctionLevelChanged(_ sender: Any) {
		self.refreshQRCode()
	}
	
	func textViewDidChange(_ textView: UITextView) {
		self.refreshQRCode()
	}
	
	// MARK: - Generate QR Code
	
	func refreshQRCode() {
        getFireBase()
		let text:String = self.textView.text
		
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
        getFireBase()
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
	
	
	
	
	
	// MARK: - Keyboard Handling
    
	
	func registerForKeyboardNotifications(){
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@objc func keyboardWasShown(_ aNotification: NSNotification) {
		let info = aNotification.userInfo!
		let kbSize:CGSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
		let contentInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
		self.scrollView.contentInset = contentInsets
		self.scrollView.scrollIndicatorInsets = contentInsets
		
		// If active text field is hidden by keyboard, scroll it so it's visible
		// Your application might not need or want this behavior.
		var aRect:CGRect = self.view.frame
		aRect.size.height -= kbSize.height
		if (!aRect.contains(self.textView.frame.origin)) {
			let scrollPoint:CGPoint = CGPoint(x: 0, y: self.textView.frame.origin.y-kbSize.height)
			self.scrollView.setContentOffset(scrollPoint, animated: true)
		}
	}
	
	@objc func keyboardWillBeHidden(_ aNotification: NSNotification) {
		let contentInsets = UIEdgeInsets.zero
		self.scrollView.contentInset = contentInsets;
		self.scrollView.scrollIndicatorInsets = contentInsets;
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
                            let space = " "
                            let firstname = document.get("firstname") as! String
                            let lastname = document.get("lastname") as! String
                            let middlename = document.get("middlename") as! String
                            let group = document.get("group") as! String
                            self.textUser = self.textUser + space + firstname + space +  lastname + space + middlename + space + group
                            print (self.textUser)
                        }
                        
                    }
            }
        }
    }
}

