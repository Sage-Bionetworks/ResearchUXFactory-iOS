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
 The `SBASurveyRule` defines an identifier to skip to and a rule predicate for that step.
 The predicate will only be tested against the owning step. The rules are used to build the 
 appropriate step class that implements the `SBANavigationRule` protocol.
 */
public protocol SBASurveyRule : NSSecureCoding {
    
    /**
     Identifier for the step to skip to.
    */
    var skipIdentifier: String? { get }
    
    // TODO: syoung 01/19/2017 Refactor to deprecate this property in favor of applying a
    // NOT Predicate to the Dictionary implementation.
    /**
     If `YES`, then the skip rule is applied when the `rulePredicate` passes,
     Otherwise, the skip rule is applied when the `rulePredicate` fails.
    */
    var skipIfPassed: Bool { get }
    
    /**
     A rule predicate to use to test the `ORKResult`.
    */
    var rulePredicate: NSPredicate? { get }
}

/**
 Additional properties used in creating the appropriate subclass of an `ORKFormStep` or
 `ORKQuestionStep`.
 */
public protocol SBAFormStepSurveyItem: SBASurveyItem {
    
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
    
    /**
     A list of rules for navigating away from this step.
    */
    var rules: [SBASurveyRule]? { get }
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
     */
    var validationRegex: String? { get }
    
    /**
     The text presented to the user when invalid input is received.
     */
     var invalidMessage: String? { get }
    
    /**
     The maximum length of the text users can enter. When the value of this property is 0, there is no maximum.
     */
    var maximumLength: Int { get }
    
    /**
     A Boolean value indicating whether to expect more than one line of input.
     */
    var multipleLines: Bool { get }
    
    /**
     The autocapitalization type that applies to the user's input.
     */
    var autocapitalizationType: UITextAutocapitalizationType { get }
    
    /**
     The autocorrection type that applies to the user's input.
     */
    var autocorrectionType: UITextAutocorrectionType { get }
    
    /**
     The spell checking type that applies to the user's input.
     */
    var spellCheckingType: UITextSpellCheckingType { get }
    
    /**
     The keyboard type that applies to the user's input.
    */
    var keyboardType: UIKeyboardType { get }
    
    /**
     Identifies whether the text object should hide the text being entered.
     */
    var isSecureTextEntry: Bool { get }
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

extension ORKPasscodeType {
    init?(key: String) {
        switch (key) {
        case SBASurveyItemType.passcodeType6Digit:
            self = .type6Digit
        case SBASurveyItemType.passcodeType4Digit:
            self = .type4Digit
        default:
            return nil
        }
    }
}

/**
 List of all the currently supported step types with the key name for each class type.
 This is used by the `SBABaseSurveyFactory` to determine which subclass of `ORKStep` to return
 for a given `SBASurveyItem`.
*/
public enum SBASurveyItemType {
    
    case custom(String?)
    
    case subtask                                        // SBASubtaskStep
    public static let subtaskKey = "subtask"
    
    case instruction(InstructionSubtype)
    public enum InstructionSubtype: String {
        case instruction        = "instruction"         // ORKInstructionStep
        case completion         = "completion"          // ORKCompletionStep
    }

    case form(FormSubtype)                              // ORKFormStep
    public enum FormSubtype: String {
        case compound           = "compound"            // ORKFormItems > 1
        case toggle             = "toggle"              // SBABooleanToggleFormStep 
        case boolean            = "boolean"             // ORKBooleanAnswerFormat
        case singleChoice       = "singleChoiceText"    // ORKTextChoiceAnswerFormat of style SingleChoiceTextQuestion
        case multipleChoice     = "multipleChoiceText"  // ORKTextChoiceAnswerFormat of style MultipleChoiceTextQuestion
        case text               = "textfield"           // ORKTextAnswerFormat
        case date               = "datePicker"          // ORKDateAnswerFormat of style Date
        case dateTime           = "timeAndDatePicker"   // ORKDateAnswerFormat of style DateTime
        case time               = "timePicker"          // ORKTimeOfDayAnswerFormat
        case duration           = "timeInterval"        // ORKTimeIntervalAnswerFormat
        case integer            = "numericInteger"      // ORKNumericAnswerFormat of style Integer
        case decimal            = "numericDecimal"      // ORKNumericAnswerFormat of style Decimal
        case scale              = "scaleInteger"        // ORKScaleAnswerFormat
        case continuousScale    = "continuousScale"     // ORKContinuousScaleAnswerFormat
        case timingRange        = "timingRange"         // Timing Range: ORKTextChoiceAnswerFormat of style SingleChoiceTextQuestion
    }

    case consent(ConsentSubtype)
    public enum ConsentSubtype: String {
        case sharingOptions     = "consentSharingOptions"   // ORKConsentSharingStep
        case review             = "consentReview"           // ORKConsentReviewStep
        case visual             = "consentVisual"           // ORKVisualConsentStep
    }
    
    case account(AccountSubtype)
    public enum AccountSubtype: String {
        case registration       = "registration"            // ORKRegistrationStep
        case login              = "login"                   // SBAProfileFormStep
        case emailVerification  = "emailVerification"       // Custom
        case externalID         = "externalID"              // SBAProfileFormStep
        case permissions        = "permissions"             // SBAPermissionsStep
        case dataGroups         = "dataGroups"              // SBADataGroupsStep
        case profile            = "profile"                 // SBAProfileFormStep
    }
    
    case passcode(ORKPasscodeType)
    public static let passcodeType6Digit = "passcodeType6Digit"
    public static let passcodeType4Digit = "passcodeType4Digit"
    
    public init(rawValue: String?) {
        guard let type = rawValue else { self = .custom(nil); return }
        
        if let subtype = InstructionSubtype(rawValue: type) {
            self = .instruction(subtype)
        }
        else if let subtype = FormSubtype(rawValue: type) {
            self = .form(subtype)
        }
        else if let subtype = ConsentSubtype(rawValue: type) {
            self = .consent(subtype)
        }
        else if let subtype = AccountSubtype(rawValue: type) {
            self = .account(subtype)
        }
        else if let subtype = ORKPasscodeType(key: type) {
            self = .passcode(subtype)
        }
        else if type == SBASurveyItemType.subtaskKey {
            self = .subtask
        }
        else {
            self = .custom(type)
        }
    }
        
    public func formSubtype() -> FormSubtype? {
        if case .form(let subtype) = self {
            return subtype
        }
        return nil
    }
    
    public func consentSubtype() -> ConsentSubtype? {
        if case .consent(let subtype) = self {
            return subtype
        }
        return nil
    }
    
    public func accountSubtype() -> AccountSubtype? {
        if case .account(let subtype) = self {
            return subtype
        }
        return nil
    }
    
    public func isNilType() -> Bool {
        if case .custom(let customType) = self {
            return (customType == nil)
        }
        return false
    }
}

extension SBASurveyItemType: Equatable {
}

public func ==(lhs: SBASurveyItemType, rhs: SBASurveyItemType) -> Bool {
    switch (lhs, rhs) {
    case (.instruction(let lhsValue), .instruction(let rhsValue)):
        return lhsValue == rhsValue;
    case (.form(let lhsValue), .form(let rhsValue)):
        return lhsValue == rhsValue;
    case (.consent(let lhsValue), .consent(let rhsValue)):
        return lhsValue == rhsValue;
    case (.account(let lhsValue), .account(let rhsValue)):
        return lhsValue == rhsValue;
    case (.passcode(let lhsValue), .passcode(let rhsValue)):
        return lhsValue == rhsValue;
    case (.subtask, .subtask):
        return true
    case (.custom(let lhsValue), .custom(let rhsValue)):
        return lhsValue == rhsValue;
    default:
        return false
    }
}

public protocol SBACustomTypeStep {
    var customTypeIdentifier: String? { get }
}

extension SBASurveyItemType: SBACustomTypeStep {
    public var customTypeIdentifier: String? {
        if case .custom(let type) = self {
            return type
        }
        return nil
    }
}

