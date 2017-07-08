//
//  SBARoundedButton.swift
//  elevateMS
//
//  Created by Michael L DePhillips on 4/5/17.
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit

public let SBARoundedButtonDefaultHeight: CGFloat = 52.0
public let SBARoundedButtonDefaultCornerRadius: CGFloat = SBARoundedButtonDefaultHeight / 2

@IBDesignable open class SBARoundedButton : UIButton, ORKButton {
    
    @IBInspectable open var corners: CGFloat = CGFloat(5) {
        didSet {
            refreshView()
            setNeedsDisplay()
        }
    }

    @IBInspectable open var shadowColor: UIColor = UIColor.roundedButtonShadowDark {
        didSet {
            refreshView()
            setNeedsDisplay()
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            // show as disabled by lowering opacity unless alpha is used to set hidden
            guard alpha > 0.1 else { return }
            self.alpha = isEnabled ? CGFloat(1) : CGFloat(0.3)
        }
    }
    
    public var isInTransition: Bool = false
    
    open var titleFont: UIFont? {
        didSet {
            guard let font = titleFont else { return }
            titleLabel?.font = font
        }
    }
    
    open var titleColor: UIColor? {
        didSet {
            setTitleColor(titleColor, for: .normal)
        }
    }
    
    public required init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 51))
        
        // setup colors
        self.backgroundColor = UIColor.roundedButtonBackgroundDark
        self.shadowColor = UIColor.roundedButtonShadowDark
        self.corners = SBARoundedButtonDefaultCornerRadius
        
        // setup text
        self.titleColor = UIColor.roundedButtonTextLight
        setTitleColor(titleColor, for: .normal)
        
        self.titleFont = UIFont.roundedButtonTitle

        commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        refreshView()
    }
    
    open func commonInit() {
        refreshView()
    }
    
    func refreshView() {
        guard self.alpha > 0.9 else {
            layer.shadowOpacity = 0
            return
        }
        
        layer.cornerRadius = corners
        
        // Draw bottom button shadow
        let shadowRadius = corners * 1.2
        let shadowHeight = CGFloat(3)
        
        // Make sure the shadow shows up outside the view's bounds
        clipsToBounds = false
        layer.masksToBounds = false
        
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: shadowHeight)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 0.0 // this is actually blur radius
        // User this as the shadow path, since it has a larger corner radius
        // than the default layer's corner radius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: shadowRadius)
        layer.shadowPath = shadowPath.cgPath
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        setNeedsDisplay()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}
