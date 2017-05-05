//
//  SBADataGroupsStepTests.swift
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

class SBADataGroupsStepTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFactoryWithDictionary() {
        
        guard let surveyStep = createDataGroupsStep(), let step = surveyStep as? ORKFormStep else {
            XCTAssert(false, "could not create step")
            return
        }
    
        XCTAssertEqual(surveyStep.identifier, "dataGroupSelection")
        XCTAssertEqual(step.title, "Which data groups do you want to be in?")
        XCTAssertEqual(step.text, "Choose one")
        XCTAssertFalse(step.isOptional)
        XCTAssertEqual(step.formItems?.count ?? 0, 1)
        XCTAssertEqual(surveyStep.dataGroups, Set(["groupA", "groupB", "groupC", "groupD", "groupE", "groupF"]))
        
        guard let answerFormat = step.formItems?.first?.answerFormat as? ORKTextChoiceAnswerFormat else {
            XCTAssert(false, "\(String(describing: step.formItems)) is not of expected class type")
            return
        }
    
        XCTAssertEqual(step.formItems!.first!.identifier, "dataGroupSelection")
        XCTAssertEqual(answerFormat.style, ORKChoiceAnswerStyle.multipleChoice)
        XCTAssertEqual(answerFormat.textChoices.count, 6)
        
        let noneChoice = answerFormat.textChoices.last!
        XCTAssertTrue(noneChoice.exclusive)
    }
    
    func testFactoryWithDictionary_SingleChoice() {
        guard let surveyStep = createDataGroupsSetSingle(), let step = surveyStep as? ORKFormStep else {
            XCTAssert(false, "could not create step")
            return
        }
        
        XCTAssertEqual(surveyStep.identifier, "dataGroupSelection")
        XCTAssertEqual(step.title, "Which data groups do you want to be in?")
        XCTAssertEqual(step.text, "Choose one")
        XCTAssertFalse(step.isOptional)
        XCTAssertEqual(step.formItems?.count ?? 0, 1)
        let dataGroups = Set(surveyStep.dataGroups)
        XCTAssertEqual(dataGroups, Set(["groupA", "groupB"]))
        
        guard let answerFormat = step.formItems?.first?.answerFormat as? ORKTextChoiceAnswerFormat else {
            XCTAssert(false, "\(String(describing: step.formItems)) is not of expected class type")
            return
        }
        
        XCTAssertEqual(step.formItems!.first!.identifier, "dataGroupSelection")
        XCTAssertEqual(answerFormat.style, ORKChoiceAnswerStyle.singleChoice)
        XCTAssertEqual(answerFormat.textChoices.count, 6)
    }
    
    // MARK: Union
    
    func testUnion_CurrentNil_NewGroupC() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = createResult(choices: ["groupC"])
        
        let dataGroups = surveyStep.union(previousGroups: nil, stepResult: stepResult)
        let expectedSet = Set(["groupC"])
        XCTAssertEqual(expectedSet, dataGroups)
    }
    
    func testUnion_CurrentNil_NewGroupAandC() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = createResult(choices: ["groupA", "groupC"])
        
        let dataGroups = surveyStep.union(previousGroups: nil, stepResult: stepResult)
        let expectedSet = Set(["groupA", "groupC"])
        XCTAssertEqual(expectedSet, dataGroups)
    }
    
    func testUnion_CurrentNil_NewGroupAandB() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = createResult(choices: ["groupA", ["groupB"]])
        
        let dataGroups = surveyStep.union(previousGroups: nil, stepResult: stepResult)
        let expectedSet = Set(["groupA", "groupB"])
        XCTAssertEqual(expectedSet, dataGroups)
    }
    
    func testUnion_CurrentNil_NewEmpty() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = createResult(choices: [""])
        
        let dataGroups = surveyStep.union(previousGroups: nil, stepResult: stepResult)
        let expectedSet = Set<String>()
        XCTAssertEqual(expectedSet, dataGroups)
    }
    
    func testUnion_CurrentGroupD_NewGroupC() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = createResult(choices: ["groupC"])
        
        let dataGroups = surveyStep.union(previousGroups: ["groupD", "test_user"], stepResult: stepResult)
        let expectedSet = Set(["groupC", "test_user"])
        XCTAssertEqual(expectedSet, dataGroups)
    }
    
    func testUnion_CurrentGroupD_NewGroupAandB() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = createResult(choices: ["groupA", ["groupB"]])
        
        let dataGroups = surveyStep.union(previousGroups: ["groupD", "test_user"], stepResult: stepResult)
        let expectedSet = Set(["groupA", "groupB", "test_user"])
        XCTAssertEqual(expectedSet, dataGroups)
    }
    
    func testUnion_CurrentGroupD_NewEmpty() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = createResult(choices: [""])
        
        let dataGroups = surveyStep.union(previousGroups: ["groupD", "test_user"], stepResult: stepResult)
        let expectedSet = Set(["test_user"])
        XCTAssertEqual(expectedSet, dataGroups)
    }
    
    // MARK: Step result
    
    func testStepResult_Nil() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = surveyStep.stepResult(currentGroups: nil)
        XCTAssertNil(stepResult?.results?.first)
    }
    
    func testStepResult_NotInSet() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = surveyStep.stepResult(currentGroups: ["test_user"])
        XCTAssertNil(stepResult?.results?.first)
    }
    
    func testStepResult_GroupC() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = surveyStep.stepResult(currentGroups: ["test_user", "groupC"])
        guard let questionResult = stepResult?.results?.first as? ORKChoiceQuestionResult,
            let choices = questionResult.choiceAnswers as? [String] else {
            XCTAssert(false, "\(String(describing: stepResult)) does not have expected choiceAnswers")
            return
        }
        
        XCTAssertEqual(["groupC"], choices)
    }
    
    func testStepResult_GroupB() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = surveyStep.stepResult(currentGroups: ["test_user", "groupB"])
        guard let questionResult = stepResult?.results?.first as? ORKChoiceQuestionResult,
            let choices = questionResult.choiceAnswers as NSArray? else {
                XCTAssert(false, "\(String(describing: stepResult)) does not have expected choiceAnswers")
                return
        }
        
        XCTAssertEqual([["groupB"]] as NSArray, choices)
    }
    
    func testStepResult_GroupAandB() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = surveyStep.stepResult(currentGroups: ["test_user", "groupA", "groupB"])
        guard let questionResult = stepResult?.results?.first as? ORKChoiceQuestionResult,
            let choices = questionResult.choiceAnswers as NSArray? else {
                XCTAssert(false, "\(String(describing: stepResult)) does not have expected choiceAnswers")
                return
        }
        
        XCTAssertEqual(["groupA", ["groupB"]] as NSArray, choices)
    }
    
    func testStepResult_GroupEandF() {
        guard let surveyStep = createDataGroupsStep() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = surveyStep.stepResult(currentGroups: ["test_user", "groupE", "groupF"])
        guard let questionResult = stepResult?.results?.first as? ORKChoiceQuestionResult,
            let choices = questionResult.choiceAnswers as NSArray? else {
                XCTAssert(false, "\(String(describing: stepResult)) does not have expected choiceAnswers")
                return
        }
        
        XCTAssertEqual([["groupE", "groupF"]] as NSArray, choices)
    }
    
    func testStepResult_Single_Narrow() {
        
        // For the case where multiple answers can result selecting the same data group, the step result cannot 
        // be created from the exisiting data groups
        guard let surveyStep = createDataGroupsSetSingle() else {
            XCTAssert(false, "could not create step")
            return
        }
        
        let stepResult = surveyStep.stepResult(currentGroups: ["groupA"])
        XCTAssertNil(stepResult)
    }
    
    // MARK: helper methods
    
    func createDataGroupsStep() -> SBADataGroupsStepProtocol? {
        
        let inputStep: NSDictionary = [
            "identifier": "dataGroupSelection",
            "type": "dataGroups",
            "title": "Which data groups do you want to be in?",
            "text": "Choose one",
            "optional" : false,
            "items": [
                [ "text" : "Group A",
                  "value" : "groupA"],
                [ "text" : "Group B",
                  "value" : ["groupB"]],
                [ "text" : "Group C",
                  "value" : "groupC"],
                [ "text" : "Group C and D",
                  "value" : ["groupC", "groupD"]],
                [ "text" : "Group E and F",
                  "value" : ["groupE", "groupF"]],
                [ "text" : "None",
                  "value" : "",
                  "exclusive" : true]]
        ]
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? SBADataGroupsStep else {
            XCTAssert(false, "\(String(describing: step)) is not of expected class type")
            return nil
        }
        
        return surveyStep
    }
    
    func createDataGroupsSetSingle() -> SBADataGroupsStepProtocol? {
        let inputStep: NSDictionary = [
            "identifier": "dataGroupSelection",
            "type": "dataGroups.singleChoiceText",
            "title": "Which data groups do you want to be in?",
            "text": "Choose one",
            "optional" : false,
            "items": [
                [ "text" : "Group A+",
                  "value" : "A+",
                  "dataGroup" : "groupA"],
                [ "text" : "Group A",
                  "value" : "A",
                  "dataGroup" : "groupA"],
                [ "text" : "Group A-",
                  "value" : "A-",
                  "dataGroup" : "groupA"],
                [ "text" : "Group B+",
                  "value" : "B+",
                  "dataGroup" : "groupB"],
                [ "text" : "Group B-",
                  "value" : "B-",
                  "dataGroup" : "groupB"],
                [ "text" : "None",
                  "value" : "none",
                  "dataGroup" : ""]
            ],
            "expectedAnswer" : ["A+", "A", "A-"],
            "skipIdentifier" : "answerA"
        ]
        
        let step = SBABaseSurveyFactory().createSurveyStepWithDictionary(inputStep)
        XCTAssertNotNil(step)
        
        guard let surveyStep = step as? SBADataGroupsStepProtocol else {
            XCTAssert(false, "\(String(describing: step)) is not of expected class type")
            return nil
        }
        
        return surveyStep
    }
    
    func createResult(choices: [Any]?) -> ORKStepResult {
        let questionResult = ORKChoiceQuestionResult(identifier: "dataGroupSelection")
        questionResult.choiceAnswers = choices;
        let stepResult = ORKStepResult(stepIdentifier: "dataGroupSelection", results: [questionResult])
        return stepResult
    }
}
