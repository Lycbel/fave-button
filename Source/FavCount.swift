//
//  favCount.swift
//  FaveButtonDemo
//
//  Created by andy on 24/10/2019.
//  Copyright © 2019 Jansel Valentin. All rights reserved.
//

import UIKit

class FavCount: UIView {
    private let widthRatio: CGFloat = 1.5
    private let basePWidth: CGFloat = 25
    private let distanceRatio: CGFloat = 0.8
    private var widthCon: NSLayoutConstraint!
    private var bottomCon: NSLayoutConstraint!
    private let keepTopInterval = TimeInterval(1)
    private var updateTimeInterval = TimeInterval(1)
    private var width: CGFloat!
    private var bottomDistance: CGFloat!
    private var extTime = TimeInterval(0.1)
    private var backImage: UIImageView = {
        let image = UIImageView(frame: .zero)
        return image
    }()
    private var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "+0"
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    open var backColor: UIColor = .white {
        didSet {
            backImage.backgroundColor = backColor
        }
    }
    
    
    var needToShowFromBottom: Bool {
        if (updateTimeInterval - Date().timeIntervalSince1970 < -keepTopInterval) {
            return true
        }
        return false
    }
    
    var task: DispatchWorkItem?
    
    func updateText(_ text: String) {
        self.isHidden = false
        if needToShowFromBottom {
            
        } else {
            self.transform = .identity
            UIView.animate(
                withDuration: extTime,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.transform = self.transform.scaledBy(x: 1.1, y: 1.1)
            }, completion: {
                succ in
                self.widthCon.constant = self.width
                self.layoutIfNeeded()
                UIView.animate(
                    withDuration: self.extTime / 2,
                    delay: 0,
                    options: .curveEaseOut,
                    animations: {
                        self.transform = .identity
                }, completion: nil)
            })
        }
        task?.cancel()
        task = DispatchWorkItem {
            self.isHidden = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + keepTopInterval, execute: task!)
        label.text = text
        updateTimeInterval = Date().timeIntervalSince1970
    }
    
    func addToParent(parent: UIView) {
        parent.addSubview(self)
        self.addSubview(backImage)
        self.addSubview(label)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        backImage.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        //self.clipsToBounds = true
        let pWidth = parent.frame.width
        width = pWidth * widthRatio
        bottomDistance = parent.frame.height * distanceRatio
        widthCon = self.widthAnchor.constraint(equalToConstant: width)
        bottomCon = self.bottomAnchor.constraint(equalTo: parent.topAnchor, constant: -bottomDistance)
        
        widthCon.isActive = true
        bottomCon.isActive = true
        self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
        
        
        (self, parent) >>- [.centerX]
        (backImage, self) >>- [.centerX, .centerY]
        (label, self) >>- [.centerX, .centerY]
        (backImage, self) >>- [.width, .height]
        (label, self) >>- [.width, .height]
        backColor = .blue
        backImage.layoutIfNeeded()
        backImage.setRounded()
        label.setSizeFont(size: 15 * pWidth / basePWidth)
        self.isHidden = true
    }

    public static func createFavCount(_ parent: UIView) -> FavCount{
        let fc = FavCount(frame: .zero)
        fc.addToParent(parent: parent)
        return fc
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension UIImageView {
    func setRounded() {
        if (self.layer.mask != nil) {
            return
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(ovalIn: CGRect(x: self.frame.size.width/2 - self.frame.size.height/2,
                                                      y: 0.0,
                                                      width: self.frame.size.height,
                                                      height: self.frame.size.height)).cgPath
        shapeLayer.position = CGPoint(x: 0, y: 0)
        self.layer.mask = shapeLayer
    }
}

fileprivate extension UILabel {
    func setSizeFont (size: CGFloat) {
        self.font =  self.font.withSize(size)
        self.sizeToFit()
    }
}
