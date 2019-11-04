//
//  FaveButton.swift
//  FaveButton
//
// Copyright © 2016 Jansel Valentin.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit


public typealias DotColors = (first: UIColor, second: UIColor)


public protocol FaveButtonDelegate: class{
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool)
    
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?
    
    var tailTextLabel: UILabel{
        get
    }
    
    var tailTextString: String {
        get
    }
}


// MARK: Default implementation
public extension FaveButtonDelegate{
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{ return nil }
}

open class FaveButton: UIButton {
    open var tailTextLabel:UILabel!
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
           let margin: CGFloat = 10
           let area = self.bounds.insetBy(dx: -margin, dy: -margin)
           return area.contains(point)
       }
    fileprivate struct Const{
        static let duration             = 1.0
        static let expandDuration       = 0.1298 
        static let collapseDuration     = 0.1089
        static let faveIconShowDelay    = Const.expandDuration + Const.collapseDuration/2.0
        static let dotRadiusFactors     = (first: 0.0633, second: 0.04)
    }
    
    open var normalColor: UIColor     = UIColor(red: 137/255, green: 156/255, blue: 167/255, alpha: 1)
    open var selectedColor: UIColor   = UIColor(red: 226/255, green: 38/255,  blue: 77/255,  alpha: 1)
    open var dotFirstColor: UIColor   = UIColor(red: 152/255, green: 219/255, blue: 236/255, alpha: 1)
    open var dotSecondColor: UIColor  = UIColor(red: 247/255, green: 188/255, blue: 48/255,  alpha: 1)
    open var circleFromColor: UIColor = UIColor(red: 221/255, green: 70/255,  blue: 136/255, alpha: 1)
    open var circleToColor: UIColor   = UIColor(red: 205/255, green: 143/255, blue: 246/255, alpha: 1)
    
    open weak var delegate: FaveButtonDelegate?
    
    fileprivate(set) var sparkGroupCount: Int = 7
    
    fileprivate var faveIconImage:UIImage?
    var faveIcon: FaveIcon!
    
    open var faveIconImage2:UIImage?
    var faveIcon2: FaveIcon!
    //var favCount: FavCount!
    fileprivate var animationsEnabled = true
    
    public var applauseMode = true
    
    fileprivate var needRing = false
    fileprivate var selectAppearState: Bool = false
    override open var isSelected: Bool {
        didSet{
            guard self.animationsEnabled else {
                return
            }            
            animateSelect(self.isSelected, duration: Const.duration)
        }
    }
    
    open var favIconColors: (f: UIColor?, s: UIColor?) {
        didSet {
            faveIcon.iconColor = favIconColors.f ?? .gray
            faveIcon2.iconColor = favIconColors.s ?? .gray
        }
    }
    
    public convenience init(frame: CGRect, faveIconNormal: UIImage?, faveIconSelected: UIImage?, setCons: (UIView) -> Void) {
        self.init(frame: frame)
        guard let icon = faveIconNormal else{
            fatalError("missing image for normal state")
        }
        faveIconImage = icon
        faveIconImage2 = faveIconSelected
        setCons(self)
        applyInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("can't use interface builder")
    }
    
    public func setSelected(selected: Bool, animated: Bool) {
        guard selected != self.isSelected else {
            return
        }
        guard animated == false else {
            self.isSelected = selected
            return
        }
        
        self.animationsEnabled = false
        self.isSelected = selected
        self.animationsEnabled = true
        
        animateSelect(self.isSelected, duration: 0.0) // trigger state change without animation
    }
}


// MARK: create
extension FaveButton{
    fileprivate func applyInit(){
        //favCount = FavCount.createFavCount(self)

        if nil == faveIconImage{
            #if swift(>=4.2)
            faveIconImage = image(for: .normal)
            faveIconImage2 = image(for: .selected)
            #else
            faveIconImage = image(for: .normal)
            faveIconImage2 = image(for: .selected)
            #endif
        }
        
        guard let faveIconImage = faveIconImage, let faveIconImage2 = faveIconImage2 else{
            fatalError("please provide an image for normal state.")
        }
        
        #if swift(>=4.2)
        setImage(UIImage(), for: UIControl.State())
        setTitle(nil, for: UIControl.State())
        #else
        setImage(UIImage(), for: UIControlState())
        setTitle(nil, for: UIControlState())
        #endif
        setImage(UIImage(), for: .selected)
        setTitle(nil, for: .selected)
        
        faveIcon  = createFaveIcon(faveIconImage)
        faveIcon2  = createFaveIcon(faveIconImage2)
        addActions()
        showFirstImage()
    }
    
    open func addTailText(view: UIView){
        tailTextLabel = (delegate!).tailTextLabel
        tailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tailTextLabel)
        (tailTextLabel, self) >>- [.centerY]
        tailTextLabel.leadingAnchor.constraint(equalTo: self.trailingAnchor, constant: self.frame.width / 10).isActive = true
        tailTextLabel.text = delegate!.tailTextString
    }
    
    
    fileprivate func createFaveIcon(_ faveIconImage: UIImage) -> FaveIcon{
        return FaveIcon.createFaveIcon(self, icon: faveIconImage,color: normalColor)
    }
    
    
    fileprivate func createSparks(_ radius: CGFloat) -> [Spark] {
        var sparks    = [Spark]()
        let step      = 360.0/Double(sparkGroupCount)
        let base      = Double(bounds.size.width)
        let dotRadius = (base * Const.dotRadiusFactors.first, base * Const.dotRadiusFactors.second)
        let offset    = 10.0
        
        for index in 0..<sparkGroupCount{
            let theta  = step * Double(index) + offset
            let colors = dotColors(at: index)
            
            let spark  = Spark.createSpark(self, radius: radius, firstColor: colors.first,secondColor: colors.second, angle: theta,
                                           dotRadius: dotRadius)
            sparks.append(spark)
        }
        return sparks
    }
}


// MARK: utils

extension FaveButton{
    fileprivate func dotColors(at index: Int) -> DotColors{
        if case let delegate as FaveButtonDelegate = delegate , nil != delegate.faveButtonDotColors(self){
            let colors     = delegate.faveButtonDotColors(self)!
            let colorIndex = 0..<colors.count ~= index ? index : index % colors.count
            
            return colors[colorIndex]
        }
        return DotColors(self.dotFirstColor, self.dotSecondColor)
    }
}


// MARK: actions
extension FaveButton{
    func addActions(){
        self.addTarget(self, action: #selector(toggle(_:)), for: .touchUpInside)
    }
    
    @objc func toggle(_ sender: FaveButton){
        sender.isSelected = !sender.isSelected
        guard case let delegate as FaveButtonDelegate = self.delegate else{
            return
        }
        //favCount.updateText(delegate.countText)
        tailTextLabel.text = delegate.tailTextString
        let delay = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * Const.duration)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: .now()){
            delegate.faveButton(sender, didSelected: self.applauseMode || sender.isSelected)
        }
    }
    
    
    open func showFirstImage() {
        faveIcon2.isHidden = true
        faveIcon.isHidden = false
    }
    
    open func showSecondImage() {
        faveIcon.isHidden = true
        faveIcon2.isHidden = false
    }
}


// MARK: animation
extension FaveButton {
    fileprivate func animateSelect(_ isSelected: Bool, duration: Double){
        let color  = applauseMode ? selectedColor : (isSelected ? selectedColor : normalColor)
        selectAppearState = selectAppearState || !isSelected
        // faveIcon.animateSelect(isSelected || applauseMode, pre: selectAppearState, fillColor: color, duration: duration, delay: duration > 0.0 ? Const.faveIconShowDelay : 0.0)
        
        guard duration > 0.0 else {
            return
        }
        
        if isSelected || applauseMode{
            let radius           = bounds.size.scaleBy(1.3).width/2 // ring radius
            let igniteFromRadius = radius*0.8
            let igniteToRadius   = radius*1.1
            
            
            let sparks = createSparks(igniteFromRadius)
            if (needRing) {
                let ring   = Ring.createRing(self, radius: 0.01, lineWidth: 3, fillColor: self.circleFromColor)
                ring.animateToRadius(radius, toColor: circleToColor, duration: Const.expandDuration, delay: 0)
                ring.animateColapse(radius, duration: Const.collapseDuration, delay: Const.expandDuration)
            }
            
            sparks.forEach{
                $0.animateIgniteShow(igniteToRadius, duration:0.4, delay: 0)
                $0.animateIgniteHide(0.6, delay: 0)
            }
        }
    }
}
