//
//  SliderSliders.swift
//  SIS
//
//  Created by Sasha on 7/15/21.
//

import UIKit

class SliderSliders{
    
    func getSlides() -> [Slides]{
        var slides: [Slides] = []
        let slide1 = Slides(id: 1, text: "text1", img: UIImage(named: "slide1")!)
        let slide2 = Slides(id: 2, text: "text2", img:UIImage(named: "slide2")!)
        let slide3 = Slides(id: 3, text: "text3", img: UIImage(named: "slide1")!)

        slides.append(slide1)
        slides.append(slide2)
        slides.append(slide3)
        
        return slides
    }
}
