//
//  SBABaseSurveyFactoryTests.swift
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

import XCTest
import ResearchUXFactory
import ResearchKit

class SBABaseSurveyFactoryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // -------------------------------------------------
    // MARK: NSDictionary
    // -------------------------------------------------
    
    func testCustomType() {
        let inputStep: NSDictionary = [
            "identifier"    : "customStep",
            "type"          : "customStepType",
            "title"         : "Title",
            "text"          : "Text for this step",
        ]
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? SBAInstructionStep else {
            XCTAssert(false, "\(step) is not of expected class type")
            return
        }
        XCTAssertEqual(surveyStep.identifier, "customStep")
        XCTAssertEqual(surveyStep.customTypeIdentifier, "customStepType")
        XCTAssertEqual(surveyStep.title, "Title")
        XCTAssertEqual(surveyStep.text, "Text for this step")
    }
    
    func testFactory_CompoundSurveyQuestion_WithRule() {
        
        let inputStep: NSDictionary = [
            "identifier" : "quiz",
            "type" : "compound",
            "items" : [
                [   "identifier" : "question1",
                    "type" : "boolean",
                    "prompt" : "Are you older than 18?",
                    "expectedAnswer" : true],
                [   "identifier" : "question2",
                    "type" : "boolean",
                    "prompt" : "Are you a US resident?",
                    "expectedAnswer" : true],
                [   "identifier" : "question3",
                    "type" : "boolean",
                    "prompt" : "Can you read English?",
                    "expectedAnswer" : true],
            ],
            "skipIdentifier" : "consent",
            "skipIfPassed" : true
        ]
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? SBANavigationFormStep else {
            XCTAssert(false, "\(step) is not of expected class type")
            return
        }
        XCTAssertEqual(surveyStep.identifier, "quiz")
        
        guard let formItems = surveyStep.formItems , formItems.count == 3 else {
            XCTAssert(false, "\(surveyStep.formItems) are not of expected count")
            return
        }
        
        // First try with one "NO" answer
        let taskResultFail = createTaskResult("quiz", results: [createBooleanResult("question1", answer: true),
                                                                createBooleanResult("question2", answer: false),
                                                                createBooleanResult("question3", answer: true)])
        let failedIdentifier = surveyStep.nextStepIdentifier(with: taskResultFail, and: nil)
        XCTAssertNil(failedIdentifier)
        
        // Next try with pass results
        let taskResultSuccess = createTaskResult("quiz", results: [createBooleanResult("question1", answer: true),
                                                                createBooleanResult("question2", answer: true),
                                                                createBooleanResult("question3", answer: true)])
        let passedIdentifier = surveyStep.nextStepIdentifier(with: taskResultSuccess, and: nil)
        XCTAssertEqual(passedIdentifier, "consent")
        
        guard let rules = surveyStep.rules, rules.count == 3 else {
            XCTAssert(false, "\(surveyStep.formItems) are not of expected count")
            return
        }
        
        XCTAssertEqual(rules[0].resultIdentifier, "question1")
        XCTAssertEqual(rules[1].resultIdentifier, "question2")
        XCTAssertEqual(rules[2].resultIdentifier, "question3")
        
        XCTAssertEqual(rules[0].skipIdentifier, "consent")
        XCTAssertEqual(rules[1].skipIdentifier, "consent")
        XCTAssertEqual(rules[2].skipIdentifier, "consent")
        
        XCTAssertTrue(rules[0].rulePredicate.evaluate(with: createBooleanResult("question1", answer: true)))
        XCTAssertTrue(rules[1].rulePredicate.evaluate(with: createBooleanResult("question2", answer: true)))
        XCTAssertTrue(rules[2].rulePredicate.evaluate(with: createBooleanResult("question3", answer: true)))
        
        XCTAssertFalse(rules[0].rulePredicate.evaluate(with: createBooleanResult("question1", answer: false)))
        XCTAssertFalse(rules[1].rulePredicate.evaluate(with: createBooleanResult("question2", answer: false)))
        XCTAssertFalse(rules[2].rulePredicate.evaluate(with: createBooleanResult("question3", answer: false)))
    }
    
    func testFactory_ToggleSurveyQuestion() {
        
        let inputStep: NSDictionary = [
            "identifier" : "quiz",
            "type" : "toggle",
            "items" : [
                [   "identifier" : "question1",
                    "prompt" : "Are you older than 18?",
                    "expectedAnswer" : true],
                [   "identifier" : "question2",
                    "prompt" : "Are you a US resident?",
                    "expectedAnswer" : true],
                [   "identifier" : "question3",
                    "prompt" : "Can you read English?",
                    "expectedAnswer" : true],
            ],
            "skipIdentifier" : "consent",
            "skipIfPassed" : false
        ]
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? SBAToggleFormStep else {
            XCTAssert(false, "\(step) is not of expected class type")
            return
        }
        XCTAssertEqual(surveyStep.identifier, "quiz")
        
        guard let formItems = surveyStep.formItems, formItems.count == 3 else {
            XCTAssert(false, "\(surveyStep.formItems) are not of expected count")
            return
        }
        
        XCTAssertEqual(formItems[0].identifier, "question1")
        XCTAssertEqual(formItems[1].identifier, "question2")
        XCTAssertEqual(formItems[2].identifier, "question3")
        
        XCTAssertEqual(formItems[0].text, "Are you older than 18?")
        XCTAssertEqual(formItems[1].text, "Are you a US resident?")
        XCTAssertEqual(formItems[2].text, "Can you read English?")
        
        XCTAssertNotNil(formItems[0].answerFormat as? ORKBooleanAnswerFormat)
        XCTAssertNotNil(formItems[1].answerFormat as? ORKBooleanAnswerFormat)
        XCTAssertNotNil(formItems[2].answerFormat as? ORKBooleanAnswerFormat)
        
        // First try with one "NO" answer
        let taskResultFail = createTaskResult("quiz", results: [createBooleanResult("question1", answer: true),
                                                                createBooleanResult("question2", answer: false),
                                                                createBooleanResult("question3", answer: true)])
        let failedIdentifier = surveyStep.nextStepIdentifier(with: taskResultFail, and: nil)
        XCTAssertEqual(failedIdentifier, "consent")
        
        // First try with one "NO" answer
        let taskResultAllFail = createTaskResult("quiz", results: [createBooleanResult("question1", answer: false),
                                                                createBooleanResult("question2", answer: false),
                                                                createBooleanResult("question3", answer: false)])
        let allFailedIdentifier = surveyStep.nextStepIdentifier(with: taskResultAllFail, and: nil)
        XCTAssertEqual(allFailedIdentifier, "consent")
        
        // Next try with pass results
        let taskResultSuccess = createTaskResult("quiz", results: [createBooleanResult("question1", answer: true),
                                                                   createBooleanResult("question2", answer: true),
                                                                   createBooleanResult("question3", answer: true)])
        let passedIdentifier = surveyStep.nextStepIdentifier(with: taskResultSuccess, and: nil)
        XCTAssertNil(passedIdentifier)
        
        guard let rules = surveyStep.rules, rules.count == 3 else {
            XCTAssert(false, "\(surveyStep.formItems) are not of expected count")
            return
        }
        
        XCTAssertEqual(rules[0].resultIdentifier, "question1")
        XCTAssertEqual(rules[1].resultIdentifier, "question2")
        XCTAssertEqual(rules[2].resultIdentifier, "question3")
        
        XCTAssertEqual(rules[0].skipIdentifier, "consent")
        XCTAssertEqual(rules[1].skipIdentifier, "consent")
        XCTAssertEqual(rules[2].skipIdentifier, "consent")
        
        XCTAssertTrue(rules[0].rulePredicate.evaluate(with: createBooleanResult("question1", answer: true)))
        XCTAssertTrue(rules[1].rulePredicate.evaluate(with: createBooleanResult("question2", answer: true)))
        XCTAssertTrue(rules[2].rulePredicate.evaluate(with: createBooleanResult("question3", answer: true)))
        
        XCTAssertFalse(rules[0].rulePredicate.evaluate(with: createBooleanResult("question1", answer: false)))
        XCTAssertFalse(rules[1].rulePredicate.evaluate(with: createBooleanResult("question2", answer: false)))
        XCTAssertFalse(rules[2].rulePredicate.evaluate(with: createBooleanResult("question3", answer: false)))
    }
    
    func testFactory_CompoundSurveyQuestion_NoRule() {
        
        let inputStep: NSDictionary = [
            "identifier" : "quiz",
            "type" : "compound",
            "items" : [
                [   "identifier" : "question1",
                    "type" : "boolean",
                    "prompt" : "Are you older than 18?"],
                [   "identifier" : "question2",
                    "type" : "boolean",
                    "text" : "Are you a US resident?"],
                [   "identifier" : "question3",
                    "type" : "boolean",
                    "prompt" : "Can you read English?"],
            ],
        ]
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? ORKFormStep else {
            XCTAssert(false, "\(step) is not of expected class type")
            return
        }
        
        XCTAssertEqual(surveyStep.identifier, "quiz")
        XCTAssertEqual(surveyStep.formItems?.count, 3)
        
        guard let formItems = surveyStep.formItems , formItems.count == 3 else { return }
        
        XCTAssertEqual(formItems[0].text, "Are you older than 18?")
        XCTAssertEqual(formItems[1].text, "Are you a US resident?")
        XCTAssertEqual(formItems[2].text, "Can you read English?")
        
    }
    
    func testFactory_SubtaskSurveyQuestion_WithRule() {
        
        let inputStep: NSDictionary = [
            "identifier" : "quiz",
            "type" : "subtask",
            "items" : [
                [   "identifier" : "question1",
                    "type" : "boolean",
                    "prompt" : "I can share my data broadly or only with Sage?",
                    "expectedAnswer" : true],
                [   "identifier" : "question2",
                    "type" : "boolean",
                    "prompt" : "My name is stored with my results?",
                    "expectedAnswer" : false],
                [   "identifier" : "question3",
                    "type" : "boolean",
                    "prompt" : "I can leave the study at any time?",
                    "expectedAnswer" : true],
            ],
            "skipIdentifier" : "consent",
            "skipIfPassed" : true
        ]
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? SBANavigationSubtaskStep else {
            XCTAssert(false, "\(step) is not of expected class type")
            return
        }
        
        XCTAssertEqual(surveyStep.identifier, "quiz")
        
        guard let subtask = surveyStep.subtask as? ORKOrderedTask else {
            XCTAssert(false, "\(surveyStep.subtask) is not of expected class")
            return
        }
        XCTAssertEqual(subtask.steps.count, 3)
        
        // First try with one "NO" answer
        let taskResultFail = createTaskResult("quiz", results: [createBooleanResult("question1", answer: true),
                                                                createBooleanResult("question2", answer: true),
                                                                createBooleanResult("question3", answer: true)],
                                              isSubtask:true)
        let failedIdentifier = surveyStep.nextStepIdentifier(with: taskResultFail, and: nil)
        XCTAssertNil(failedIdentifier)
        
        // Next try with pass results
        let taskResultSuccess = createTaskResult("quiz", results: [createBooleanResult("question1", answer: true),
                                                                   createBooleanResult("question2", answer: false),
                                                                   createBooleanResult("question3", answer: true)],
                                                 isSubtask:true)
        let passedIdentifier = surveyStep.nextStepIdentifier(with: taskResultSuccess, and: nil)
        XCTAssertEqual(passedIdentifier, "consent")
    }
    
    func testFactory_DirectNavigationRule() {
        
        let inputStep: NSDictionary = [
            "identifier" : "ineligible",
            "prompt" : "You can't get there from here",
            "detailText": "Tap the button below to begin the consent process",
            "type"  : "instruction",
            "nextIdentifier" : "exit"
        ]
        
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? SBAInstructionStep else {
            XCTAssert(false, "\(step) is not of expected class type")
            return
        }
        
        XCTAssertEqual(surveyStep.identifier, "ineligible")
        XCTAssertEqual(surveyStep.text, "You can't get there from here")
        XCTAssertEqual(surveyStep.detailText, "Tap the button below to begin the consent process")
        XCTAssertEqual(surveyStep.nextStepIdentifier, "exit")
    }
    
    func testFactory_CompletionStep() {
        
        let inputStep: NSDictionary = [
            "identifier" : "quizComplete",
            "title" : "Great Job!",
            "text" : "You answered correctly",
            "detailText": "Tap the button below to begin the consent process",
            "type"  : "completion",
        ]
        
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? ORKInstructionStep else {
            XCTAssert(false, "\(step) is not of expected class type")
            return
        }
        
        XCTAssertEqual(surveyStep.identifier, "quizComplete")
        XCTAssertEqual(surveyStep.title, "Great Job!")
        XCTAssertEqual(surveyStep.text, "You answered correctly")
        XCTAssertEqual(surveyStep.detailText, "Tap the button below to begin the consent process")
    }
    
    func testFactory_BooleanQuestion() {
        
        let inputStep: NSDictionary = [
            "identifier" : "question1",
            "type" : "boolean",
            "prompt" : "Are you older than 18?",
            "expectedAnswer" : true
        ]
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? SBANavigationFormStep else {
            XCTAssert(false, "\(step) is not of expected class type")
            return
        }
        
        XCTAssertEqual(surveyStep.identifier, "question1")
        XCTAssertEqual(surveyStep.formItems?.count, 1)
        
        guard let formItem = surveyStep.formItems?.first,
            let _ = formItem.answerFormat as? ORKBooleanAnswerFormat else {
                XCTAssert(false, "\(surveyStep.formItems) is not of expected class type")
                return
        }
        
        XCTAssertNil(formItem.text)
        XCTAssertEqual(surveyStep.text, "Are you older than 18?")
        
        guard let rules = surveyStep.rules, rules.count == 1, let rule = rules.first else {
            XCTAssert(false, "\(step) is missing a rule")
            return
        }
        
        XCTAssertEqual(rule.resultIdentifier, "question1")
        XCTAssertEqual(rule.skipIdentifier, ORKNullStepIdentifier)
        
        let questionResult = ORKBooleanQuestionResult(identifier:formItem.identifier)
        questionResult.booleanAnswer = true
        XCTAssertTrue(rule.rulePredicate.evaluate(with: questionResult), "\(rule.rulePredicate)")
        
        questionResult.booleanAnswer = false
        XCTAssertFalse(rule.rulePredicate.evaluate(with: questionResult), "\(rule.rulePredicate)")
    }
    
    func testFactory_SingleChoiceQuestion() {
        let inputStep: NSDictionary = [
            "identifier" : "question1",
            "type" : "singleChoiceText",
            "prompt" : "Question 1?",
            "items" : ["a", "b", "c"],
            "expectedAnswer" : "b"
        ]
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? SBANavigationFormStep else {
            XCTAssert(false, "\(step) is not of expected class type")
            return
        }
        
        XCTAssertEqual(surveyStep.identifier, "question1")
        XCTAssertEqual(surveyStep.formItems?.count, 1)
        
        guard let formItem = surveyStep.formItems?.first,
            let answerFormat = formItem.answerFormat as? ORKTextChoiceAnswerFormat else {
                XCTAssert(false, "\(surveyStep.formItems) is not of expected class type")
                return
        }
        
        XCTAssertNil(formItem.text)
        XCTAssertEqual(surveyStep.text, "Question 1?")
        XCTAssertEqual(answerFormat.style, ORKChoiceAnswerStyle.singleChoice)
        XCTAssertEqual(answerFormat.textChoices.count, 3)
        
        XCTAssertEqual(answerFormat.textChoices.first!.text, "a")
        let firstValue = answerFormat.textChoices.first!.value as? String
        XCTAssertEqual(firstValue, "a")
        
        guard let rules = surveyStep.rules, rules.count == 1, let rule = rules.first else {
            XCTAssert(false, "\(step) is missing a rule")
            return
        }
        
        XCTAssertEqual(rule.resultIdentifier, "question1")
        XCTAssertEqual(rule.skipIdentifier, ORKNullStepIdentifier)
        
        let questionResult = ORKChoiceQuestionResult(identifier:formItem.identifier)
        questionResult.choiceAnswers = ["b"]
        XCTAssertTrue(rule.rulePredicate.evaluate(with: questionResult), "\(rule.rulePredicate)")
        
        questionResult.choiceAnswers = ["c"]
        XCTAssertFalse(rule.rulePredicate.evaluate(with: questionResult), "\(rule.rulePredicate)")
    }
    
    
    func testFactory_MultipleChoiceQuestion() {
        let inputStep: NSDictionary = [
            "identifier" : "question1",
            "type" : "multipleChoiceText",
            "prompt" : "Question 1?",
            "items" : [
                ["prompt" : "a", "value" : 0],
                ["prompt" : "b", "value" : 1, "detailText": "good"],
                ["prompt" : "c", "value" : 2, "exclusive": true]],
        ]
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? ORKFormStep else {
            XCTAssert(false, "\(step) is not of expected class type")
            return
        }
        
        XCTAssertEqual(surveyStep.identifier, "question1")
        XCTAssertEqual(surveyStep.formItems?.count, 1)
        
        guard let formItem = surveyStep.formItems?.first,
            let answerFormat = formItem.answerFormat as? ORKTextChoiceAnswerFormat else {
                XCTAssert(false, "\(surveyStep.formItems) is not of expected class type")
                return
        }
        
        XCTAssertNil(formItem.text)
        XCTAssertEqual(surveyStep.text, "Question 1?")
        XCTAssertEqual(answerFormat.style, ORKChoiceAnswerStyle.multipleChoice)
        XCTAssertEqual(answerFormat.textChoices.count, 3)
        
        let choiceA = answerFormat.textChoices[0]
        XCTAssertEqual(choiceA.text, "a")
        XCTAssertEqual(choiceA.value as? Int, 0)
        XCTAssertFalse(choiceA.exclusive)
        
        let choiceB = answerFormat.textChoices[1]
        XCTAssertEqual(choiceB.text, "b")
        XCTAssertEqual(choiceB.value as? Int, 1)
        XCTAssertEqual(choiceB.detailText, "good")
        XCTAssertFalse(choiceB.exclusive)
        
        let choiceC = answerFormat.textChoices[2]
        XCTAssertEqual(choiceC.text, "c")
        XCTAssertEqual(choiceC.value as? Int, 2)
        XCTAssertTrue(choiceC.exclusive)
    }
    
    func testFactory_TextChoice() {
        
        let inputStep: NSDictionary = [
            "identifier": "purpose",
            "title": "What is the purpose of this study?",
            "type": "singleChoiceText",
            "items":[
                ["text" :"Understand the fluctuations of Parkinson disease symptoms", "value" : true],
                ["text" :"Treating Parkinson disease", "value": false],
            ],
            "expectedAnswer": true,
        ]
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? SBANavigationFormStep else {
            XCTAssert(false, "\(step) is not of expected class type")
            return
        }
        
        XCTAssertEqual(surveyStep.identifier, "purpose")
        XCTAssertEqual(surveyStep.formItems?.count, 1)
        
        guard let formItem = surveyStep.formItems?.first,
            let answerFormat = formItem.answerFormat as? ORKTextChoiceAnswerFormat else {
                XCTAssert(false, "\(surveyStep.formItems) is not of expected class type")
                return
        }
        
        XCTAssertNil(formItem.text)
        
        XCTAssertEqual(answerFormat.style, ORKChoiceAnswerStyle.singleChoice)
        XCTAssertEqual(answerFormat.textChoices.count, 2)
        if (answerFormat.textChoices.count != 2) {
            return
        }
        
        XCTAssertEqual(answerFormat.textChoices.first!.text, "Understand the fluctuations of Parkinson disease symptoms")
        let firstValue = answerFormat.textChoices.first!.value as? Bool
        XCTAssertEqual(firstValue, true)
        
        XCTAssertEqual(answerFormat.textChoices.last!.text, "Treating Parkinson disease")
        let lastValue = answerFormat.textChoices.last!.value as? Bool
        XCTAssertEqual(lastValue, false)
        
        guard let rules = surveyStep.rules, rules.count == 1, let rule = rules.first else {
            XCTAssert(false, "\(step) is missing a rule")
            return
        }
        
        XCTAssertEqual(rule.resultIdentifier, "purpose")
        XCTAssertEqual(rule.skipIdentifier, ORKNullStepIdentifier)
        
        let questionResult = ORKChoiceQuestionResult(identifier:formItem.identifier)
        questionResult.choiceAnswers = [true]
        XCTAssertTrue(rule.rulePredicate.evaluate(with: questionResult), "\(rule.rulePredicate)")
        
        questionResult.choiceAnswers = [false]
        XCTAssertFalse(rule.rulePredicate.evaluate(with: questionResult), "\(rule.rulePredicate)")
        
    }
    
    func testFactory_RegistrationStep() {
        let input: NSDictionary = [
            "identifier"    : "registration",
            "type"          : "registration",
            "title"         : "Registration"
        ]
        
        let result = SBABaseSurveyFactory().createSurveyStepWithDictionary(input)
        
        XCTAssertNotNil(result)
        guard let step = result as? ORKRegistrationStep else {
            XCTAssert(false, "\(result) not of expected type.")
            return
        }
        
        XCTAssertEqual(step.identifier, "registration")
        XCTAssertEqual(step.title, "Registration")
    }
    
    
    // MARK: Helper methods
    
    func createBooleanResult(_ stepIdentifier: String, answer: Bool?) -> ORKResult {
        let questionResult = ORKBooleanQuestionResult(identifier:stepIdentifier)
        if let booleanAnswer = answer {
            questionResult.booleanAnswer = booleanAnswer as NSNumber?
        }
        return questionResult
    }

    func createTaskBooleanResult(_ stepIdentifier: String, answer: Bool?) -> ORKTaskResult {
        let questionResult = createBooleanResult(stepIdentifier, answer: answer)
        return createTaskResult(stepIdentifier, results: [questionResult])
    }
    
    func createTaskChoiceResult(_ stepIdentifier: String, answer: [Any]?) -> ORKTaskResult {
        let questionResult = ORKChoiceQuestionResult(identifier:stepIdentifier)
        questionResult.choiceAnswers = answer
        return createTaskResult(stepIdentifier, results: [questionResult])
    }
    
    func createTaskNumberResult(_ stepIdentifier: String, answer: Int?) -> ORKTaskResult {
        let questionResult = ORKNumericQuestionResult(identifier:stepIdentifier)
        if let numericAnswer = answer {
            questionResult.numericAnswer = numericAnswer as NSNumber?
        }
        return createTaskResult(stepIdentifier, results: [questionResult])
    }
    
    func createTaskResult(_ stepIdentifier: String, results: [ORKResult]?, isSubtask:Bool = false) -> ORKTaskResult {
        var stepResults: [ORKStepResult] = [ORKStepResult(identifier: "introduction")]
        if isSubtask {
            let subResults = results!.map({ (result) -> ORKStepResult in
                return ORKStepResult(stepIdentifier: "\(stepIdentifier).\(result.identifier)", results: [result])
            })
            stepResults.append(contentsOf: subResults)
        } else {
            stepResults.append(ORKStepResult(stepIdentifier: stepIdentifier, results: results))
        }
        let taskResult = ORKTaskResult(identifier: "task")
        taskResult.results = stepResults
        return taskResult
    }
    
}
