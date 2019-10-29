//
//  ViewController.swift
//  FaveButtonDemo
//
//  Created by Jansel Valentin on 6/12/16.
//  Copyright © 2016 Jansel Valentin. All rights reserved.
//

import UIKit
import FaveButton


func color(_ rgbColor: Int) -> UIColor{
    return UIColor(
        red:   CGFloat((rgbColor & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbColor & 0x00FF00) >> 8 ) / 255.0,
        blue:  CGFloat((rgbColor & 0x0000FF) >> 0 ) / 255.0,
        alpha: CGFloat(1.0)
    )
}

class ViewController: UIViewController, FaveButtonDelegate{
    var tailTextString: String = "dddd"
    
    var tailTextLabel: UILabel {
        get {
            return UILabel(frame: .zero)
        }
    }
    var fav: FaveButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // optional, set default selected fave-buttons with initial
        // startup animation disabled.

        
        fav = FaveButton(frame: .zero, faveIconNormal: UIImage(named: "like")!,faveIconSelected: UIImage(named: "heart") , setCons: {
            fav in
            fav.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(fav)
            NSLayoutConstraint.activate([
                       fav.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
                       fav.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
                       fav.widthAnchor.constraint(equalToConstant: 30),
                       fav.heightAnchor.constraint(equalToConstant: 30)
                   ])
            fav.layoutIfNeeded()
        })
        self.fav.delegate = self
        self.fav.addTailText(view: self.view)
        fav.faveIcon.iconColor = .red
        
    }
    
    let colors = [
        DotColors(first: color(0x7DC2F4), second: color(0xE2264D)),
        DotColors(first: color(0xF8CC61), second: color(0x9BDFBA)),
        DotColors(first: color(0xAF90F4), second: color(0x90D1F9)),
        DotColors(first: color(0xE9A966), second: color(0xF8C852)),        
        DotColors(first: color(0xF68FA7), second: color(0xF6A2B8))
    ]
    
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
        faveButton.showFirstImage()
    }
    
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
        return nil
    }
    var hh = 1
}




