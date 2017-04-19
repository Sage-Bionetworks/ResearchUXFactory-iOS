//
//  SBAProfileInfoOptions.swift
//  ResearchUXFactory
//
//  Copyright © 2016-2017 Sage Bionetworks. All rights reserved.
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
 The `SBAProfileInfoOption` enum includes the list of demographics and account
 registration items that are commonly required by research studies.
 */
public enum SBAProfileInfoOption : String {
    case email                  = "email"
    case password               = "password"
    case externalID             = "externalID"
    case fullName               = "name"
    case givenName              = "given"
    case familyName             = "family"
    case birthdate              = "birthdate"
    case currentAge             = "currentAge"
    case gender                 = "gender"
    case bloodType              = "bloodType"
    case fitzpatrickSkinType    = "fitzpatrickSkinType"
    case wheelchairUse          = "wheelchairUse"
    case height                 = "height"
    case weight                 = "weight"
    case wakeTime               = "wakeTime"
    case sleepTime              = "sleepTime"
}

/**
 List of possible errors for a given stage of onboarding
 */
public enum SBAProfileInfoOptionsError: Error {
    case missingRequiredOptions
    case missingEmail
    case missingExternalID
    case missingName
    case notConsented
    case unrecognizedSurveyItemType
}

/**
 Model object for converting profile form items into `ORKFormItem` using a string key that
 maps to `SBAProfileInfoOption`
 */
public struct SBAProfileInfoOptions {
    
    /**
     Parsed list of common options to be included with this form.
     */
    public let includes: [SBAProfileInfoOption]
    
    /**
     iVar for storing custom options
     */
    public let customItems: [Any]
    
    /**
     The Auto-capitalization and Keyboard for entering the external ID (if applicable)
     */
    public let extendedOptions: [SBAProfileInfoOption : Any]
    
    /**
     The type of survey step being created.
     */
    public var surveyItemType: SBASurveyItemType
    
    /**
     `ORKFormItem.identifier` for the password confirmation field
     */
    public static let confirmationIdentifier = "passwordConfirmation"
    
    public init(includes: [SBAProfileInfoOption], surveyItemType: SBASurveyItemType = .custom(nil), extendedOptions: [SBAProfileInfoOption : Any] = [:], customItems: [Any] = []) {
        self.surveyItemType = surveyItemType
        self.includes = includes
        self.extendedOptions = extendedOptions
        self.customItems = customItems
    }
    
    public init(include: SBAProfileInfoOption, surveyItemType: SBASurveyItemType = .custom(nil), extendedOption: Any? = nil) {
        self.surveyItemType = surveyItemType
        self.includes = [include]
        self.extendedOptions = {
            guard let ops = extendedOption else { return [:] }
            return [include:ops]
        }()
        self.customItems = []
    }
    
    public init(inputItem: SBASurveyItem?, defaultIncludes: [SBAProfileInfoOption] = []) {
        
        // If the inputItem does not match the protocol for a form step item
        // then set the default includes and exit early
        guard let surveyForm = inputItem as? SBAFormStepSurveyItem,
            let items = surveyForm.items else {
                self.surveyItemType = inputItem?.surveyItemType ?? .custom(nil)
                self.includes = defaultIncludes
                self.extendedOptions = [:]
                self.customItems = []
                return
        }
        
        // Set the item type
        self.surveyItemType = surveyForm.surveyItemType
        
        // Map the includes
        var extendedOptions: [SBAProfileInfoOption : Any] = [:]
        var customItems: [Any] = []
        var includes = items.mapAndFilter({ (obj) -> SBAProfileInfoOption? in
            if let str = obj as? String {
                return SBAProfileInfoOption(rawValue: str)
            }
            else if let dictionary = obj as? [String : AnyObject],
                let identifier = dictionary["identifier"] as? String,
                let option = SBAProfileInfoOption(rawValue: identifier) {
        
                // Special-case the extended options for external ID and password
                // but always store the options.
                switch (option) {
                case .externalID:
                    extendedOptions[.externalID] = SBAExternalIDOptions(options: dictionary)
                case .password:
                    extendedOptions[.password] = SBAPasswordOptions(options: dictionary)
                default:
                    extendedOptions[option] = dictionary
                }
                
                return option
            }
            else {
                customItems.append(obj)
            }
            return nil
        })
        if includes.count == 0 {
            includes = defaultIncludes
        }
        
        self.includes = includes
        self.extendedOptions = extendedOptions
        self.customItems = customItems
    }
    
    public func makeFormItems(factory:SBABaseSurveyFactory? = nil) -> [ORKFormItem] {
        
        var formItems: [ORKFormItem] = []
        
        for option in self.includes {
            switch option {
                
            case .email:
                let formItem = makeEmailFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .password:
                let (formItem, answerFormat, shouldConfirm) = makePasswordFormItem(with: option.rawValue)
                formItems.append(formItem)
                
                // If the password should be confirmed, then add a second field to do so
                if shouldConfirm {
                    let confirmFormItem = makeConfirmationFormItem(formItem: formItem, answerFormat: answerFormat)
                    formItems.append(confirmFormItem)
                }
                
            case .externalID:
                let formItem = makeExternalIDFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .fullName, .givenName, .familyName:
                let formItem = makeNameFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .birthdate:
                let formItem = makeBirthdateFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .currentAge:
                let formItem = makeCurrentAgeFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .gender:
                let formItem = makeGenderFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .bloodType:
                let formItem = makeBloodTypeFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .fitzpatrickSkinType:
                let formItem = makeFitzpatrickSkinTypeFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .wheelchairUse:
                let formItem = makeWheelchairUseFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .height:
                let formItem = makeHeightFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .weight:
                let formItem = makeWeightFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .wakeTime:
                let formItem = makeWakeTimeFormItem(with: option.rawValue)
                formItems.append(formItem)
                
            case .sleepTime:
                let formItem = makeSleepTimeFormItem(with: option.rawValue)
                formItems.append(formItem)
            }
        }
        
        let surveyFactory = factory ?? SBAInfoManager.shared.defaultSurveyFactory
        for item in customItems {
            if let surveyItem = item as? SBAFormStepSurveyItem, surveyItem.isValidFormItem {
                let formItem = surveyFactory.createFormItem(surveyItem)
                formItems.append(formItem)
            }
        }
        
        return formItems
    }
    
    func makeEmailFormItem(with identifier: String) -> ORKFormItem {
        let answerFormat = ORKAnswerFormat.emailAnswerFormat()
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("EMAIL_FORM_ITEM_TITLE"),
                                   answerFormat: answerFormat,
                                   optional: false)
        formItem.placeholder = Localization.localizedString("EMAIL_FORM_ITEM_PLACEHOLDER")
        return formItem
    }
    
    func makePasswordFormItem(with identifier: String) -> (ORKFormItem, ORKTextAnswerFormat, Bool) {
    
        let answerFormat = ORKAnswerFormat.textAnswerFormat()
        answerFormat.multipleLines = false
        answerFormat.isSecureTextEntry = true
        answerFormat.autocapitalizationType = .none
        answerFormat.autocorrectionType = .no
        answerFormat.spellCheckingType = .no
        
        var shouldConfirm: Bool = false
        
        // DO *not* validate the password if this is a login type. Requirements for login
        // can change (get harder) and we don't want to force the user to meet requirements
        // if they already have an older password with weaker requirements.
        if self.surveyItemType != .account(.login) {
            let passwordOptions: SBAPasswordOptions = self.extendedOptions[SBAProfileInfoOption.password] as? SBAPasswordOptions ?? SBAPasswordOptions()
            answerFormat.validationRegex = passwordOptions.validationRegex
            answerFormat.invalidMessage = passwordOptions.invalidMessage
            answerFormat.maximumLength = passwordOptions.maximumLength
            shouldConfirm = passwordOptions.shouldConfirm
        }
        
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("PASSWORD_FORM_ITEM_TITLE"),
                                   answerFormat: answerFormat,
                                   optional: false)
        formItem.placeholder = Localization.localizedString("PASSWORD_FORM_ITEM_PLACEHOLDER")
        
        return (formItem, answerFormat, shouldConfirm)
    }
    
    func makeConfirmationFormItem(formItem: ORKFormItem, answerFormat: ORKTextAnswerFormat) -> ORKFormItem {
        
        // Add a confirmation field
        let confirmIdentifier = SBAProfileInfoOptions.confirmationIdentifier
        let confirmText = Localization.localizedString("CONFIRM_PASSWORD_FORM_ITEM_TITLE")
        let confirmError = Localization.localizedString("CONFIRM_PASSWORD_ERROR_MESSAGE")
        let confirmFormItem = formItem.confirmationAnswer(withIdentifier: confirmIdentifier, text: confirmText,
                                                          errorMessage: confirmError)
        
        confirmFormItem.placeholder = Localization.localizedString("CONFIRM_PASSWORD_FORM_ITEM_PLACEHOLDER")
        
        return confirmFormItem
    }
    
    func makeExternalIDFormItem(with identifier: String) -> ORKFormItem {
        
        let externalIDOptions: SBAExternalIDOptions = self.extendedOptions[SBAProfileInfoOption.externalID] as? SBAExternalIDOptions ?? SBAExternalIDOptions()
        let answerFormat = ORKAnswerFormat.textAnswerFormat()
        answerFormat.multipleLines = false
        answerFormat.autocapitalizationType = externalIDOptions.autocapitalizationType
        answerFormat.autocorrectionType = .no
        answerFormat.spellCheckingType = .no
        answerFormat.keyboardType = externalIDOptions.keyboardType
        
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("SBA_REGISTRATION_EXTERNALID_TITLE"),
                                   answerFormat: answerFormat,
                                   optional: false)
        formItem.placeholder = Localization.localizedString("SBA_REGISTRATION_EXTERNALID_PLACEHOLDER")
        
        return formItem
    }
    
    func makeNameFormItem(with identifier: String) -> ORKFormItem {
        
        let answerFormat = ORKAnswerFormat.textAnswerFormat()
        answerFormat.multipleLines = false
        answerFormat.autocapitalizationType = .words
        answerFormat.autocorrectionType = .no
        answerFormat.spellCheckingType = .no
        answerFormat.keyboardType = .default
        
        let nameType = SBAProfileInfoOption(rawValue: identifier) ?? SBAProfileInfoOption.fullName
        
        
        let (text, placeholder): (String, String) = {
            switch(nameType) {
            case .givenName:
                return (Localization.localizedString("CONSENT_NAME_GIVEN"),
                        Localization.localizedString("CONSENT_NAME_PLACEHOLDER"))
                
            case .familyName:
                return (Localization.localizedString("CONSENT_NAME_FAMILY"),
                         Localization.localizedString("CONSENT_NAME_PLACEHOLDER"))
                    
            default:
                return (Localization.localizedString("SBA_REGISTRATION_FULLNAME_TITLE"),
                        Localization.localizedString("SBA_REGISTRATION_FULLNAME_PLACEHOLDER"))
            }
        }()
        
        let formItem = ORKFormItem(identifier: identifier,
                                       text: text,
                                       answerFormat: answerFormat.copy() as? ORKAnswerFormat,
                                       optional: false)
        formItem.placeholder = placeholder
            
        return formItem
    }
    
    func makeBirthdateFormItem(with identifier: String) -> ORKFormItem {
        
        let characteristic = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        let answerFormat = SBAHealthKitCharacteristicTypeAnswerFormat(characteristicType: characteristic)
        answerFormat.shouldRequestAuthorization = false
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("DOB_FORM_ITEM_TITLE"),
                                   answerFormat: answerFormat,
                                   optional: false)
        formItem.placeholder = Localization.localizedString("DOB_FORM_ITEM_PLACEHOLDER")
        
        return formItem
    }
    
    func makeCurrentAgeFormItem(with identifier: String) -> ORKFormItem {
        let answerFormat = ORKNumericAnswerFormat(style: .integer)
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("AGE_FORM_ITEM_TITLE"),
                                   answerFormat: answerFormat,
                                   optional: false)
        formItem.placeholder = Localization.localizedString("AGE_FORM_ITEM_PLACEHOLDER")
        
        return formItem
    }
    
    func makeGenderFormItem(with identifier: String) -> ORKFormItem {
        
        let characteristic = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
        let answerFormat = SBAHealthKitCharacteristicTypeAnswerFormat(characteristicType: characteristic)
        answerFormat.shouldRequestAuthorization = false
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("GENDER_FORM_ITEM_TITLE"),
                                   answerFormat: answerFormat,
                                   optional: false)
        formItem.placeholder = Localization.localizedString("GENDER_FORM_ITEM_PLACEHOLDER")
        
        return formItem
    }
    
    func makeBloodTypeFormItem(with identifier: String) -> ORKFormItem {
        
        let characteristic = HKObjectType.characteristicType(forIdentifier: .bloodType)!
        let answerFormat = SBAHealthKitCharacteristicTypeAnswerFormat(characteristicType: characteristic)
        answerFormat.shouldRequestAuthorization = false
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("BLOOD_TYPE_FORM_ITEM_TITLE"),
                                   answerFormat: answerFormat,
                                   optional: false)
        formItem.placeholder = Localization.localizedString("BLOOD_TYPE_FORM_ITEM_PLACEHOLDER")
        
        return formItem
    }
    
    func makeFitzpatrickSkinTypeFormItem(with identifier: String) -> ORKFormItem {
        
        let characteristic = HKObjectType.characteristicType(forIdentifier: .fitzpatrickSkinType)!
        let answerFormat = SBAHealthKitCharacteristicTypeAnswerFormat(characteristicType: characteristic)
        answerFormat.shouldRequestAuthorization = false
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("FITZPATRICK_SKIN_TYPE_FORM_ITEM_TITLE"),
                                   answerFormat: answerFormat,
                                   optional: false)
        formItem.placeholder = Localization.localizedString("FITZPATRICK_SKIN_TYPE_FORM_ITEM_PLACEHOLDER")
        
        return formItem
    }
    
    func makeWheelchairUseFormItem(with identifier: String) -> ORKFormItem {
        
        let answerFormat: ORKAnswerFormat = {
            if #available(iOS 10.0, *) {
                let characteristic = HKObjectType.characteristicType(forIdentifier: .wheelchairUse)!
                let answerFormat = SBAHealthKitCharacteristicTypeAnswerFormat(characteristicType: characteristic)
                answerFormat.shouldRequestAuthorization = false
                return answerFormat
            } else {
                return ORKBooleanAnswerFormat()
            }
        }()
        
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("WHEELCHAIR_USE_FORM_ITEM_TITLE"),
                                   answerFormat: answerFormat,
                                   optional: false)
        
        return formItem
    }
    
    func makeHeightFormItem(with identifier: String) -> ORKFormItem {
        
        // Get the locale unit
        var formatterUnit = LengthFormatter.Unit.meter
        let formatter = LengthFormatter()
        formatter.unitStyle = .medium
        formatter.isForPersonHeightUse = true
        formatter.unitString(fromMeters: 2.0, usedUnit: &formatterUnit)
        
        let unit: HKUnit = HKUnit(from: formatterUnit)
        let quantityType = HKObjectType.quantityType(forIdentifier: .height)!
        let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .integer)
        answerFormat.shouldRequestAuthorization = false
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("HEIGHT_FORM_ITEM_TITLE"),
                                   answerFormat: answerFormat,
                                   optional: false)
        
        return formItem
    }
    
    func makeWeightFormItem(with identifier: String) -> ORKFormItem {
        
        // Get the locale unit
        var formatterUnit = MassFormatter.Unit.kilogram
        let formatter = MassFormatter()
        formatter.unitStyle = .medium
        formatter.isForPersonMassUse = true
        formatter.unitString(fromKilograms: 60.0, usedUnit: &formatterUnit)
        
        let unit: HKUnit = HKUnit(from: formatterUnit)
        let quantityType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .integer)
        answerFormat.shouldRequestAuthorization = false
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("WEIGHT_FORM_ITEM_TITLE"),
                                   answerFormat: answerFormat,
                                   optional: false)
        return formItem
    }
    
    func makeWakeTimeFormItem(with identifier: String) -> ORKFormItem {
        
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.hour = 7
        components.minute = 0
        let answerFormat = ORKTimeOfDayAnswerFormat(defaultComponents: components)
        
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("WAKE_TIME_FORM_ITEM_TEXT"),
                                   answerFormat: answerFormat,
                                   optional: false)
        return formItem
    }
    
    func makeSleepTimeFormItem(with identifier: String) -> ORKFormItem {
        
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.hour = 10
        components.minute = 0
        let answerFormat = ORKTimeOfDayAnswerFormat(defaultComponents: components)
        
        let formItem = ORKFormItem(identifier: identifier,
                                   text: Localization.localizedString("SLEEP_TIME_FORM_ITEM_TEXT"),
                                   answerFormat: answerFormat,
                                   optional: false)
        return formItem
    }
}

/**
 For any given result, get the result associated with the given `SBAProfileInfoOption`.
 This could be used in both updating demographics from a user profile and in onboarding.
 */
extension SBAResearchKitResultConverter {
    
    /**
     Method for updating the user's profile. This method will only update non-nil results so that
     if the user skips a step, that doesn't remove the value. This will update the `name` property,
     the `familyName` property and the `birthdate` property using the available values.
     
     @param participantInfo     The participant info object to be updated
     @param profileKeys         A list of keys to update
     */
    public func update(participantInfo: SBAParticipantInfo, with profileKeys: [String]) {
        
        // "Name" can refer to either .givenName or .fullName and depends upon the application
        // To stay compatible with older apps, this field *could* apply to either case.
        let nameKeys: [SBAProfileInfoOption] = [.fullName, .familyName, .givenName]
        let nameSet = Set(nameKeys.map{ $0.rawValue })
        if nameSet.union(profileKeys).count > 0 {
            if let name = self.name {
                participantInfo.name = name
            }
            if let familyName = self.familyName {
                participantInfo.familyName = familyName
            }
        }
        
        // Eligibility and consent can have an age requirement and studies usually track
        // age as demographic data. Generally, actual birthdate is not required but can be
        // estimated from the age that the user enters.
        let birthdayKeys: [SBAProfileInfoOption] = [.birthdate, .currentAge]
        let birthdaySet = Set(birthdayKeys.map{ $0.rawValue })
        if birthdaySet.union(profileKeys).count > 0 {
            if let birthdate = self.birthdate {
                participantInfo.birthdate = birthdate
            }
            else if let currentAge = self.currentAge {
                participantInfo.birthdate = Date(currentAge: currentAge)
            }
        }
        
        // Set the profile for any other keys that are included in the list of keys to update.
        // These values are only updated if non-nil.
        let remainingSet = Set(profileKeys).subtracting(nameSet).subtracting(birthdaySet)
        for key in remainingSet {
            if let storedAnswer = self.storedAnswer(for: key) {
                participantInfo.setStoredAnswer(storedAnswer, forKey: key)
            }
        }
    }
    
    public var name: String? {
        return textAnswer(for: .givenName) ?? textAnswer(for: .fullName)
    }
    
    public var familyName: String? {
        return textAnswer(for: .familyName)
    }
    
    public var email: String? {
        return textAnswer(for: .email)
    }
    
    public var password: String? {
        return textAnswer(for: .password)
    }
    
    public var externalID: String? {
        return textAnswer(for: .externalID)
    }
    
    public var gender: HKBiologicalSex? {
        return convertBiologicalSex(for: .gender)
    }
    
    public var currentAge: Int? {
        return intAnswer(for: SBAProfileInfoOption.currentAge.rawValue)
    }
    
    public var birthdate: Date? {
        return dateOfBirthAnswer(for: SBAProfileInfoOption.birthdate.rawValue)
    }
    
    public var bloodType: HKBloodType? {
        return bloodTypeAnswer(for: SBAProfileInfoOption.bloodType.rawValue)
    }
    
    public var fitzpatrickSkinType: HKFitzpatrickSkinType? {
        return fitzpatrickSkinTypeAnswer(for: SBAProfileInfoOption.fitzpatrickSkinType.rawValue)
    }
    
    public var wheelchairUse: Bool? {
        return wheelchairUseAnswer(for: SBAProfileInfoOption.wheelchairUse.rawValue)
    }
    
    public var height: HKQuantity? {
        return quantity(for: .height)
    }
    
    public var weight: HKQuantity? {
        return quantity(for: .weight)
    }
    
    public var wakeTime: DateComponents? {
        return timeOfDay(for: .wakeTime)
    }
    
    public var sleepTime: DateComponents? {
        return timeOfDay(for: .sleepTime)
    }
    
    func timeOfDay(for option: SBAProfileInfoOption) -> DateComponents? {
        return timeOfDay(for: option.rawValue)
    }
    
    func quantity(for option: SBAProfileInfoOption) -> HKQuantity? {
        return quantity(for: option.rawValue)
    }
    
    func convertBiologicalSex(for option: SBAProfileInfoOption) -> HKBiologicalSex? {
        return self.convertBiologicalSex(for: option.rawValue)
    }
    
    func textAnswer(for option: SBAProfileInfoOption) -> String? {
        return textAnswer(for: option.rawValue)
    }
}
