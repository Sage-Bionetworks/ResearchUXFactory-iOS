//
//  SBASurveyItem.swift
//  ResearchUXFactory
//
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
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

import ResearchKit

/**
 The `SBAStepTransformer` protocol allows any input model object to be transformed into an `ORKStep`
 */
public protocol SBAStepTransformer: class {
    func transformToStep(with factory: SBABaseSurveyFactory, isLastStep: Bool) -> ORKStep?
}


/**
 The `SBASurveyItem` protocol can be used to transform a model object defined in the input model
 into the appropriate ResearchKit model object. The type of object created is up to the implementation
 class.
 */
public protocol SBASurveyItem: SBAStepTransformer {
    
    /**
     A short string that uniquely identifies the item. This is used as the step identifier
     and, where appropriate, as the form item identifier or task identifier.
     */
    var identifier: String! { get }
    
    /**
     The type of step that this item represents.
    */
    var surveyItemType: SBASurveyItemType { get }
    
    /**
     The primary text to display for the step in a localized string.
    */
    var stepTitle: String? { get }
    
    /**
     Additional text to display for the step in a localized string.
     
     The additional text is displayed in a smaller font below `title`. If you need to display a
     long question, it can work well to keep the title short and put the additional content in
     the `text` property.
     */
    var stepText: String? { get }
    
    /**
     Additional text to display for the step in a localized string at the bottom of the view.
     
     The footnote is displayed in a smaller font below the continue button. It is intended to be used
     in order to include disclaimer, copyright, etc. that is important to display in the step but
     should not distract from the main purpose of the step.
     */
    var stepFootnote: String? { get }
    
    /**
     A key/value dictionary of options used to instantiate the appropriate class of ResearchKit model object.
    */
    var options: [String : AnyObject]? { get }
}


/**
 For the case where an `SBASurveyItem` will transform into an `ORKActiveStep`, the item
 may also implement the `SBAActiveStepSurveyItem` protocol to allow modifying properties 
 on the active step.
 */
public protocol SBAActiveStepSurveyItem: SBASurveyItem {
    
    /**
     Localized text that represents an instructional voice prompt.
     
     Instructional speech begins when the step starts. If VoiceOver is active,
     the instruction is spoken by VoiceOver.
     */
    var stepSpokenInstruction: String? { get }
    
    /**
     Localized text that represents an instructional voice prompt for when the step finishes.
     
     Instructional speech begins when the step finishes. If VoiceOver is active,
     the instruction is spoken by VoiceOver.
     */
    var stepFinishedSpokenInstruction: String? { get }
}


/**
 Additional properties used in creating the appropriate subclass of an `ORKFormStep` or
 `ORKQuestionStep`.
 */
public protocol SBAFormStepSurveyItem: SBASurveyItem {
    
    /**
     A localized string that displays placeholder information for the form item.
     
     You can display placeholder text in a text field or text area to help users understand how to answer the
     item's question. A placeholder string is not appropriate for choice-based answer formats.
     */
    var placeholderText: String? { get }
    
    /**
     Whether or not to create an `ORKQuestionStep` or `ORKFormStep` subclass. If `YES`,
     then the factory will instantiate a `SBANavigationQuestionStep` by default.
    */
    var shouldUseQuestionStyle: Bool { get }
    
    /**
     A Boolean value indicating whether the user can skip the step
     without providing an answer.
     */
    var optional: Bool { get }
    
    /**
     The items array is used to hold a generic list of items appropriate to a given 
     `SBASurveyItemType`.
    */
    var items: [Any]? { get }
    
    /**
     The range property is used to hold a generic object appropriate to a given
     `SBASurveyItemType`.
    */
    var range: AnyObject? { get }
}


/**
 Additional properties used in creating the appropriate subclass of an `ORKInstructionStep`.
 */
public protocol SBAInstructionStepSurveyItem: SBASurveyItem {
    
    /**
     Additional detailed explanation for the instruction.
     
     The detail text is displayed below the content of the `text` property.
     */
    var stepDetail: String? { get }
    
    /**
     An image that provides visual context for the instruction.
     
     The image is displayed with aspect fit. Depending on the device, the screen area
     available for this image can vary. For exact
     metrics, see `ORKScreenMetricIllustrationHeight`.
     */
    var stepImage: UIImage? { get }
    
    /**
     Optional icon image to show above the title and text.
     */
    var iconImage: UIImage? { get }
    
    /**
     @return    An `SBALearnMoreAction` that can be attached to this step.
     */
    func learnMoreAction() -> SBALearnMoreAction?
}


/**
 Additional properties used when creating an `ORKTextFieldAnswerFormat`. This object
 should be returned by the `SBAFormStepSurveyItem` for the `range` property.
 */
public protocol SBATextFieldRange: class {
    
    /**
     The regex used to validate user's input. If set to nil, no validation will be performed. 
     Dictionary key = "validationRegex"
     
     @note If the "validationRegex" is defined using a dictionary key/value pair, then the `invalidMessage` should also be defined.
     */
    var validationRegex: String? { get }
    
    /**
     The text presented to the user when invalid input is received.
     Dictionary key = "invalidMessage"
     */
     var invalidMessage: String? { get }
    
    /**
     The maximum length of the text users can enter. When the value of this property is 0, there is no maximum. 
     Dictionary key = "maximumLength"
     */
    var maximumLength: Int { get }
    
    /**
     Auto-capitalization type for the text field
     */
    var autocapitalizationType: UITextAutocapitalizationType { get }
    
    /**
     Keyboard type for the text field
     */
    var keyboardType: UIKeyboardType { get }
}

extension SBATextFieldRange {
    
    public func createRegularExpression() -> NSRegularExpression? {
        guard let regex = self.validationRegex else { return nil }
        return try? NSRegularExpression(pattern: regex, options: [])
    }
    
}

/**
 Additional properties used when creating an `ORKDateAnswerFormat`. This protocol
 should be returned by the `SBAFormStepSurveyItem` for the `range` property.
 */
public protocol SBADateRange: class {
    
    /**
     The minimum allowed date. When the value of this property is `nil`, there is no minimum.
     */
    var minDate: Date? { get }
    
    /**
     The maximum allowed date. When the value of this property is `nil`, there is no maximum.
     */
    var maxDate: Date? { get }
}

/**
 This protocol should be returned by the `SBAFormStepSurveyItem` for the `range` property when
 the `SBASurveyItem.surveyItemType` is an `integer`, `decimal`, `scale`, or `continuousScale`,
 and for the `SBASurveyItem.items` when `SBASurveyItem.surveyItemType == .timingRange`.
 */
public protocol SBANumberRange: class {
    
    /**
     The minimum allowed number. When the value of this property is `nil`, there is no minimum.
     */
    var minNumber: NSNumber? { get }
    
    /**
     The maximum allowed number. When the value of this property is `nil`, there is no maximum.
     */
    var maxNumber: NSNumber? { get }
    
    /**
     A unit label associated with this property. This property is currently not supported for 
     `ORKContinuousScaleAnswerFormat` or `ORKScaleAnswerFormat`.
    */
    var unitLabel: String? { get }
    
    /**
     A step interval to be used for `ORKContinuousScaleAnswerFormat` or `ORKScaleAnswerFormat`
    */
    var stepInterval: Double { get }
}

/**
 This protocol includes a pointer to a custom step type identifier that can be used by factory
 overrides or an implemnentation of `ORKTaskViewControllerDelegate` to vend a custom step.
 */
public protocol SBACustomTypeStep {
    
    /**
     An identifier for a custom step type.
    */
    var customTypeIdentifier: String? { get }
}


