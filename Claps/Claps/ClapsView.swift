//
//  ClapsView.swift
//  Claps
//
//  Created by Hemang Shah on 8/17/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

fileprivate extension UIView {
    func asCircle() {
        self.layer.cornerRadius = self.frame.size.width/2.0
        self.layer.masksToBounds = true
    }
}

fileprivate extension UIColor {
    class func RGB(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
    }
}

fileprivate extension Int {
    var abbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.characters.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }
}

@objc public enum ClapsViewStates: Int {
    case begin
    case end
    case clapping
    case finalized
}

@objc public protocol ClapsViewDelegate {
    func clapsViewStateChanged(clapsView: ClapsView, state: ClapsViewStates, totalClaps: Int, currentClaps: Int)
}

@IBDesignable
public class ClapsView: UIView {
    
    @IBOutlet public var delegate: ClapsViewDelegate?
    
    ///Inactive State Border Color. Default: .lightGray
    @IBInspectable public var inActiveStateBorderColor: UIColor = .lightGray {
        didSet {
            self.inActiveState()
        }
    }
    
    ///Active State Border Color.
    @IBInspectable public var activeStateBorderColor: UIColor = .RGB(r: 255.0, g: 207.0, b: 74.0) {
        didSet {
            self.activeState()
        }
    }
    
    ///Inside Background Color. Default: .clear
    @IBInspectable public var insideBakcgroundColor: UIColor = .clear {
        didSet {
            self.emojiLabel?.backgroundColor = insideBakcgroundColor
        }
    }
    
    ///ClapsView Background Color.
    @IBInspectable public var clapsLabelBackgroundColor: UIColor = .RGB(r: 255.0, g: 207.0, b: 74.0) {
        didSet {
            self.clapsLabel?.backgroundColor = clapsLabelBackgroundColor
        }
    }
    
    ///ClapsView Text Color. Default: .white
    @IBInspectable public var clapsLabelTextColor: UIColor = .white {
        didSet {
            self.clapsLabel?.textColor = clapsLabelTextColor
        }
    }
    
    ///ClapsView Font. Default: SystemFont = 12.0
    @IBInspectable public var clapsLabelFont: UIFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            self.clapsLabel?.font = clapsLabelFont
        }
    }
    
    ///ClapsView Emoji. Default: 👏
    @IBInspectable public var emoji: String = "👏" {
        didSet {
            if emoji.isEmpty {
                fatalError("\(String.init(describing: ClapsView.self)) requires an Emoji.")
            } else {
                self.emojiLabel?.text = emoji
            }
        }
    }
    
    ///Increase/Decrease the size of Emoji. Default: 40.0 | Minimum: 20.0
    @IBInspectable public var emojiLabelFontSize: CGFloat = 40.0 {
        didSet {
            if self.emojiLabelFontSize >= 20.0 {
                self.emojiLabel?.font = UIFont.init(name: "AppleColorEmoji", size: emojiLabelFontSize)
            } else {
                fatalError("\(String.init(describing: ClapsView.self)) requires 20.0 size for Emoji. This is the minimum size.")
            }
        }
    }
    
    ///Show 1000 claps as 1k. Default: false
    @IBInspectable public var showClapsAbbreviated: Bool = false
    
    ///Total Claps Count by All the Users.
    @IBInspectable public var totalClaps: Int = 0
    ///Current Claps Count By a User.
    @IBInspectable public var currentClaps: Int = 0
    ///The maximum number of claps allowed.
    @IBInspectable public var maxClaps: Int = 50
    ///i.e. currentClaps + iteratorClaps = new claps.
    @IBInspectable public var iteratorClaps: Int = 1
    
    //To show the exact claps each time.
    fileprivate var lastClapsCount: Int = 0
    
    //Private Values
    fileprivate var clapsLabel: UILabel? = nil
    fileprivate var emojiLabel: UILabel? = nil
    fileprivate var removeClapsButton: UIButton? = nil
    
    fileprivate var animationTimer: Timer? = nil

    fileprivate let animationDuration: TimeInterval = 0.25
    fileprivate let timerDuration: TimeInterval = 0.30
    
    //MARK: Init
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setupClapsView()
    }

    //MARK: Setup
    fileprivate func setupClapsView() {
        if self.frameValidator() {
            self.backgroundColor = UIColor.white
            self.asCircle()
            self.addEmojiLabel()
            self.inActiveState()
            self.addLongPressGesture()
            self.addClapsLabel()
            self.addRemoveClapsButton()
            self.addSingleAndDoubleTapGestures()
        }
    }
    
    //MARK: Gestures
    fileprivate func addLongPressGesture() {
        //This gesture will be used to iterate the claps on long press.
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(actionUserTappedOrLongPress))
        self.addGestureRecognizer(longPressGesture)
    }
    
    fileprivate func addSingleAndDoubleTapGestures() {
        //This gesture will be used to see current claps by a user.
        let singleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(actionUserSingleTaps))
        singleTapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTapGesture)
        
        //This gesture will be used to show a 'X' button. This will be used to remove all of the claps by a user.
        let doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(actionUserDoubleTaps))
        doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
    //MARK: Gesture Action
    @objc fileprivate func actionUserTappedOrLongPress(longPressGesture: UILongPressGestureRecognizer) {
        
        if longPressGesture.state == .began {
            
            self.updateForBeginState()
            self.countManagement()
            self.activeState()
            self.runTimer()
            
        } else if longPressGesture.state == .ended {
            
            self.updateForEndState()
            self.stopTimer()
            self.updateClaps()
            self.inActiveState()
        }
    }
    
    @objc fileprivate func actionUserDoubleTaps(gesture: UIPanGestureRecognizer) {
        if self.currentClaps > 0 {
            if (self.removeClapsButton?.isHidden)! {
                self.removeClapsButton?.isHidden = false
            } else {
                self.removeClapsButton?.isHidden = true
            }
        }
    }
    
    @objc fileprivate func actionUserSingleTaps(gesture: UIPanGestureRecognizer) {
        self.finalizeClaps()
    }
    
    @objc fileprivate func actionRemoveClaps(sender: UIButton) {
        let totalClaps = (self.totalClaps == self.currentClaps) ? 0 : self.totalClaps
        self.remove(withTotalClaps: totalClaps, withFinalizeAnimation: false)
        self.removeClapsButton?.isHidden = true
    }
    
    //MARK: Update for Begin/End States
    fileprivate func updateForBeginState() {
        if (self.delegate != nil) {
            self.delegate?.clapsViewStateChanged(clapsView: self, state: .begin, totalClaps: self.totalClaps, currentClaps: self.currentClaps)
        }
    }
    
    fileprivate func updateForEndState() {
        if (self.delegate != nil) {
            self.delegate?.clapsViewStateChanged(clapsView: self, state: .end, totalClaps: self.totalClaps, currentClaps: self.currentClaps)
        }
    }
    
    //MARK: Timer Management (Start/Stop)
    fileprivate func runTimer() {
        
        self.stopTimer()
        
        if #available(iOS 10.0, *) {
            self.animationTimer = Timer.scheduledTimer(withTimeInterval: self.timerDuration, repeats: true) { (timer) in
                self.animateClapsLabel()
            }
        } else {
            // Fallback on earlier versions
            self.animationTimer = Timer.scheduledTimer(timeInterval: self.timerDuration, target: self, selector: #selector(animateClapsLabel), userInfo: nil, repeats: true)
        }
    }
    
    fileprivate func stopTimer() {
        if let timer = animationTimer {
            timer.invalidate()
        }
    }
    
    //MARK: Finalize Claps
    fileprivate func updateClaps() {
        let differenceInClapsCount = (self.currentClaps - self.lastClapsCount)
        self.totalClaps = self.totalClaps + differenceInClapsCount
        self.finalizeClaps()
    }
    
    internal func finalizeClaps() {
        
        if self.totalClaps <= 0 {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timerDuration, execute: {
            
            if self.showClapsAbbreviated {
                self.clapsLabel?.text = self.totalClaps.abbreviated
            } else {
                self.clapsLabel?.text = "+" + "\(self.totalClaps)"
            }
            
            UIView.animate(withDuration: self.animationDuration, delay: 0.0, options: .curveEaseOut, animations: {
                self.clapsLabel?.alpha = 1.0
                self.clapsLabel?.transform = CGAffineTransform(scaleX: 1.5,y: 1.5)
            }) { (isCompleted) in
                self.clapsLabel?.alpha = 0.0
                self.clapsLabel?.transform = CGAffineTransform(scaleX: 1.0,y: 1.0)
            }
        })
    }
    
    ///This is to remove a user claps. So we will requires to update the ClapsView with new claps.
    internal func remove(withTotalClaps totalClaps: Int, withFinalizeAnimation finalizeAnimation: Bool) {
        self.totalClaps = totalClaps
        self.currentClaps = 0
        self.lastClapsCount = 0
        self.countManagement()
        
        if finalizeAnimation {
            self.updateClaps()
        }
    }
    
    //MARK: Iterator
    @objc fileprivate func animateClapsLabel() {
        
        self.iterateClaps()
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseOut, animations: {
            self.clapsLabel?.alpha = 1.0
            self.clapsLabel?.transform = CGAffineTransform(scaleX: 1.5,y: 1.5)
            self.emojiLabel?.transform = CGAffineTransform(scaleX: 1.5,y: 1.5)
        }) { (isCompleted) in
            self.clapsLabel?.alpha = 0.0
            self.clapsLabel?.transform = CGAffineTransform(scaleX: 1.0,y: 1.0)
            self.emojiLabel?.transform = CGAffineTransform(scaleX: 1.0,y: 1.0)
        }
    }
    
    fileprivate func iterateClaps() {
        if !self.hasMaxClaps() {
            self.currentClaps = self.currentClaps + self.iteratorClaps
            if (self.delegate != nil) {
                self.delegate?.clapsViewStateChanged(clapsView: self, state: .clapping, totalClaps: self.totalClaps, currentClaps: self.currentClaps)
            }
        }
        
        if self.showClapsAbbreviated {
            self.clapsLabel?.text = self.currentClaps.abbreviated
        } else {
            self.clapsLabel?.text = "+" + String(self.currentClaps)
        }
    }
    
    internal func hasMaxClaps() -> Bool {
        return (self.currentClaps == self.maxClaps)
    }
    
    fileprivate func countManagement() {
        if self.lastClapsCount >= 0 {
            self.lastClapsCount = self.currentClaps
        }
    }
    
    //MARK: UI Helpers
    fileprivate func initialFrame() -> CGRect {
        return CGRect.init(origin: .zero, size: CGSize.init(width: self.frame.size.width, height: self.frame.size.height))
    }
    
    fileprivate func addEmojiLabel() {
        let label = UILabel.init(frame: initialFrame())
        label.asCircle()
        label.backgroundColor = insideBakcgroundColor
        label.isUserInteractionEnabled = false
        label.text = emoji
        label.font = UIFont.init(name: "AppleColorEmoji", size: emojiLabelFontSize)
        label.textAlignment = .center
        label.clipsToBounds = false
        label.isUserInteractionEnabled = false
        self.addSubview(label)
        label.center = CGPoint.init(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
        self.emojiLabel = label
    }
    
    fileprivate func addClapsLabel() {
        if let superView = self.superview {
            let clapsViewSize = self.frame.size.width/2.0
            let label = UILabel.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: clapsViewSize, height: clapsViewSize)))
            label.asCircle()
            label.backgroundColor = clapsLabelBackgroundColor
            label.isUserInteractionEnabled = false
            label.text = String(totalClaps)
            label.font = clapsLabelFont
            label.adjustsFontSizeToFitWidth = true
            label.textColor = clapsLabelTextColor
            label.textAlignment = .center
            label.alpha = 0.0
            label.isUserInteractionEnabled = false
            superView.addSubview(label)
            label.center = CGPoint.init(x: self.center.x, y: self.center.y - (self.frame.size.height + 25.0))
            self.clapsLabel = label
        } else {
            fatalError("\(String.init(describing: ClapsView.self)) couldn't find it's super view.")
        }
    }
    
    fileprivate func addRemoveClapsButton() {
        if let superView = self.superview {
            let button = UIButton.init(type: .custom)
            button.frame = CGRect.init(origin: .zero, size: self.frame.size)
            button.asCircle()
            button.setTitle("x", for: .normal)
            button.backgroundColor = self.clapsLabelBackgroundColor
            button.addTarget(self, action: #selector(actionRemoveClaps), for: .touchUpInside)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30.0)
            superView.addSubview(button)
            button.center = self.center
            button.isHidden = true
            self.removeClapsButton = button
        } else {
            fatalError("\(String.init(describing: ClapsView.self)) couldn't find it's super view.")
        }
    }
    
    fileprivate func activeState() {
        self.layer.borderColor = activeStateBorderColor.cgColor
        self.layer.borderWidth = 2.0
    }
    
    fileprivate func inActiveState() {
        self.layer.borderColor = inActiveStateBorderColor.cgColor
        self.layer.borderWidth = 2.0
    }
    
    //MARK: Validator
    fileprivate func frameValidator() -> Bool {
        let size = self.frame.size
        if size.width != size.height {
            fatalError("\(String.init(describing: ClapsView.self)) width and height should be equal.")
        }
        return true
    }
}
