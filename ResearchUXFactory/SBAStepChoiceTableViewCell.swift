//
//  SBAStepChoiceTableViewCell.swift
//  ResearchUXFactory
//
//  Created by Josh Bruhin on 5/30/17.
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

// MARK: Choice Cell

class SBAStepChoiceTableViewCell: UITableViewCell {
    
    private let kShadowHeight: CGFloat = 5.0
    private let kSideMargin = CGFloat(20.0).proportionalToScreenWidth()
    private let kVertMargin: CGFloat = 10.0
    private let kMinHeight: CGFloat = 75.0

    var choiceValueLabel = UILabel()
    
    var shadowAlpha: CGFloat {
        return isSelected ? 0.2 : 0.05
    }
    
    var bgColor: UIColor {
        return isSelected ? UIColor.choiceCellBackgroundHighlighted : UIColor.choiceCellBackground
    }
    
    var labelColor: UIColor {
        return isSelected ? UIColor.choiceCellLabelHighlighted : UIColor.choiceCellLabel
    }
    
    open let shadowView: UIView = {
        let rule = UIView()
        rule.backgroundColor = UIColor.black
        return rule
    }()
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = bgColor
            choiceValueLabel.textColor = labelColor
            shadowView.alpha = shadowAlpha
        }
    }
    
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        
        self.selectionStyle = .none
        
        contentView.addSubview(choiceValueLabel)
        contentView.addSubview(shadowView)
        
        choiceValueLabel.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        choiceValueLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - (kSideMargin * 2)
        
        choiceValueLabel.numberOfLines = 0
        choiceValueLabel.font = UIFont.choiceCellLabel
        choiceValueLabel.textColor = labelColor
        choiceValueLabel.textAlignment = .left
        
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        choiceValueLabel.alignToSuperview([.leading, .trailing], padding: kSideMargin)
        choiceValueLabel.alignToSuperview([.top], padding: kVertMargin)
        
        shadowView.makeHeight(.equal, kShadowHeight)
        shadowView.alignToSuperview([.leading, .trailing, .bottom], padding: 0.0)
        shadowView.alignBelow(view: choiceValueLabel, padding: kVertMargin)
        
        contentView.makeHeight(.greaterThanOrEqual, kMinHeight)

        super.updateConstraints()
    }
}

// MARK: TextField Cell

open class SBAStepTextFieldTableViewCell: UITableViewCell {
    
    private let kVerticalMargin: CGFloat = 10.0
    private let kVerticalPadding: CGFloat = 7.0
    private let kSideMargin = CGFloat(25.0).proportionalToScreenWidth()
    private let kTextFieldWidth: CGFloat = 150.0
    
    public var textField: UITextField!
    open var ruleView: UIView!
    
    /**
     Layout constants. Subclasses can override to customize; otherwise the default private
     constants are used.
     */
    open func constants() -> (
        verticalMargin: CGFloat,
        verticalPadding: CGFloat,
        sideMargin: CGFloat,
        textFieldWidth: CGFloat)
    {
        return (kVerticalMargin,
                kVerticalPadding,
                kSideMargin,
                kTextFieldWidth)
    }
    
    /**
     Create all the view elements. Subclasses can override to provide custom instances.
     */
    open func initializeViews() {
        textField = SBAStepTextField()
        ruleView = UIView()
    }
    
    /**
     Define the subView properties.
     */
    open func setupViews() {
        
        textField.font = UIFont.textFieldCellText
        textField.textColor = UIColor.textFieldCellFieldText
        textField.textAlignment = .center
        
        ruleView.backgroundColor = UIColor.textFieldCellFieldBorder
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        
        initializeViews()
        setupViews()
        
        contentView.addSubview(textField)
        contentView.addSubview(ruleView)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        ruleView.translatesAutoresizingMaskIntoConstraints = false
        
        setNeedsUpdateConstraints()
    }
    
    override open func updateConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        // if we have a defined textField width, we use that and center the text field and ruleView horizontally.
        // Otherwise, we pin left and right edges to the superview with some side margin
        
        if constants().textFieldWidth > 0 {
            
            textField.makeWidth(.equal, constants().textFieldWidth)
            textField.alignCenterHorizontal(padding: 0.0)
        } else {

            textField.alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
        }

        textField.alignToSuperview([.top], padding: constants().verticalMargin)
        
        ruleView.alignBelow(view: textField, padding: constants().verticalPadding)
        ruleView.makeHeight(.equal, 1.0)
        
        // align left and right edges of ruleView to the textField
        ruleView.align([.leading, .trailing], .equal, to: textField, [.leading, .trailing], padding: 0.0)
        
        super.updateConstraints()
    }
}

class SBAStepTextField: UITextField {
    var indexPath: IndexPath?
}

