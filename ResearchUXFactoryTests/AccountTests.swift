//
//  SBAAccountTests.swift
//  ResearchUXFactory
//
//  Copyright (c) 2016 Sage Bionetworks. All rights reserved.
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

import XCTest
@testable import ResearchUXFactory

class SBAAccountTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateProfileFormStep() {
        let input: NSDictionary = [
            "identifier"    : "profile",
            "type"          : "profile",
            "title"         : "Profile",
            "items"         : ["externalID", "name", "birthdate", "gender", "bloodType", "fitzpatrickSkinType", "wheelchairUse", "height", "weight", "wakeTime", "sleepTime", ["identifier" : "chocolate", "type" : "boolean", "text" : "Do you like chocolate?"]]
        ]
        
        let step = SBAProfileFormStep(inputItem: input)
        XCTAssertEqual(step.identifier, "profile")
        XCTAssertEqual(step.title, "Profile")

        let externalIDItem = step.formItem(for:"externalID")
        let externalID = externalIDItem?.answerFormat as? ORKTextAnswerFormat
        XCTAssertNotNil(externalIDItem)
        XCTAssertNotNil(externalID, "\(String(describing: externalIDItem?.answerFormat))")
        
        let nameItem = step.formItem(for:"name")
        let name = nameItem?.answerFormat as? ORKTextAnswerFormat
        XCTAssertNotNil(nameItem)
        XCTAssertNotNil(name, "\(String(describing: nameItem?.answerFormat))")
        
        let birthdateItem = step.formItem(for:"birthdate")
        let birthdate = birthdateItem?.answerFormat as? ORKHealthKitCharacteristicTypeAnswerFormat
        XCTAssertNotNil(birthdateItem)
        XCTAssertNotNil(birthdate, "\(String(describing: birthdateItem?.answerFormat))")
        XCTAssertEqual(birthdate!.characteristicType.identifier, HKCharacteristicTypeIdentifier.dateOfBirth.rawValue)
        
        let genderItem = step.formItem(for:"gender")
        let gender = genderItem?.answerFormat as? ORKHealthKitCharacteristicTypeAnswerFormat
        XCTAssertNotNil(genderItem)
        XCTAssertNotNil(gender, "\(String(describing: genderItem?.answerFormat))")
        XCTAssertEqual(gender!.characteristicType.identifier, HKCharacteristicTypeIdentifier.biologicalSex.rawValue)
        
        let bloodTypeItem = step.formItem(for:"bloodType")
        let bloodType = bloodTypeItem?.answerFormat as? ORKHealthKitCharacteristicTypeAnswerFormat
        XCTAssertNotNil(bloodTypeItem)
        XCTAssertNotNil(bloodType, "\(String(describing: bloodTypeItem?.answerFormat))")
        XCTAssertEqual(bloodType!.characteristicType.identifier, HKCharacteristicTypeIdentifier.bloodType.rawValue)

        let fitzpatrickSkinTypeItem = step.formItem(for:"fitzpatrickSkinType")
        let fitzpatrickSkinType = fitzpatrickSkinTypeItem?.answerFormat as? ORKHealthKitCharacteristicTypeAnswerFormat
        XCTAssertNotNil(fitzpatrickSkinTypeItem)
        XCTAssertNotNil(fitzpatrickSkinType, "\(String(describing: fitzpatrickSkinTypeItem?.answerFormat))")
        XCTAssertEqual(fitzpatrickSkinType!.characteristicType.identifier, HKCharacteristicTypeIdentifier.fitzpatrickSkinType.rawValue)

        let wheelchairUseItem = step.formItem(for:"wheelchairUse")
        XCTAssertNotNil(wheelchairUseItem)
        if #available(iOS 10.0, *) {
            let wheelchairUse = wheelchairUseItem?.answerFormat as? ORKHealthKitCharacteristicTypeAnswerFormat
            XCTAssertNotNil(wheelchairUse, "\(String(describing: wheelchairUseItem?.answerFormat))")
            XCTAssertEqual(wheelchairUse!.characteristicType.identifier, HKCharacteristicTypeIdentifier.wheelchairUse.rawValue)
        }
        else {
            let wheelchairUse = wheelchairUseItem?.answerFormat as? ORKBooleanAnswerFormat
            XCTAssertNotNil(wheelchairUse, "\(String(describing: wheelchairUseItem?.answerFormat))")
        }
        
        let heightItem = step.formItem(for:"height")
        let height = heightItem?.answerFormat as? ORKHealthKitQuantityTypeAnswerFormat
        XCTAssertNotNil(heightItem)
        XCTAssertNotNil(height, "\(String(describing: heightItem?.answerFormat))")
        XCTAssertEqual(height!.quantityType.identifier, HKQuantityTypeIdentifier.height.rawValue)

        let weightItem = step.formItem(for:"weight")
        let weight = weightItem?.answerFormat as? ORKHealthKitQuantityTypeAnswerFormat
        XCTAssertNotNil(weightItem)
        XCTAssertNotNil(weight, "\(String(describing: weightItem?.answerFormat))")
        XCTAssertEqual(weight!.quantityType.identifier, HKQuantityTypeIdentifier.bodyMass.rawValue)

        let wakeTimeItem = step.formItem(for:"wakeTime")
        let wakeTime = wakeTimeItem?.answerFormat as? ORKTimeOfDayAnswerFormat
        XCTAssertNotNil(wakeTimeItem)
        XCTAssertNotNil(wakeTime, "\(String(describing: wakeTimeItem?.answerFormat))")
        let wakeHour = wakeTime?.defaultComponents?.hour
        XCTAssertNotNil(wakeHour)
        XCTAssertEqual(wakeHour!, 7)

        let sleepTimeItem = step.formItem(for:"sleepTime")
        let sleepTime = sleepTimeItem?.answerFormat as? ORKTimeOfDayAnswerFormat
        XCTAssertNotNil(sleepTimeItem)
        XCTAssertNotNil(sleepTime, "\(String(describing: sleepTimeItem?.answerFormat))")
        let sleepHour = sleepTime?.defaultComponents?.hour
        XCTAssertNotNil(sleepHour)
        XCTAssertEqual(sleepHour!, 10)
        
        let chocolateItem = step.formItem(for:"chocolate")
        let chocolate = chocolateItem?.answerFormat as? ORKBooleanAnswerFormat
        XCTAssertNotNil(chocolateItem)
        XCTAssertNotNil(chocolate, "\(String(describing: chocolateItem?.answerFormat))")
        XCTAssertEqual(chocolateItem?.text, "Do you like chocolate?")
    }
    
    func testProfileForm_DefaultRegistration() {
        let input: NSDictionary = [
            "identifier"    : "registration",
            "type"          : "registration",
            "title"         : "Registration",
        ]
        
        let step = SBAProfileFormStep(inputItem: input)
        XCTAssertEqual(step.identifier, "registration")
        XCTAssertEqual(step.title, "Registration")
        
        let emailItem = step.formItem(for:"email")
        let email = emailItem?.answerFormat as? ORKEmailAnswerFormat
        XCTAssertNotNil(emailItem)
        XCTAssertNotNil(email, "\(String(describing: emailItem?.answerFormat))")
        
        let passwordItem = step.formItem(for:"password")
        let password = passwordItem?.answerFormat as? ORKTextAnswerFormat
        XCTAssertNotNil(passwordItem)
        XCTAssertNotNil(password, "\(String(describing: passwordItem?.answerFormat))")
        
        guard let passwordFormat = password else {
            return
        }
        
        XCTAssertEqual(passwordFormat.validationRegex, "[[:ascii:]]{4,24}")
        XCTAssertEqual(passwordFormat.invalidMessage, "Passwords must be between 4 and 24 characters long.")
        XCTAssertEqual(passwordFormat.maximumLength, 24)
        XCTAssertFalse(passwordFormat.multipleLines)
        XCTAssertEqual(passwordFormat.autocapitalizationType, UITextAutocapitalizationType.none)
        XCTAssertEqual(passwordFormat.autocorrectionType, UITextAutocorrectionType.no)
        XCTAssertEqual(passwordFormat.spellCheckingType, UITextSpellCheckingType.no)
        XCTAssertEqual(passwordFormat.keyboardType, UIKeyboardType.default)
        XCTAssertTrue(passwordFormat.isSecureTextEntry)
        
        let confirmationItem = step.formItem(for:"passwordConfirmation")
        let confirmation = confirmationItem?.answerFormat as? ORKTextAnswerFormat
        XCTAssertNotNil(confirmationItem)
        XCTAssertNotNil(confirmation, "\(String(describing: confirmationItem?.answerFormat))")
        
        guard let confirmationFormat = confirmation else {
            return
        }
        
        XCTAssertEqual(confirmationFormat.maximumLength, 24)
        XCTAssertFalse(confirmationFormat.multipleLines)
        XCTAssertEqual(confirmationFormat.autocapitalizationType, UITextAutocapitalizationType.none)
        XCTAssertEqual(confirmationFormat.autocorrectionType, UITextAutocorrectionType.no)
        XCTAssertEqual(confirmationFormat.spellCheckingType, UITextSpellCheckingType.no)
        XCTAssertEqual(confirmationFormat.keyboardType, UIKeyboardType.default)
        XCTAssertTrue(confirmationFormat.isSecureTextEntry)

    }
    
    func testProfileForm_RegistrationWithMinMax() {
        let input: NSDictionary = [
            "identifier"    : "registration",
            "type"          : "registration",
            "title"         : "Registration",
            "items"         : ["email",
                               ["identifier" : "password",
                                "minimumLength" : 4,
                                "maximumLength" : 16,
                                "shouldConfirm" : false
                ]]]
        
        let step = SBAProfileFormStep(inputItem: input)
        XCTAssertEqual(step.identifier, "registration")
        XCTAssertEqual(step.title, "Registration")
        
        let emailItem = step.formItem(for:"email")
        let email = emailItem?.answerFormat as? ORKEmailAnswerFormat
        XCTAssertNotNil(emailItem)
        XCTAssertNotNil(email, "\(String(describing: emailItem?.answerFormat))")
        
        let passwordItem = step.formItem(for:"password")
        let password = passwordItem?.answerFormat as? ORKTextAnswerFormat
        XCTAssertNotNil(passwordItem)
        XCTAssertNotNil(password, "\(String(describing: passwordItem?.answerFormat))")
        
        guard let passwordFormat = password else {
            return
        }
        
        XCTAssertEqual(passwordFormat.validationRegex, "[[:ascii:]]{4,16}")
        XCTAssertEqual(passwordFormat.invalidMessage, "Passwords must be between 4 and 16 characters long.")
        XCTAssertEqual(passwordFormat.maximumLength, 16)
        XCTAssertFalse(passwordFormat.multipleLines)
        XCTAssertEqual(passwordFormat.autocapitalizationType, UITextAutocapitalizationType.none)
        XCTAssertEqual(passwordFormat.autocorrectionType, UITextAutocorrectionType.no)
        XCTAssertEqual(passwordFormat.spellCheckingType, UITextSpellCheckingType.no)
        XCTAssertEqual(passwordFormat.keyboardType, UIKeyboardType.default)
        XCTAssertTrue(passwordFormat.isSecureTextEntry)
        
        let confirmationItem = step.formItem(for:"passwordConfirmation")
        XCTAssertNil(confirmationItem)
    }
    
    func testProfileForm_RegistrationWithRegex() {
        let input: NSDictionary = [
            "identifier"    : "registration",
            "type"          : "registration",
            "title"         : "Registration",
            "items"         : ["email",
                               ["identifier" : "password",
                                "validationRegex" : "abc",
                                "invalidMessage" : "ABC 123",
                                "shouldConfirm" : false
                ]]]
        
        let step = SBAProfileFormStep(inputItem: input)
        XCTAssertEqual(step.identifier, "registration")
        XCTAssertEqual(step.title, "Registration")
        
        let emailItem = step.formItem(for:"email")
        let email = emailItem?.answerFormat as? ORKEmailAnswerFormat
        XCTAssertNotNil(emailItem)
        XCTAssertNotNil(email, "\(String(describing: emailItem?.answerFormat))")
        
        let passwordItem = step.formItem(for:"password")
        let password = passwordItem?.answerFormat as? ORKTextAnswerFormat
        XCTAssertNotNil(passwordItem)
        XCTAssertNotNil(password, "\(String(describing: passwordItem?.answerFormat))")
        
        guard let passwordFormat = password else {
            return
        }
        
        XCTAssertEqual(passwordFormat.validationRegex, "abc")
        XCTAssertEqual(passwordFormat.invalidMessage, "ABC 123")
        XCTAssertEqual(passwordFormat.maximumLength, 24)
        XCTAssertFalse(passwordFormat.multipleLines)
        XCTAssertEqual(passwordFormat.autocapitalizationType, UITextAutocapitalizationType.none)
        XCTAssertEqual(passwordFormat.autocorrectionType, UITextAutocorrectionType.no)
        XCTAssertEqual(passwordFormat.spellCheckingType, UITextSpellCheckingType.no)
        XCTAssertEqual(passwordFormat.keyboardType, UIKeyboardType.default)
        XCTAssertTrue(passwordFormat.isSecureTextEntry)
        
        let confirmationItem = step.formItem(for:"passwordConfirmation")
        XCTAssertNil(confirmationItem)
    }
    
    func testProfileForm_DefaultLogin() {
        let input: NSDictionary = [
            "identifier"    : "login",
            "type"          : "login",
            "title"         : "Login",
            ]
        
        let step = SBAProfileFormStep(inputItem: input)
        XCTAssertEqual(step.identifier, "login")
        XCTAssertEqual(step.title, "Login")
        
        let emailItem = step.formItem(for:"email")
        let email = emailItem?.answerFormat as? ORKEmailAnswerFormat
        XCTAssertNotNil(emailItem)
        XCTAssertNotNil(email, "\(String(describing: emailItem?.answerFormat))")
        
        let passwordItem = step.formItem(for:"password")
        let password = passwordItem?.answerFormat as? ORKTextAnswerFormat
        XCTAssertNotNil(passwordItem)
        XCTAssertNotNil(password, "\(String(describing: passwordItem?.answerFormat))")
        
        guard let passwordFormat = password else {
            return
        }
        
        XCTAssertNil(passwordFormat.validationRegex)
        XCTAssertNil(passwordFormat.invalidMessage)
        XCTAssertEqual(passwordFormat.maximumLength, 0)
        XCTAssertFalse(passwordFormat.multipleLines)
        XCTAssertEqual(passwordFormat.autocapitalizationType, UITextAutocapitalizationType.none)
        XCTAssertEqual(passwordFormat.autocorrectionType, UITextAutocorrectionType.no)
        XCTAssertEqual(passwordFormat.spellCheckingType, UITextSpellCheckingType.no)
        XCTAssertEqual(passwordFormat.keyboardType, UIKeyboardType.default)
        XCTAssertTrue(passwordFormat.isSecureTextEntry)
        
        let confirmationItem = step.formItem(for:"passwordConfirmation")
        XCTAssertNil(confirmationItem)
    }
    
    func testGivenFamilyNameStep() {
        let input: NSDictionary = [
            "identifier"    : "profile",
            "type"          : "profile",
            "title"         : "Profile",
            "items"         : ["given", "family"]
        ]
        
        let step = SBAProfileFormStep(inputItem: input)
        XCTAssertEqual(step.identifier, "profile")
        XCTAssertEqual(step.title, "Profile")
        
        let givenNameItem = step.formItem(for:"given")
        let givenName = givenNameItem?.answerFormat as? ORKTextAnswerFormat
        XCTAssertNotNil(givenNameItem)
        XCTAssertNotNil(givenName, "\(String(describing: givenNameItem?.answerFormat))")
        
        let familyNameItem = step.formItem(for:"family")
        let familyName = familyNameItem?.answerFormat as? ORKTextAnswerFormat
        XCTAssertNotNil(familyNameItem)
        XCTAssertNotNil(familyName, "\(String(describing: familyNameItem?.answerFormat))")
    }
    
    func testCurrentAgeStep() {
        let input: NSDictionary = [
            "identifier"    : "profile",
            "type"          : "profile",
            "title"         : "Profile",
            "items"         : ["currentAge"]
        ]
        
        let step = SBAProfileFormStep(inputItem: input)
        XCTAssertEqual(step.identifier, "profile")
        XCTAssertEqual(step.title, "Profile")
        
        let currentAgeItem = step.formItem(for:"currentAge")
        let currentAge = currentAgeItem?.answerFormat as? ORKNumericAnswerFormat
        XCTAssertNotNil(currentAgeItem)
        XCTAssertNotNil(currentAge, "\(String(describing: currentAgeItem?.answerFormat))")
    }
}
