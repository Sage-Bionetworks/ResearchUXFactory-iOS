//
//  ResearchKitResultConverterTests.swift
//  ResearchUXFactory
//
//  Copyright (c) 2017 Sage Bionetworks. All rights reserved.
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
import HealthKit

class MockResultConverter: NSObject, SBAResearchKitResultConverter {
    
    var answerFormatFinder: SBAAnswerFormatFinder?
    var results: [ORKResult] = []
    
    func findResult(for identifier: String) -> ORKResult? {
        return results.sba_find(withIdentifier: identifier)
    }
}

class ResearchKitResultConverterTests: XCTestCase {
    
    func testTextAnswer() {
        
        let converter = MockResultConverter()
        let resultA = ORKTextQuestionResult(identifier: "A")
        resultA.textAnswer = "answer A"
        let resultB = ORKTextQuestionResult(identifier: "B")
        resultB.textAnswer = "answer B"
        let resultC = ORKTextQuestionResult(identifier: "C")
        let resultD = ORKNumericQuestionResult(identifier: "D")
        resultD.numericAnswer = 5
        
        converter.results = [resultA, resultB, resultC, resultD]
        XCTAssertEqual(converter.textAnswer(for: "A"), "answer A")
        XCTAssertNil(converter.textAnswer(for: "D"))
    }
    
    func textIntAnswer() {
        let converter = MockResultConverter()
        let resultA = ORKTextQuestionResult(identifier: "A")
        resultA.textAnswer = "answer A"
        let resultB = ORKTextQuestionResult(identifier: "B")
        resultB.textAnswer = "answer B"
        let resultC = ORKNumericQuestionResult(identifier: "C")
        let resultD = ORKNumericQuestionResult(identifier: "D")
        resultD.numericAnswer = 5
        
        converter.results = [resultA, resultB, resultC, resultD]
        XCTAssertNil(converter.intAnswer(for: "A"))
        XCTAssertEqual(converter.intAnswer(for: "D"), 5)
    }
    
    func testTimeOfDay() {
        let converter = MockResultConverter()
        let resultA = ORKTextQuestionResult(identifier: "A")
        resultA.textAnswer = "answer A"
        let resultB = ORKTextQuestionResult(identifier: "B")
        resultB.textAnswer = "answer B"
        let resultC = ORKTimeOfDayQuestionResult(identifier: "C")
        let resultD = ORKTimeOfDayQuestionResult(identifier: "D")
        
        var timeOfDay = DateComponents()
        timeOfDay.hour = 6
        timeOfDay.minute = 20
        resultD.dateComponentsAnswer = timeOfDay
        
        converter.results = [resultA, resultB, resultC, resultD]
        XCTAssertNil(converter.timeOfDay(for: "A"))
        XCTAssertEqual(converter.timeOfDay(for: "D"), timeOfDay)
    }
    
    func testProfileResults() {
        
        // NOTE: If this test fails, check that AccountTests.testCreateProfileFormStep() is passing
        // b/c for convenience, I am using the same methods to create the step
        let profileKeys = ["externalID", "name", "birthdate", "gender", "bloodType", "fitzpatrickSkinType", "wheelchairUse", "height", "weight", "wakeTime", "sleepTime"]
        let input: NSDictionary = [
            "identifier"    : "profile",
            "type"          : "profile",
            "title"         : "Profile",
            "items"         : profileKeys
        ]
        
        let step = SBAProfileFormStep(inputItem: input)
        
        let converter = MockResultConverter()
        converter.answerFormatFinder = step
        
        let birthdate = Date(timeIntervalSince1970: 2*12*365*24 + 3*30) // Not really important to use a calendar date
        var wakeTime = DateComponents()
        wakeTime.hour = 8
        var sleepTime = DateComponents()
        sleepTime.hour = 22
        
        let stepResult = step.instantiateDefaultStepResult(["externalID" : "1234ABCD",
                                                            "name" : "Joe Smith",
                                                            "birthdate" : birthdate,
                                                            "gender" : ["HKBiologicalSexFemale"],
                                                            "bloodType" : ["HKBloodTypeBNegative"],
                                                            "wheelchairUse" : [true],
                                                            "height" : 158,
                                                            "weight" : "120 lb",
                                                            "wakeTime" : wakeTime,
                                                            "sleepTime" : sleepTime])
        converter.results = stepResult.results!
        
        // -- Test that the Profile Info properties are correct
        
        XCTAssertEqual(converter.externalID, "1234ABCD")
        XCTAssertEqual(converter.birthdate, birthdate)
        XCTAssertEqual(converter.name, "Joe Smith")
        XCTAssertEqual(converter.gender, HKBiologicalSex.female)
        XCTAssertEqual(converter.bloodType, HKBloodType.bNegative)
        XCTAssertEqual(converter.wheelchairUse, true)
        XCTAssertEqual(converter.wakeTime, wakeTime)
        XCTAssertEqual(converter.sleepTime, sleepTime)
        
        let expectedHeight = HKQuantity(unit: HKUnit.meterUnit(with: .centi), doubleValue: 158)
        XCTAssertEqual(converter.height, expectedHeight)
        
        let expectedWeight = HKQuantity(unit: HKUnit.pound(), doubleValue: 120)
        XCTAssertEqual(converter.weight, expectedWeight)
        
        // -- Check that the stored result returns the same values 
        
        let storedGender = converter.storedAnswer(for: "gender") as? HKBiologicalSex
        XCTAssertEqual(storedGender, HKBiologicalSex.female)
        
        let storedBloodType = converter.storedAnswer(for: "bloodType") as? HKBloodType
        XCTAssertEqual(storedBloodType, HKBloodType.bNegative)
        
        let storedWheelchairUse = converter.storedAnswer(for: "wheelchairUse") as? Bool
        XCTAssertEqual(storedWheelchairUse, true)
        
        let storedHeight = converter.storedAnswer(for: "height") as? HKQuantity
        XCTAssertEqual(storedHeight, expectedHeight)
        
        let storedWeight = converter.storedAnswer(for: "weight") as? HKQuantity
        XCTAssertEqual(storedWeight, expectedWeight)
        
        let storedWakeTime = converter.storedAnswer(for: "wakeTime") as? DateComponents
        XCTAssertEqual(storedWakeTime, wakeTime)
        
        let storedSleepTime = converter.storedAnswer(for: "sleepTime") as? DateComponents
        XCTAssertEqual(storedSleepTime, sleepTime)
        
        // -- Test that a participant is updated properly
        
        let participant = MockParticipantInfo()
        converter.update(participantInfo: participant, with: profileKeys)
        
        XCTAssertEqual(participant.storedAnswers["externalID"] as? String, "1234ABCD")
        XCTAssertEqual(participant.birthdate, birthdate)
        XCTAssertEqual(participant.name, "Joe Smith")
        XCTAssertEqual(participant.storedAnswers["gender"] as? HKBiologicalSex, HKBiologicalSex.female)
        XCTAssertEqual(participant.storedAnswers["bloodType"] as? HKBloodType, HKBloodType.bNegative)
        XCTAssertEqual(participant.storedAnswers["wheelchairUse"] as? Bool, true)
        XCTAssertEqual(participant.storedAnswers["wakeTime"] as? DateComponents , wakeTime)
        XCTAssertEqual(participant.storedAnswers["sleepTime"] as? DateComponents, sleepTime)
        
        
    }
    
    func testProfileResults_GivenFamily_CurrentAge() {
        
        // NOTE: If this test fails, check that AccountTests.testCreateProfileFormStep() is passing
        // b/c for convenience, I am using the same methods to create the step
        let profileKeys = ["given", "family", "currentAge"]
        let input: NSDictionary = [
            "identifier"    : "profile",
            "type"          : "profile",
            "title"         : "Profile",
            "items"         : profileKeys
        ]
        
        let step = SBAProfileFormStep(inputItem: input)
        
        let converter = MockResultConverter()
        converter.answerFormatFinder = step
        
        let stepResult = step.instantiateDefaultStepResult(["given" : "Joe",
                                                            "family" : "Smith",
                                                            "currentAge" : 20])
        converter.results = stepResult.results!
        
        // -- Test that the Profile Info properties are correct
        XCTAssertEqual(converter.fullName, "Joe Smith")
        XCTAssertEqual(converter.givenName, "Joe")
        XCTAssertEqual(converter.familyName, "Smith")
        XCTAssertEqual(converter.name, "Joe")
        
        // -- Test that a participant is updated properly
        
        let participant = MockParticipantInfo()
        converter.update(participantInfo: participant, with: profileKeys)
        
        let expectedBirthday = Date().addingNumberOfYears(-20).dateOnly()
        XCTAssertEqual(participant.birthdate?.dateOnly(), expectedBirthday)
        XCTAssertEqual(participant.name, "Joe")
        XCTAssertEqual(participant.familyName, "Smith")
    }
}
