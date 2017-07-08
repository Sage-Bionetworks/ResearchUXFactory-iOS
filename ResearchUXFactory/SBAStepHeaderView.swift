//
//  SBAStepHeaderView.swift
//  ResearchUXFactory
//
//  Created by Josh Bruhin on 5/25/17.
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

/**
 A custom UIView to be included in an SBAGenericStepViewController. It optionally contains several subViews
 and displays them in this order, from top to bottom of the view:
 
 1) progressView: SBAStepProgressView - show progress thru the current flow
 2) imageView: UIImageView - shows an image associated with the current step
 3) headerLabel: UILabel - generally the Title of the current step
 4) detailsLabel: UILabel - generally the Text of the current step
 5) customView: UIView - any custom view provided by the SBAGenericStepViewController
 6) learnMoreButton: UIButton - a button to call the learnMoreAction
 7) promptLabel: UILabel - a label intended to prompt the user to enter data or make a selection
 
 Several public properties are provided to configure the view, such has hiding or showing the learnMoreButton
 or progressView, and providing a minimumHeight or customView.
 
 To customize the view elements, subclasses should override the initializeViews() method. This will allow
 the use of any custom element (of the appropriate type) to be used instead of the default instances.
 */

open class SBAStepHeaderView: UIView {
    
    private let kTopMargin: CGFloat = CGFloat(30.0).proportionalToScreenWidth()
    private let kSideMargin: CGFloat = CGFloat(30.0).proportionalToScreenWidth()
    private let kVerticalSpacing: CGFloat = CGFloat(20.0).proportionalToScreenWidth()
    private let kBottomMargin: CGFloat = 10.0
    private let kImageViewHeight: CGFloat = CGFloat(100.0).proportionalToScreenWidth()
    private let kLearnMoreButtonHeight: CGFloat = 30.0
    private let kLabelMaxLayoutWidth: CGFloat = {
        return CGFloat(UIScreen.main.bounds.size.width - (2 * CGFloat(30.0).proportionalToScreenWidth()))
    }()
    
    /**
     Causes the progress view to be shown or hidden. Default is the value from UI config.
     */
    open var shouldShowProgress = SBAGenericStepUIConfig.shouldShowProgressView() {
        didSet {
            progressView.isHidden = !shouldShowProgress
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     Causes the learn more button to be shown or hidden.
     */
    open var shouldShowLearnMore: Bool = false {
        didSet {
            learnMoreButton.isHidden = !shouldShowLearnMore
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     Causes an image to be shown or hidden. It will assign the provided image (or nil) to the
     imageView. The imageView will be hidden automatically if the imageView.image is nil.
     */
    open var image: UIImage? {
        didSet {
            imageView.image = image
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     An optional view that can be included. It is shown directly below the detailsLabel
     and above the learnMoreButton. This view can be provided by subclasses in the initializeViews()
     method or assigned later.
     */
    open var customView: UIView? {
        didSet {
            if customView != nil {
                self.addSubview(customView!)
                setNeedsUpdateConstraints()
            }
        }
    }
    
    /**
     Causes the main view to be resized to this minimum height, if necessary. The extra needed height
     is added to and divided equally between the top margin and bottom margin of the main view.
     */
    open var minumumHeight: CGFloat = 0.0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    open var progressView: SBAStepProgressView!
    open var learnMoreButton: UIButton!
    
    open var headerLabel: UILabel!
    open var detailsLabel: UILabel!
    open var promptLabel: UILabel!
    open var imageView: UIImageView!
    
    
    /**
     Layout constants. Subclasses can override to customize; otherwise the default private
     constants are used.
     */
    open func constants() -> (
        topMargin: CGFloat,
        bottomMargin: CGFloat,
        sideMargin: CGFloat,
        verticalSpacing: CGFloat,
        imageViewHeight: CGFloat,
        labelMaxLayoutWidth: CGFloat)
    {
        return (kTopMargin,
                kBottomMargin,
                kSideMargin,
                kVerticalSpacing,
                kImageViewHeight,
                kLabelMaxLayoutWidth)
    }
    
    /**
     Create all the view elements. Subclasses can override to provide custom instances. A customView
     can optionally be created here by the subclass.
     */
    open func initializeViews() {
        
        progressView = SBAStepProgressView()
        learnMoreButton = SBAUnderlinedButton()
        
        headerLabel = UILabel()
        detailsLabel = UILabel()
        promptLabel = UILabel()
        imageView = UIImageView()
        
        // customView used by subclass, not initialized here
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        
        initializeViews()
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        learnMoreButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if shouldShowProgress {
            // add progress view
            self.addSubview(progressView)
        }
        
        
        // add imageView
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        
        
        // add labels
        self.addSubview(headerLabel)
        self.addSubview(detailsLabel)
        self.addSubview(promptLabel)
        
        headerLabel.accessibilityTraits = UIAccessibilityTraitHeader
        detailsLabel.accessibilityTraits = UIAccessibilityTraitSummaryElement
        
        headerLabel.numberOfLines = 0
        detailsLabel.numberOfLines = 0
        promptLabel.numberOfLines = 0
        
        headerLabel.font = UIFont.headerViewHeaderLabel
        detailsLabel.font = UIFont.headerViewDetailsLabel
        promptLabel.font = UIFont.headerViewPromptLabel
        
        headerLabel.textColor = UIColor.headerViewHeaderLabel
        detailsLabel.textColor = UIColor.headerViewDetailsLabel
        promptLabel.textColor = UIColor.headerViewPromptLabel
        
        headerLabel.textAlignment = .center
        detailsLabel.textAlignment = .center
        promptLabel.textAlignment = .center
        
        headerLabel.preferredMaxLayoutWidth = constants().labelMaxLayoutWidth
        detailsLabel.preferredMaxLayoutWidth = constants().labelMaxLayoutWidth
        promptLabel.preferredMaxLayoutWidth = constants().labelMaxLayoutWidth
        
        // add learn more button
        self.addSubview(learnMoreButton)
        
        // customView, if any
        if let customView = customView {
            self.addSubview(customView)
        }
        
        setNeedsUpdateConstraints()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        headerLabel.preferredMaxLayoutWidth = headerLabel.frame.size.width
        detailsLabel.preferredMaxLayoutWidth = detailsLabel.frame.size.width
        
        layoutIfNeeded()
    }
    
    open override func updateConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        var gap = constants().topMargin
        
        if shouldShowProgress {
            // progress view
            progressView.alignToSuperview([.leading, .trailing, .top], padding: 0.0)
            
            // image view
            imageView.alignBelow(view: progressView, padding: gap)
            
        } else {
            
            // image view
            imageView.alignToSuperview([.top], padding: gap)
        }
        
        imageView.alignCenterHorizontal(padding: 0.0)
        imageView.makeHeight(.equal, (image == nil ? 0.0 : constants().imageViewHeight))
        
        gap = image != nil ? constants().verticalSpacing : 0.0
        
        // header label
        headerLabel.alignBelow(view: imageView, padding: gap)
        headerLabel.alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
        headerLabel.makeHeight(.greaterThanOrEqual, 0.0)
        
        gap = headerLabel.text != nil ? constants().verticalSpacing : 0.0
        
        // details label
        detailsLabel.alignBelow(view: headerLabel, padding: gap)
        detailsLabel.alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
        detailsLabel.makeHeight(.greaterThanOrEqual, 0.0)
        
        gap = detailsLabel.text != nil ? constants().verticalSpacing : 0.0
        
        if let customView = customView {
            // we align left and right to superview and top to view above
            customView.translatesAutoresizingMaskIntoConstraints = false
            customView.alignBelow(view: detailsLabel, padding: gap)
            customView.alignToSuperview([.leading, .trailing], padding: 0.0)
            
            // we assume the height constraint has been set
            // TODO: Josh Bruhin, 6/12/17 - check for or enforce this
            
            gap = constants().verticalSpacing
        }
        
        // learn more button
        let viewAbove = customView != nil ? customView : detailsLabel
        learnMoreButton.alignBelow(view: viewAbove!, padding: gap)
        learnMoreButton.alignCenterHorizontal(padding: 0.0)
        learnMoreButton.makeHeight(.equal, (shouldShowLearnMore ? kLearnMoreButtonHeight : 0.0))
        
        gap = shouldShowLearnMore ? constants().verticalSpacing : 0.0
        
        // prompt label
        promptLabel.alignBelow(view: learnMoreButton, padding: gap)
        promptLabel.alignCenterHorizontal(padding: 0.0)
        promptLabel.makeHeight(.greaterThanOrEqual, 0.0)
        
        gap = constants().bottomMargin
        
        promptLabel.alignToSuperview([.bottom], padding: gap)
        
        // check our minimum height
        let height = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        if height < minumumHeight {
            
            // adjust our top and bottom margins
            let topConstraint = imageView.constraint(for: .top, relation: .equal)
            let bottomConstraint = promptLabel.constraint(for: .bottom, relation: .equal)
            
            let marginIncrease = (minumumHeight - height) / 2
            topConstraint?.constant += marginIncrease
            bottomConstraint?.constant -= marginIncrease
        }
        
        super.updateConstraints()
    }
}
