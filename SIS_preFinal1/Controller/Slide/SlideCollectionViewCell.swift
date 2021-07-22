//
//  SlideCollectionViewCell.swift
//  SIS
//
//  Created by Sasha on 7/15/21.
//

import UIKit

class SlideCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var regButton: UIButton!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var slideImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(slide: Slides){
        slideImage.image = slide.img
        descriptionText.text = slide.text
        if (slide.id == 1){
//           PageControl.currentPage = 0
        }
        if (slide.id == 2){
//            PageControl.currentPage = 1
        }
        if(slide.id == 3){
//            PageControl.currentPage = 2
            regButton.isHidden = false
            authButton.isHidden = false
        }
    }
    @IBAction func regButton(_ sender: Any) {
        rootView(name: "RegisterViewController")
    }
    @IBAction func authButton(_ sender: Any) {
        rootView(name: "AuthInViewController")
    }
    @IBAction func pageAction(_ sender: Any) {
    }
    func rootView(name: String){
        let board = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = board.instantiateViewController(identifier: name)
        window?.rootViewController = navigationController
    }
    
}
