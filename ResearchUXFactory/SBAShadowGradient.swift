//
//  SBAShadowGradient.swift
//  BridgeAppSDK
//
//  Created by Michael L DePhillips on 4/8/17.
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

@IBDesignable open class SBAShadowGradient : UIView {
    
    /**
     * The color of the shadow that is drawn as the background of this
     */
    @IBInspectable var shadowColor : UIColor = UIColor.black {
        didSet {
            commonInit()
        }
    }
    
    /**
     * The alpha value (0.0 to 1.0) that the bototm part of the gradient will be at
     */
    @IBInspectable var bottomAlpha : CGFloat = CGFloat(0.25) {
        didSet {
            commonInit()
        }
    }
    
    /**
     * The alpha value (0.0 to 1.0) that the top part of the gradient will be at
     */
    @IBInspectable var topAlpha : CGFloat = CGFloat(0.0) {
        didSet {
            commonInit()
        }
    }
    
    let gradientLayer = CAGradientLayer()
    
    public init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
    
    func commonInit() {
        backgroundColor = UIColor.clear
        gradientLayer.frame = self.bounds
        
        let bottomColor = shadowColor.withAlphaComponent(bottomAlpha).cgColor
        let topColor = shadowColor.withAlphaComponent(topAlpha).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        
        if layer.sublayers?.count ?? 0 == 0 {
            layer.addSublayer(gradientLayer)
        }
    }
    
    override open func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = self.bounds
    }
}
