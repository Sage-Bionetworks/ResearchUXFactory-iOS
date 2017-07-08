//
//  SBABaseSurveyFactory.swift
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
 The purpose of the Survey Factory is to allow subclassing for custom types of steps
 that are not recognized by this factory and to allow usage by Obj-c classes that
 do not recognize protocol extensions.
 */
open class SBABaseSurveyFactory : NSObject {
    
    open var steps: [ORKStep]?
    
    public override init() {
        super.init()
    }
    
    public convenience init?(jsonNamed: String) {
        guard let json = SBAResourceFinder.shared.json(forResource: jsonNamed) else { return nil }
        self.init(dictionary: json as NSDictionary)
    }
    
    public convenience init(dictionary: NSDictionary) {
        self.init()
        
        // Map the consent sections into a consent document (if applicable)
        self.mapConsentDocumentSectionsIfNeeded(with: dictionary)
        
        // Map the steps (if applicable)
        self.mapSteps(with: dictionary)
    }
    
    /**
     Convenience method for mapping the steps from the given dictionary into this instance
     of the factory.
     
     @param dictionary  dictionary with the steps to map
    */
    public func mapSteps(with dictionary: NSDictionary) {
        if let steps = dictionary["steps"] as? [NSDictionary] {
            self.steps = steps.mapAndFilter({ self.createSurveyStepWithDictionary($0) })
        }
    }
    
    /**
     In general, do not override this method. Instead, override the method for injection of the steps
     for a given subgroup type. This is the base-level factory method used to vend the step appropriate
     to the given `surveyItemType` for this `SBASurveyItem`.
     @param inputItem       A model object that matches the protocol for an `SBASurveyItem`
     @param isSubtaskStep   `YES` if this is called as a sub-step element of another step, otherwise `NO`
     @return                An `ORKStep` or nil
    */
    open func createSurveyStep(_ inputItem: SBASurveyItem, isSubtaskStep: Bool = false) -> ORKStep? {
        switch (inputItem.surveyItemType) {
            
        case .instruction(_):
            return SBAInstructionStep(inputItem: inputItem)
            
        case .subtask:
            if let form = inputItem as? SBAFormStepSurveyItem {
                return form.createSubtaskStep(with: self)
            } else { break }
            
        case .form(_):
            if let form = inputItem as? SBAFormStepSurveyItem {
                return createFormStep(form, isSubtaskStep: isSubtaskStep)
            } else { break }
        
        case .dataGroups(_):
            return createDataGroupsStep(inputItem: inputItem)
            
        case .account(let subtype):
            return createAccountStep(inputItem: inputItem, subtype: subtype)
            
        case .passcode(let passcodeType):
            let step = ORKPasscodeStep(identifier: inputItem.identifier)
            step.title = inputItem.stepTitle
            step.text = inputItem.stepText
            step.passcodeType = passcodeType
            return step
            
        case .consent(let subtype):
            return createConsentStep(inputItem: inputItem, subtype: subtype)
            
        default:
            break
        }
        return createSurveyStepWithCustomType(inputItem)
    }
    
    /**
     Factory method for creating an SBANavigableOrderedTask from the current steps
     @param identifier  The task identifier
     @return            Task created with the steps initialized with this factory
     */
    open func createTaskWithIdentifier(_ identifier: String) -> SBANavigableOrderedTask {
        return SBANavigableOrderedTask(identifier: identifier, steps: steps)
    }
    
    /**
     Factory method for creating an ORKTask from an SBAActiveTask
     @param activeTask      An `SBAActiveTask` active task
     @param taskOptions     Task options for this task
     @return                An encodable, copyable `ORKTask`
     */
    open func createTaskWithActiveTask(_ activeTask: SBAActiveTask, taskOptions: ORKPredefinedTaskOption) ->
        (ORKTask & NSCopying & NSSecureCoding)? {
        return activeTask.createDefaultORKActiveTask(taskOptions)
    }

    /**
     Factory method for creating a survey step with a dictionary
     @param dictionary      Dictionary defining the step
     @return                An `ORKStep`
     */
    open func createSurveyStepWithDictionary(_ dictionary: NSDictionary) -> ORKStep? {
        return self.createSurveyStep(dictionary)
    }
    
    /**
     Factory method for creating a custom type of survey question that is not
     defined by this class. Note: Only swift can subclass this method directly
     @param inputItem       An input item conforming to the `SBASurveyItem` protocol
     @return                An `ORKStep`
     */
    open func createSurveyStepWithCustomType(_ inputItem: SBASurveyItem) -> ORKStep? {
        switch (inputItem.surveyItemType) {
        case .custom(_):
            return SBAInstructionStep(inputItem: inputItem)
        default:
            return nil
        }
    }
    
    /**
     Factory method for creating a step where the step uses tracked items to build the step.
     Note: only swift can subclass this method directly.
     @param inputItem       An input item conforming to the `SBASurveyItem` protocol
     @param trackingType    The tracking type for the survey item
     @param trackedItems    The list of all tracked data objects used to define this step
     @return                An `ORKStep`
     */
    open func createSurveyStep(_ inputItem: SBASurveyItem, trackingType: SBATrackingStepType, trackedItems: [SBATrackedDataObject]) -> ORKStep? {
        if trackingType == .activity, let activityItem = inputItem as? SBATrackedActivitySurveyItem {
            // Let the activity item return the appropriate instance of the step
            return activityItem.createTrackedActivityStep(trackedItems, factory: self)
        }
        else if trackingType == .selection, let selectionItem = inputItem as? SBAFormStepSurveyItem {
            return SBATrackedSelectionStep(inputItem: selectionItem, trackedItems: trackedItems, factory: self)
        }
        else {
            // Otherwise, return the step from the factory
            return self.createSurveyStep(inputItem)
        }
    }
    
    /**
     Factory method for injecting an override of the functionality supported by the `SBAFormStepSurveyItem`
     protocol extension. Because a protocol extension cannot be overriden, this method allows the injection 
     of customization of the default answer format.
     @param inputItem       An input item conforming to the `SBAFormStepSurveyItem` protocol
     @param subtype         The form subtype to use when creating the answer format
     @return                An answer format.
    */
    open func createAnswerFormat(_ inputItem: SBAFormStepSurveyItem, subtype: SBASurveyItemType.FormSubtype?) -> ORKAnswerFormat? {
        return inputItem.createAnswerFormat(subtype)
    }
    
    /**
     Factory method for injecting an override of the functionality supported by the `SBAFormStepSurveyItem`
     protocol extension. Because a protocol extension cannot be overriden, this method allows the injection
     of customization of the default form item.
     @param inputItem       An input item conforming to the `SBAFormStepSurveyItem` protocol
     @param subtype         The form subtype to use when creating the answer format
     @return                A form item.
    */
    open func createFormItem(_ inputItem:SBAFormStepSurveyItem, subtype: SBASurveyItemType.FormSubtype? = nil) -> ORKFormItem {
        let subtype = inputItem.surveyItemType.formSubtype() ?? subtype
        return inputItem.createFormItem(text: inputItem.stepText, subtype: subtype, factory: self)
    }
    
    /**
     Factory method for injecting an override of the functionality supported by the `SBAFormStepSurveyItem`
     protocol extension. Because a protocol extension cannot be overriden, this method allows the injection
     of customization of the default form item.
     @param inputItem       An input item conforming to the `SBAFormStepSurveyItem` protocol
     @param isSubtaskStep   Whether or not this is a subtask step
     @return                step
     */
    open func createFormStep(_ inputItem:SBAFormStepSurveyItem, isSubtaskStep: Bool = false) -> ORKStep? {
        
        // If this item should use the question style then create accordingly
        if inputItem.shouldUseQuestionStyle {
            return SBANavigationQuestionStep(inputItem: inputItem, factory: self)
        }
        
        // Factory method for determining the proper type of form-style step to return
        // the ORKQuestionStep and ORKFormStep have a different UI presentation
        let step: ORKStep =
            // If this is a boolean toggle step then that casting takes priority
            inputItem.isBooleanToggle ? SBAToggleFormStep(inputItem: inputItem) :
            // If this is *not* a subtask step and it uses navigation then return a survey form step
            (!isSubtaskStep && inputItem.usesNavigation()) ? SBANavigationFormStep(inputItem: inputItem) :
            // Otherwise, use a form step
            SBAFormStep(identifier: inputItem.identifier)
        
        inputItem.buildFormItems(with: step as! SBAFormStepProtocol, isSubtaskStep: isSubtaskStep, factory: self)
        inputItem.mapStepValues(with: step)
        return step
    }
    
    /**
     Factory method for injecting an override of the functionality specific to account handling.
     This allows for custom steps to be returned.
    */
    open func createAccountStep(inputItem: SBASurveyItem, subtype: SBASurveyItemType.AccountSubtype) -> ORKStep? {
        switch (subtype) {
        case .registration:
            return ORKRegistrationStep(identifier: inputItem.identifier, title: inputItem.stepTitle, text: inputItem.stepText)
        case .permissions:
            return SBAPermissionsStep(inputItem: inputItem)
        case .emailVerification:
            let step = SBAInstructionStep(inputItem: inputItem)
            step.customTypeIdentifier = subtype.rawValue
            return step
        case .profile, .login, .externalID:
            return SBAProfileFormStep(inputItem: inputItem, factory: self)
        }
    }
    
    /**
     Factory method for injecting an override of the creation of a data groups step.
     */
    open func createDataGroupsStep(inputItem: SBASurveyItem) -> ORKStep? {
        return SBADataGroupsStep(inputItem: inputItem)
    }
    
    /**
     The consent document is created on demand using a lazy initializer with 
     default values for the required fields.
    */
    lazy open var consentDocument: ORKConsentDocument = {
        // Setup the consent document
        let consentDocument = ORKConsentDocument()
        consentDocument.title = Localization.localizedString("SBA_CONSENT_TITLE")
        consentDocument.signaturePageTitle = Localization.localizedString("SBA_CONSENT_TITLE")
        consentDocument.signaturePageContent = Localization.localizedString("SBA_CONSENT_SIGNATURE_CONTENT")
        
        // Add the signature
        let signature = ORKConsentSignature(forPersonWithTitle: Localization.localizedString("SBA_CONSENT_PERSON_TITLE"), dateFormatString: nil, identifier: "participant")
        consentDocument.addSignature(signature)
        
        return consentDocument
    }()
    
    /**
     Map the consent sections and document properties from the given dictionary.
     If this instance of the factory uses consent sections then the `consentDocument`
     will be initialized and the sections will be added to it.
    */
    open func mapConsentDocumentSectionsIfNeeded(with dictionary: NSDictionary) {
        
        // Load the sections
        var previousSectionType: SBAConsentSectionType?
        if let sections = dictionary["sections"] as? [NSDictionary] {
            self.consentDocument.sections = sections.map({ (dictionarySection) -> ORKConsentSection in
                let consentSection = dictionarySection.createConsentSection(previous: previousSectionType)
                previousSectionType = dictionarySection.consentSectionType
                // If this is an `.onlyInDocument` type then set this to the html review by default
                if consentSection.type == .onlyInDocument, let htmlContent = consentSection.htmlContent {
                    self.consentDocument.htmlReviewContent = htmlContent
                }
                return consentSection
            })
        }
        
    }

    /**
     Override the base class to implement creating consent steps.
     @param inputItem   The item used to create the step
     @param subtype     The `SBASurveyItemType.ConsentSubtype` for this step
     @return            The step created by the factory
     */
    open func createConsentStep(inputItem: SBASurveyItem, subtype: SBASurveyItemType.ConsentSubtype) -> ORKStep? {
        switch (subtype) {
            
        case .visual:
            return SBAVisualConsentStep(identifier: inputItem.identifier, consentDocument: self.consentDocument)
            
        case .sharingOptions:
            let share = inputItem as! SBAConsentSharingOptions
            let step = ORKConsentSharingStep(identifier: inputItem.identifier,
                                             investigatorShortDescription: share.investigatorShortDescription,
                                             investigatorLongDescription: share.investigatorLongDescription,
                                             localizedLearnMoreHTMLContent: share.localizedLearnMoreHTMLContent)
            
            if let additionalText = inputItem.stepText, let text = step.text {
                step.text = "\(text)\n\n\(additionalText)"
            }
            if let form = inputItem as? SBAFormStepSurveyItem,
                let textChoices = form.items?.map({form.createTextChoice(from: $0)}) {
                step.answerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
            }
            
            return step;
            
        case .review:
            let step = ORKConsentReviewStep(identifier: inputItem.identifier,
                                            signature: self.consentDocument.signatures?.first,
                                            in: self.consentDocument)
            step.reasonForConsent = Localization.localizedString("SBA_CONSENT_SIGNATURE_CONTENT")
            return step;
        }
    }

}

extension SBASurveyItem {
}

extension SBAInstructionStepSurveyItem {
}

extension SBAFormStepSurveyItem {
    
    var isValidFormItem: Bool {
        return (self.identifier != nil) && (self.surveyItemType.formSubtype() != nil)
    }
    
    var isBooleanToggle: Bool {
        return SBASurveyItemType.form(.toggle) == self.surveyItemType
    }
    
    var isCompoundStep: Bool {
        return isBooleanToggle || (SBASurveyItemType.form(.compound) == self.surveyItemType)
    }
    
    func usesNavigation() -> Bool {
        guard let ruleGroup = self as? SBASurveyRuleGroup else { return false }
        return ruleGroup.hasNavigationRules()
    }
    
    public func createSubtaskStep(with factory:SBABaseSurveyFactory) -> SBASubtaskStep {
        assert((self.items?.count ?? 0) > 0, "A subtask step requires items")
        let steps = self.items?.mapAndFilter({ factory.createSurveyStep($0 as! SBASurveyItem, isSubtaskStep: true) })
        let step = self.usesNavigation() ?
            SBANavigationSubtaskStep(inputItem: self, steps: steps) :
            SBASubtaskStep(identifier: self.identifier, steps: steps)
        return step
    }
    
    public func mapStepValues(with step: ORKStep) {
        step.title = self.stepTitle?.trim()
        step.text = self.stepText?.trim()
        step.isOptional = self.optional
        if let formStep = step as? ORKFormStep {
            formStep.footnote = self.stepFootnote
        }
    }
    
    public func buildFormItems(with step: SBAFormStepProtocol, isSubtaskStep: Bool, factory: SBABaseSurveyFactory? = nil) {
        
        if self.isCompoundStep {
            let factory = factory ?? SBAInfoManager.shared.defaultSurveyFactory
            step.formItems = self.items?.map({
                return factory.createFormItem($0 as! SBAFormStepSurveyItem)
            })
        }
        else {
            let subtype = self.surveyItemType.formSubtype()
            step.formItems = [self.createFormItem(text: nil, subtype: subtype, factory: factory)]
        }
    }
        
    func createFormItem(text: String?, subtype: SBASurveyItemType.FormSubtype?, factory: SBABaseSurveyFactory? = nil) -> ORKFormItem {
        let answerFormat = factory?.createAnswerFormat(self, subtype: subtype) ?? self.createAnswerFormat(subtype)
        let formItem = ORKFormItem(identifier: self.identifier, text: text, answerFormat: answerFormat, optional: self.optional)
        formItem.placeholder = self.placeholderText
        return formItem
    }
    
    public func createAnswerFormat(_ subtype: SBASurveyItemType.FormSubtype?) -> ORKAnswerFormat? {
        let subtype = subtype ?? SBASurveyItemType.FormSubtype.boolean
        switch(subtype) {
        case .boolean:
            return ORKBooleanAnswerFormat()
        case .text, .multipleLineText:
            let answerFormat = ORKTextAnswerFormat()
            answerFormat.multipleLines = (subtype == .multipleLineText)
            if let range = self.range as? SBATextFieldRange {
                if let validationRegex = range.createRegularExpression() {
                    answerFormat.validationRegularExpression = validationRegex
                    answerFormat.invalidMessage = {
                        guard let invalidMessage = range.invalidMessage else {
                            print("Warning: The validation Regex does not have an associated validation message.")
                            return Localization.localizedString("INVALID_REGEX_MESSAGE")
                        }
                        return invalidMessage
                    }()
                }
                answerFormat.maximumLength = range.maximumLength
                answerFormat.autocapitalizationType = range.autocapitalizationType
                answerFormat.keyboardType = range.keyboardType
            }
            return answerFormat
        case .singleChoice, .multipleChoice:
            guard let textChoices = self.items?.map({createTextChoice(from: $0)}) else { return nil }
            let style: ORKChoiceAnswerStyle = (subtype == .singleChoice) ? .singleChoice : .multipleChoice
            return ORKTextChoiceAnswerFormat(style: style, textChoices: textChoices)
        case .mood:
            return self.createMoodScaleAnswerFormat()
        case .date, .dateTime:
            let style: ORKDateAnswerStyle = (subtype == .date) ? .date : .dateAndTime
            let range = self.range as? SBADateRange
            return ORKDateAnswerFormat(style: style, defaultDate: nil, minimumDate: range?.minDate as Date?, maximumDate: range?.maxDate as Date?, calendar: nil)
        case .time:
            return ORKTimeOfDayAnswerFormat()
        case .duration:
            return ORKTimeIntervalAnswerFormat()
        case .integer, .decimal, .scale, .continuousScale:
            guard let range = self.range as? SBANumberRange else {
                assertionFailure("\(subtype) requires a valid number range")
                return nil
            }
            return range.createAnswerFormat(with: subtype)
        case .timingRange:
            guard let textChoices = self.items?.mapAndFilter({ (obj) -> ORKTextChoice? in
                guard let item = obj as? SBANumberRange else { return nil }
                return item.createORKTextChoice()
            }) else { return nil }
            let notSure = ORKTextChoice(text: Localization.localizedString("SBA_NOT_SURE_CHOICE"), value: "Not sure" as NSString)
            return ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices + [notSure])
        case .compound, .toggle:
            assertionFailure("Form item question type .compound or .toggle is not supported as an answer format")
            return nil
        }
    }
    
    public func createTextChoice(from obj: Any) -> ORKTextChoice {
        guard let textChoice = obj as? SBATextChoice else {
            assertionFailure("Passing object \(obj) does not match expected protocol SBATextChoice")
            return ORKTextChoice(text: "", detailText: nil, value: NSNull(), exclusive: false)
        }
        return textChoice.createORKTextChoice()
    }
    
    public func createMoodScaleAnswerFormat(with defaultChoices:[ORKImageChoice]? = nil) -> ORKMoodScaleAnswerFormat {
        let moodChoices = defaultChoices ?? ORKMoodScaleAnswerFormat(moodQuestionType: .custom).imageChoices
        guard let items = self.items, moodChoices.count == items.count
        else {
            return ORKMoodScaleAnswerFormat(imageChoices: moodChoices)
        }
        let imageChoices = moodChoices.enumerated().map { (idx: Int, moodChoice: ORKImageChoice) -> ORKImageChoice in
            guard let choice = items[idx] as? SBAImageChoice else { return moodChoice }
            return choice.createORKImageChoice(with: moodChoice)
        }
        return ORKMoodScaleAnswerFormat(imageChoices: imageChoices)
    }
}

extension SBANumberRange {
    
    func createAnswerFormat(with subtype: SBASurveyItemType.FormSubtype) -> ORKAnswerFormat {
        
        if (subtype == .scale) || (subtype == .continuousScale), self.stepInterval >= 0,
            // If this is a scale subtype then check that the max, min and step interval are valid
            let min = self.minNumber?.doubleValue, let max = self.maxNumber?.doubleValue, (max > min)
        {
            if (subtype == .scale)  {
                // ResearchKit will throw an assertion if the number of steps is greater than 13 so
                // hardcode a check for whether or not to use a continuous scale based on that number
                let interval = Double(self.stepInterval)
                let numberOfSteps = floor((max - min) / interval)
                if (numberOfSteps > 13) || (numberOfSteps * interval != (max - min)) {
                    return ORKContinuousScaleAnswerFormat(maximumValue: max, minimumValue: min, defaultValue: 0.0, maximumFractionDigits: 0)
                }
                else {
                    return ORKScaleAnswerFormat(maximumValue: self.maxNumber!.intValue, minimumValue: self.minNumber!.intValue, defaultValue: 0, step: Int(self.stepInterval))
                }
            }
            else {
                // Calculate the number of digits to use based on the step interval
                var digits: Int = 0
                var pow: Double = 1.0
                let step = self.stepInterval
                while (step < pow) {
                    pow = pow / 10.0
                    digits = digits + 1
                }
                return ORKContinuousScaleAnswerFormat(maximumValue: max, minimumValue: min, defaultValue: 0.0, maximumFractionDigits: digits)
            }
        }
        
        // Fall through for non-scale or invalid scale type
        let style: ORKNumericAnswerStyle = (subtype == .decimal) || (subtype == .continuousScale) ? .decimal : .integer
        return ORKNumericAnswerFormat(style: style, unit: self.unitLabel, minimum: self.minNumber, maximum: self.maxNumber)
    }
    
    // Return a timing interval
    func createORKTextChoice() -> ORKTextChoice? {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = timeIntervalUnit
        formatter.unitsStyle = .full
        let unitText = self.unitLabel ?? "seconds"
        let calendarUnit = self.timeIntervalUnit
        
        // Note: in all cases, the value is returned in English so that the localized 
        // values will result in the same answer in any table. It is up to the researcher to translate.
        if let maxNum = self.maxNumber?.intValue,
            let max = dateComponents(value: maxNum, calendarUnit: calendarUnit),
            let maxString = formatter.string(from: max) {
            
            if let minNum = self.minNumber?.intValue {
                let maxText = Localization.localizedStringWithFormatKey("SBA_RANGE_%@_AGO", maxString)
                return ORKTextChoice(text: "\(minNum)-\(maxText)",
                                     value: "\(minNum)-\(maxNum) \(unitText) ago"  as NSString)
            }
            else {
                let text = Localization.localizedStringWithFormatKey("SBA_LESS_THAN_%@_AGO", maxString)
                return ORKTextChoice(text: text, value: "Less than \(maxNum) \(unitText) ago"  as NSString)
            }
        }
        else if let minNum = self.minNumber?.intValue,
            let min = dateComponents(value: minNum, calendarUnit: calendarUnit),
            let minString = formatter.string(from: min) {
            
            let text = Localization.localizedStringWithFormatKey("SBA_MORE_THAN_%@_AGO", minString)
            return ORKTextChoice(text: text, value: "More than \(minNum) \(unitText) ago" as NSString)
        }
        
        assertionFailure("Not a valid range with neither a min or max value defined")
        return nil
    }
    
    var timeIntervalUnit: NSCalendar.Unit {
        guard let unit = self.unitLabel else { return NSCalendar.Unit.second }
        switch unit {
        case "minutes" :
            return NSCalendar.Unit.minute
        case "hours" :
            return NSCalendar.Unit.hour
        case "days" :
            return NSCalendar.Unit.day
        case "weeks" :
            return NSCalendar.Unit.weekOfMonth
        case "months" :
            return NSCalendar.Unit.month
        case "years" :
            return NSCalendar.Unit.year
        default :
            return NSCalendar.Unit.second
        }
    }
    
    func dateComponents(value: Int, calendarUnit: NSCalendar.Unit) -> DateComponents? {
        var components = DateComponents()
        switch(calendarUnit) {
        case NSCalendar.Unit.year:
            components.year = value
        case NSCalendar.Unit.month:
            components.month = value
        case NSCalendar.Unit.weekOfMonth:
            components.weekOfYear = value
        case NSCalendar.Unit.hour:
            components.hour = value
        case NSCalendar.Unit.minute:
            components.minute = value
        default:
            components.second = value
        }
        return components
    }

}



