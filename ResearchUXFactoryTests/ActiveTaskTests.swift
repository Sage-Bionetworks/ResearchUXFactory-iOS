//
//  SBAActiveTaskTests.swift
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
import ResearchKit
import ResearchUXFactory

class SBAActiveTaskTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: Test active task factory for predefined tasks
    // syoung 03/08/2017 When adding a test for task added to the SBAActiveTaskType list, please order alphabetically.
    
    func testCardioTask() {
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "1-Cardio-ABCD-1234",
            "schemaIdentifier"          : "Cardio Activity",
            "taskType"                  : "cardio",
            "intendedUseDescription"    : "intended Use Description Text",
            "taskOptions"               : [
                "walkDuration"          : 45.0,
                "restDuration"          : 20.0,
            ],
            "localizedSteps"               : [[
                "identifier" : "conclusion",
                "title"      : "Title 123",
                "text"       : "Text 123",
                "detailText" : "Detail Text 123"
                ]
            ]
        ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Cardio Activity")
        
        guard let task = result as? ORKOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        // Last - Completion
        guard let completionStep = task.steps.last as? ORKCompletionStep else {
            XCTAssert(false, "\(String(describing: task.steps.last)) not of expect class")
            return
        }
        XCTAssertEqual(completionStep.identifier, "conclusion")
        XCTAssertEqual(completionStep.title, "Title 123")
        XCTAssertEqual(completionStep.text, "Text 123")
        XCTAssertEqual(completionStep.detailText, "Detail Text 123")
        
        // The following steps are only applicable for the cardio task
        // for iOS 9, the fitnessTest task is returned instead.
        guard #available(iOS 10.0, *) else { return }
        
        let expectedCount = 13
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        // Step 1 - Overview
        guard let instructionStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(instructionStep.identifier, "instruction")
        XCTAssertEqual(instructionStep.detailText, "intended Use Description Text")
        
        // Step - Permissions Step
        guard let permissions = task.steps[1] as? SBAPermissionsStep else {
            XCTAssert(false, "\(task.steps[1]) not of expect class")
            return
        }
        XCTAssertNotNil(permissions.permissionTypes.find(withIdentifier: "coremotion"), "\(permissions.permissionTypes)")
        XCTAssertNotNil(permissions.permissionTypes.find(withIdentifier: "location"), "\(permissions.permissionTypes)")
        XCTAssertNotNil(permissions.permissionTypes.find(withIdentifier: "camera"), "\(permissions.permissionTypes)")
        let healthPermission = permissions.permissionTypes.find(withIdentifier: "healthKit") as? SBAHealthKitPermissionObjectType
        XCTAssertNotNil(healthPermission, "\(permissions.permissionTypes)")
        if let healthKitTypes = healthPermission?.healthKitTypes {
            XCTAssertNotNil(healthKitTypes.find(withIdentifier:"HKQuantityTypeIdentifierActiveEnergyBurned"))
            XCTAssertNotNil(healthKitTypes.find(withIdentifier:"HKQuantityTypeIdentifierDistanceWalkingRunning"))
            XCTAssertNotNil(healthKitTypes.find(withIdentifier:"HKWorkoutTypeIdentifier"))
            XCTAssertNotNil(healthKitTypes.find(withIdentifier:"HKQuantityTypeIdentifierHeartRate"))
        }
        else {
            XCTAssertNotNil(healthPermission?.healthKitTypes)
        }
        XCTAssertEqual(healthPermission!.readTypes!.count, 4)
        XCTAssertEqual(healthPermission!.writeTypes!.count, 4)
        
        // Step - Workout Step
        guard let _ = task.steps[8] as? ORKWorkoutStep else {
            XCTAssert(false, "\(task.steps[8]) not of expect class")
            return
        }
    }

    func testGoNoGoTask() {
        
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "1-Go-No-Go",
            "schemaIdentifier"          : "Go-No-Go",
            "taskType"                  : "goNoGo",
            "intendedUseDescription"    : "intended Use Description Text",
            "localizedSteps"               : [[
                "identifier" : "conclusion",
                "title"      : "Title 123",
                "text"       : "Text 123",
                "detailText" : "Detail Text 123"
                ]
            ]
        ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Go-No-Go")
        
        guard let task = result as? ORKOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let expectedCount = 5
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        // Step 1 - Overview
        guard let instructionStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(instructionStep.identifier, "instruction")
        XCTAssertEqual(instructionStep.text, "intended Use Description Text")
        
        // Step - Permissions
        guard let permissions = task.steps[1] as? SBAPermissionsStep else {
            XCTAssert(false, "\(task.steps[1]) not of expect class")
            return
        }
        XCTAssertEqual(permissions.permissionTypes.count, 1)
        XCTAssertEqual(permissions.permissionTypes.first?.identifier, "coremotion")
        
        // Step - Instruction
        guard let _ = task.steps[2] as? ORKInstructionStep else {
            XCTAssert(false, "\(task.steps[2]) not of expect class")
            return
        }

        // Step - Active
        guard let _ = task.steps[3] as? ORKActiveStep else {
            XCTAssert(false, "\(task.steps[3]) not of expect class")
            return
        }
        
        // Step - Completion
        guard let completionStep = task.steps.last as? ORKCompletionStep else {
            XCTAssert(false, "\(String(describing: task.steps.last)) not of expect class")
            return
        }
        XCTAssertEqual(completionStep.identifier, "conclusion")
        XCTAssertEqual(completionStep.title, "Title 123")
        XCTAssertEqual(completionStep.text, "Text 123")
        XCTAssertEqual(completionStep.detailText, "Detail Text 123")
    }
    
    func testMemoryTask() {
        
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "1-Memory-ABCD-1234",
            "schemaIdentifier"          : "Memory Activity",
            "taskType"                  : "memory",
            "intendedUseDescription"    : "intended Use Description Text",
            "taskOptions"               : [
                "initialSpan"               : 5,
                "minimumSpan"               : 3,
                "maximumSpan"               : 10,
                "playSpeed"                 : 1.5,
                "maxTests"                  : 6,
                "maxConsecutiveFailures"    : 4
            ],
        ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Memory Activity")
        
        guard let task = result as? ORKOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let expectedCount = 4
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        // First - Overview
        guard let instructionStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(instructionStep.identifier, "instruction")
        XCTAssertEqual(instructionStep.text, "intended Use Description Text")
        
        // Third - Memory
        guard let activeStep = task.steps[2] as? ORKSpatialSpanMemoryStep else {
            XCTAssert(false, "\(task.steps[2]) not of expect class")
            return
        }
        XCTAssertEqual(activeStep.identifier, "cognitive.memory.spatialspan")
        XCTAssertEqual(activeStep.initialSpan, 5)
        XCTAssertEqual(activeStep.minimumSpan, 3)
        XCTAssertEqual(activeStep.maximumSpan, 10)
        XCTAssertEqual(activeStep.playSpeed, 1.5)
        XCTAssertEqual(activeStep.maximumTests, 6)
        XCTAssertEqual(activeStep.maximumConsecutiveFailures, 4)
        
        // Last - Completion
        guard let completionStep = task.steps.last as? ORKCompletionStep else {
            XCTAssert(false, "\(String(describing: task.steps.last)) not of expect class")
            return
        }
        XCTAssertEqual(completionStep.identifier, "conclusion")
    }
    
    func testMoodSurveyTask() {
        
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "Mood Task",
            "schemaIdentifier"          : "Mood",
            "taskType"                  : "moodSurvey",
            "intendedUseDescription"    : "intended Use Description Text",
            "taskOptions"               : [
                "frequency"             : "weekly",
                "customQuestionText"    : "Custom Question Text"
            ],
            "localizedSteps"               : [[
                "identifier" : "conclusion",
                "title"      : "Title 123",
                "text"       : "Text 123",
                "detailText" : "Detail Text 123"
                ]
            ]
        ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Mood")
        
        guard let task = result as? ORKOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let expectedCount = 8
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        print("\(task.steps)")
        
        // Step 1 - Overview
        guard let instructionStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(instructionStep.identifier, "instruction")
        XCTAssertEqual(instructionStep.title, "Weekly Check-In")
        XCTAssertEqual(instructionStep.text, "intended Use Description Text")
        
        for ii in 1...(expectedCount - 2) {
            let questionStep = task.steps[ii] as? ORKQuestionStep
            XCTAssertNotNil(questionStep, "\(task.steps[ii])")
            let answerFormat = questionStep?.answerFormat as? ORKMoodScaleAnswerFormat
            XCTAssertNotNil(answerFormat, "\(task.steps[ii])")
        }
        
        // Step - Completion
        guard let completionStep = task.steps.last as? ORKCompletionStep else {
            XCTAssert(false, "\(String(describing: task.steps.last)) not of expect class")
            return
        }
        XCTAssertEqual(completionStep.identifier, "conclusion")
        XCTAssertEqual(completionStep.title, "Title 123")
        XCTAssertEqual(completionStep.text, "Text 123")
        XCTAssertEqual(completionStep.detailText, "Detail Text 123")
    }
    
    func testTappingTask() {
        
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "1-Tapping-ABCD-1234",
            "schemaIdentifier"          : "Tapping Activity",
            "taskType"                  : "tapping",
            "intendedUseDescription"    : "intended Use Description Text",
            "taskOptions"               : [
                "duration"      : 12.0,
                "handOptions"   : "right"
            ],
            "localizedSteps"               : [[
                "identifier" : "conclusion",
                "title"      : "Title 123",
                "text"       : "Text 123",
                "detailText" : "Detail Text 123"
                ]
            ]
        ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Tapping Activity")
        
        guard let task = result as? ORKOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let expectedCount = 5
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        // Step - Overview
        guard let instructionStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(instructionStep.identifier, "instruction")
        XCTAssertEqual(instructionStep.text, "intended Use Description Text")
        
        // Step - Permissions
        guard let permissions = task.steps[1] as? SBAPermissionsStep else {
            XCTAssert(false, "\(task.steps[1]) not of expect class")
            return
        }
        XCTAssertEqual(permissions.permissionTypes.count, 1)
        XCTAssertEqual(permissions.permissionTypes.first?.identifier, "coremotion")
        
        // Step - Right Hand Tapping Instruction
        guard let rightInstructionStep = task.steps[2] as? ORKInstructionStep else {
            XCTAssert(false, "\(task.steps[2]) not of expect class")
            return
        }
        XCTAssertEqual(rightInstructionStep.identifier, "instruction1.right")
        
        // Step - Right Hand Tapping
        guard let rightTappingStep = task.steps[3] as? ORKTappingIntervalStep else {
            XCTAssert(false, "\(task.steps[3]) not of expect class")
            return
        }
        XCTAssertEqual(rightTappingStep.identifier, "tapping.right")
        XCTAssertEqual(rightTappingStep.stepDuration, 12.0)
        
        // Step - Completion
        guard let completionStep = task.steps.last as? ORKCompletionStep else {
            XCTAssert(false, "\(String(describing: task.steps.last)) not of expect class")
            return
        }
        XCTAssertEqual(completionStep.identifier, "conclusion")
        XCTAssertEqual(completionStep.title, "Title 123")
        XCTAssertEqual(completionStep.text, "Text 123")
        XCTAssertEqual(completionStep.detailText, "Detail Text 123")
    }
    
    func testTrailmakingTask() {
        
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "1-Trail-Making",
            "schemaIdentifier"          : "Trail Making",
            "taskType"                  : "trailmaking",
            "intendedUseDescription"    : "intended Use Description Text",
            "taskOptions"               : [
                "trailType"                 : "A",
                "trailmakingInstruction"    : "trail making instruction"
            ],
            "localizedSteps"               : [[
                "identifier" : "conclusion",
                "title"      : "Title 123",
                "text"       : "Text 123",
                "detailText" : "Detail Text 123"
                ]
            ]
        ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Trail Making")
        
        guard let task = result as? ORKOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let expectedCount = 6
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        // Step 1 - Overview
        guard let instructionStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(instructionStep.identifier, "instruction")
        XCTAssertEqual(instructionStep.text, "intended Use Description Text")
        
        // Step 2 - Instruction
        guard let instruction1Step = task.steps[1] as? ORKInstructionStep else {
            XCTAssert(false, "\(task.steps[1]) not of expect class")
            return
        }
        XCTAssertEqual(instruction1Step.identifier, "instruction1")
        
        // Step 3 - Instruction
        guard let instruction2Step = task.steps[2] as? ORKInstructionStep else {
            XCTAssert(false, "\(task.steps[2]) not of expect class")
            return
        }
        XCTAssertEqual(instruction2Step.identifier, "instruction2")
        XCTAssertEqual(instruction2Step.text, "trail making instruction")
        
        
        // Countdown
        guard let countdownStep = task.steps[3] as? ORKCountdownStep else {
            XCTAssert(false, "\(task.steps[3]) not of expect class")
            return
        }
        XCTAssertEqual(countdownStep.identifier, "countdown")
        
        // Countdown
        guard let trailmakingStep = task.steps[4] as? ORKTrailmakingStep else {
            XCTAssert(false, "\(task.steps[4]) not of expect class")
            return
        }
        XCTAssertEqual(trailmakingStep.identifier, "trailmaking")
        XCTAssertEqual(trailmakingStep.trailType, ORKTrailMakingTypeIdentifier.A)
        
        // Completion
        guard let completionStep = task.steps.last as? ORKCompletionStep else {
            XCTAssert(false, "\(String(describing: task.steps.last)) not of expect class")
            return
        }
        XCTAssertEqual(completionStep.identifier, "conclusion")
        XCTAssertEqual(completionStep.title, "Title 123")
        XCTAssertEqual(completionStep.text, "Text 123")
        XCTAssertEqual(completionStep.detailText, "Detail Text 123")
    }
    
    
    func testTremorTask_Right_IncludeAll() {
        
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "1-Tremor-ABCD-1234",
            "schemaIdentifier"          : "Tremor Activity",
            "taskType"                  : "tremor",
            "intendedUseDescription"    : "intended Use Description Text",
            "taskOptions"               : [
                "duration"      : 10.0,
                "handOptions"   : "right",
            ],
            ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Tremor Activity")
        
        guard let task = result as? ORKOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let expectedCount = 19
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        // Step 1 - Overview
        guard let instructionStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(instructionStep.identifier, "instruction")
        XCTAssertEqual(instructionStep.text, "intended Use Description Text")
        
        // Step - Permissions
        guard let permissions = task.steps[1] as? SBAPermissionsStep else {
            XCTAssert(false, "\(task.steps[1]) not of expect class")
            return
        }
        XCTAssertEqual(permissions.permissionTypes.count, 1)
        XCTAssertEqual(permissions.permissionTypes.first?.identifier, "coremotion")
        
        // Step 2 - Additional Instruction
        guard let additionalInstructionStep = task.steps[2] as? ORKInstructionStep else {
            XCTAssert(false, "\(task.steps[2]) not of expect class")
            return
        }
        XCTAssertEqual(additionalInstructionStep.identifier, "instruction1.right")
        
        // Step 3 - Right Hand Tremor Instruction
        guard let rightInstructionStep = task.steps[3] as? ORKInstructionStep else {
            XCTAssert(false, "\(task.steps[3]) not of expect class")
            return
        }
        XCTAssertEqual(rightInstructionStep.identifier, "instruction2.right")
        
        // Step 4 - Count down
        guard let countStep = task.steps[4] as? ORKCountdownStep else {
            XCTAssert(false, "\(task.steps[4]) not of expect class")
            return
        }
        XCTAssertEqual(countStep.identifier, "countdown1.right")
        
        // Step 5 - Hand In Lap
        guard let handInLapStep = task.steps[5] as? ORKActiveStep else {
            XCTAssert(false, "\(task.steps[5]) not of expect class")
            return
        }
        XCTAssertEqual(handInLapStep.identifier, "tremor.handInLap.right")
        
        // Last - Completion
        guard let completionStep = task.steps.last as? ORKCompletionStep else {
            XCTAssert(false, "\(String(describing: task.steps.last)) not of expect class")
            return
        }
        XCTAssertEqual(completionStep.identifier, "conclusion")
    }
    
    func testTremorTask_Both_ExcludeNoseAndElbowBent() {
        
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "1-Tremor-ABCD-1234",
            "schemaIdentifier"          : "Tremor Activity",
            "taskType"                  : "tremor",
            "intendedUseDescription"    : "intended Use Description Text",
            "taskOptions"               : [
                "duration"          : 10.0,
                "handOptions"       : "both",
                "excludePostions"   : ["elbowBent", "touchNose"]
            ],
            ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Tremor Activity")
        
        guard let task = result as? ORKOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let introSteps = ["instruction",
                          "skipHand",
                          "SBAPermissionStep"]
        let bothHandSteps = ["instruction1.",
                             "instruction2.",
                             "countdown1.",
                             "tremor.handInLap.",
                             "instruction4.",
                             "countdown2.",
                             "tremor.handAtShoulderLength.",
                             "instruction7.",
                             "countdown5.",
                             "tremor.handQueenWave."]
        let endSteps = ["conclusion"]
        
        let expectedCount = introSteps.count + 2 * bothHandSteps.count + endSteps.count
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        // Step - Overview
        guard let introStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(introStep.identifier, introSteps[0])
        XCTAssertEqual(introStep.text, "intended Use Description Text")
        
        // Step - Permissions Step
        guard let _ = task.steps[1] as? SBAPermissionsStep else {
            XCTAssert(false, "\(task.steps[1]) not of expect class")
            return
        }
        
        // Step - Navigation
        guard let navStep = task.steps[2] as? ORKQuestionStep else {
            XCTAssert(false, "\(task.steps[2]) not of expect class")
            return
        }
        XCTAssertEqual(navStep.identifier, introSteps[1])
        
        // Steps - Each hand
        for hand in 1...2 {
            let start = introSteps.count + (hand - 1) * bothHandSteps.count
            let end = start + bothHandSteps.count
            let handSteps = Array(task.steps[start..<end])
            for (idx, step) in handSteps.enumerated() {
                XCTAssertTrue(step.identifier.hasPrefix(bothHandSteps[idx]), "expected=\(bothHandSteps[idx]) actual=\(step.identifier)")
            }
        }
        
        // Last - Completion
        guard let completionStep = task.steps.last as? ORKCompletionStep else {
            XCTAssert(false, "\(String(describing: task.steps.last)) not of expect class")
            return
        }
        XCTAssertEqual(completionStep.identifier, endSteps[0])
    }

    
    func testVoiceTask() {
        
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "1-Voice-ABCD-1234",
            "schemaIdentifier"          : "Voice Activity",
            "taskType"                  : "voice",
            "intendedUseDescription"    : "intended Use Description Text",
            "taskOptions"               : [
                "duration"              : 10.0,
                "speechInstruction"     : "Speech Instruction",
                "shortSpeechInstruction": "Short Speech Instruction"
            ],
        ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Voice Activity")
        
        guard let task = result as? ORKNavigableOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let expectedCount = 7
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        // Step 1 - Overview
        guard let instructionStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(instructionStep.identifier, "instruction")
        XCTAssertEqual(instructionStep.text, "intended Use Description Text")
        
        // Step - Permissions
        guard let permissions = task.steps[1] as? SBAPermissionsStep else {
            XCTAssert(false, "\(task.steps[1]) not of expect class")
            return
        }
        XCTAssertEqual(permissions.permissionTypes.count, 1)
        XCTAssertEqual(permissions.permissionTypes.first?.identifier, "microphone")
        
        // Step 2 - Detail Instruction
        guard let instructionDetailStep = task.steps[2] as? ORKInstructionStep else {
            XCTAssert(false, "\(task.steps[2]) not of expect class")
            return
        }
        XCTAssertEqual(instructionDetailStep.identifier, "instruction1")
        XCTAssertEqual(instructionDetailStep.text, "Speech Instruction")
        
        // Step 3 - Count down
        guard let countStep = task.steps[3] as? ORKCountdownStep else {
            XCTAssert(false, "\(task.steps[3]) not of expect class")
            return
        }
        XCTAssertEqual(countStep.identifier, "countdown")
        let audioRule = task.navigationRule(forTriggerStepIdentifier: countStep.identifier)
        XCTAssertNotNil(audioRule)
        
        // Step 4 - audio too loud
        guard let tooLoudStep = task.steps[4] as? ORKInstructionStep else {
            XCTAssert(false, "\(task.steps[4]) not of expect class")
            return
        }
        XCTAssertEqual(tooLoudStep.identifier, "audio.tooloud")
        if let navTooLoudRule = task.navigationRule(forTriggerStepIdentifier: tooLoudStep.identifier) as? ORKDirectStepNavigationRule {
            XCTAssertEqual(navTooLoudRule.destinationStepIdentifier, countStep.identifier)
        }
        else {
            XCTAssert(false, "\(tooLoudStep.identifier) navigation rule missing or not expected type")
        }
        
        // Step 5 - Audio
        guard let audioStep = task.steps[5] as? ORKAudioStep else {
            XCTAssert(false, "\(task.steps[5]) not of expect class")
            return
        }
        XCTAssertEqual(audioStep.identifier, "audio")
        XCTAssertEqual(audioStep.title, "Short Speech Instruction")
        
        // Last - Completion
        guard let completionStep = task.steps.last as? ORKCompletionStep else {
            XCTAssert(false, "\(String(describing: task.steps.last)) not of expect class")
            return
        }
        XCTAssertEqual(completionStep.identifier, "conclusion")
    }
    
    func testWalkingTask() {
        
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "1-Walking-ABCD-1234",
            "schemaIdentifier"          : "Walking Activity",
            "taskType"                  : "walking",
            "intendedUseDescription"    : "intended Use Description Text",
            "taskOptions"               : [
                "walkDuration"          : 45.0,
                "restDuration"          : 20.0,
            ],
            ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Walking Activity")
        
        guard let task = result as? ORKOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let expectedCount = 7
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        // Step 1 - Overview
        guard let instructionStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(instructionStep.identifier, "instruction")
        XCTAssertEqual(instructionStep.text, "intended Use Description Text")
        
        // Step - Permissions
        guard let permissions = task.steps[1] as? SBAPermissionsStep else {
            XCTAssert(false, "\(task.steps[1]) not of expect class")
            return
        }
        XCTAssertEqual(permissions.permissionTypes.count, 1)
        XCTAssertEqual(permissions.permissionTypes.first?.identifier, "coremotion")
        
        // Step 2 - Detail Instruction
        guard let instructionDetailStep = task.steps[2] as? ORKInstructionStep else {
            XCTAssert(false, "\(task.steps[2]) not of expect class")
            return
        }
        XCTAssertEqual(instructionDetailStep.identifier, "instruction1")
        
        // Step 3 - Count down
        guard let countStep = task.steps[3] as? ORKCountdownStep else {
            XCTAssert(false, "\(task.steps[3]) not of expect class")
            return
        }
        XCTAssertEqual(countStep.identifier, "countdown")
        
        // Step 4 - Walking
        guard let walkingStep = task.steps[4] as? ORKWalkingTaskStep else {
            XCTAssert(false, "\(task.steps[4]) not of expect class")
            return
        }
        XCTAssertEqual(walkingStep.identifier, "walking.outbound")
        XCTAssertEqual(walkingStep.stepDuration, 45.0)
        
        // Step 5 - Rest
        guard let restStep = task.steps[5] as? ORKFitnessStep else {
            XCTAssert(false, "\(task.steps[5]) not of expect class")
            return
        }
        XCTAssertEqual(restStep.identifier, "walking.rest")
        XCTAssertEqual(restStep.stepDuration, 20.0)
        
        // Last - Completion
        guard let completionStep = task.steps.last as? ORKCompletionStep else {
            XCTAssert(false, "\(String(describing: task.steps.last)) not of expect class")
            return
        }
        XCTAssertEqual(completionStep.identifier, "conclusion")
    }
    
    // MARK: Additional functionality tests
    
    func testGroupedActiveTask() {
        
        let tappingTask: NSDictionary = [
            "taskIdentifier"            : "1-Tapping-ABCD-1234",
            "schemaIdentifier"          : "Tapping Activity",
            "surveyItemType"            : "activeTask",
            "taskType"                  : "tapping",
        ]
        
        let voiceTask: NSDictionary = [
            "taskIdentifier"            : "1-Voice-ABCD-1234",
            "schemaIdentifier"          : "Voice Activity",
            "taskType"                  : "voice",
            "intendedUseDescription"    : "intended Use Description Text",
            "predefinedExclusions"      : 0,
            ]
        
        let walkingTask: NSDictionary = [
            "taskIdentifier"            : "1-Walking-ABCD-1234",
            "schemaIdentifier"          : "Walking Activity",
            "surveyItemType"            : "activeTask",
            "taskType"                  : "walking",
            ]
        
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "1-Combo-ABCD-1234",
            "steps"                 :[
                [
                    "identifier" : "introduction",
                    "text" : "This is a combo task",
                    "detailText": "Tap the button below to begin",
                    "type"  : "instruction",
                ],
                tappingTask,
                voiceTask,
                walkingTask
            ],
            "insertSteps"               :[
                [
                    "resourceName"      : "MedicationTracking",
                    "resourceBundle"    : Bundle(for: self.classForCoder).bundleIdentifier,
                    "classType"         : "TrackedDataObjectCollection"
                    ]
                ]
        ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "1-Combo-ABCD-1234")
        
        guard let task = result as? SBANavigableOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let expectedCount = 7
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        // Step 1 - Overview
        guard let instructionStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(instructionStep.identifier, "introduction")
        XCTAssertEqual(instructionStep.text, "This is a combo task")
        XCTAssertEqual(instructionStep.detailText, "Tap the button below to begin")
        
        // Step 2 - Medication tracking
        let medStep = task.steps[1]
        XCTAssertEqual(medStep.identifier, "Medication Tracker")
        
        // Step 3 - Tapping Subtask
        guard let tappingStep = task.steps[2] as? SBASubtaskStep,
            let tapTask = tappingStep.subtask as? ORKOrderedTask,
            let lastTapStep = tapTask.steps.last else {
            XCTAssert(false, "\(task.steps[2]) not of expect class")
            return
        }
        XCTAssertEqual(tappingStep.identifier, "Tapping Activity")
        XCTAssertNotEqual(lastTapStep.identifier, "conclusion")
        
        // Progress Step
        guard let progressStep1 = task.steps[3] as? SBAProgressStep else {
            XCTAssert(false, "\(task.steps[3]) not of expect class")
            return
        }
        let actualTitles1 = progressStep1.items!.map({ $0.description })
        let expectedTitles1 = ["\u{2705} Tapping Speed", "\u{2003}\u{2002} Voice", "\u{2003}\u{2002} Gait and Balance"]
        XCTAssertEqual(actualTitles1, expectedTitles1)
        
        
        // Step 4 - Voice Subtask
        guard let voiceStep = task.steps[4] as? SBASubtaskStep,
            let vTask = voiceStep.subtask as? ORKOrderedTask,
            let lastVoiceStep = vTask.steps.last else {
            XCTAssert(false, "\(task.steps[4]) not of expect class")
            return
        }
        XCTAssertEqual(voiceStep.identifier, "Voice Activity")
        XCTAssertEqual(lastVoiceStep.identifier, "conclusion")
        
        // Progress Step
        guard let progressStep2 = task.steps[5] as? SBAProgressStep else {
            XCTAssert(false, "\(task.steps[5]) not of expect class")
            return
        }
        let actualTitles2 = progressStep2.items!.map({ $0.description })
        let expectedTitles2 = ["\u{2705} Tapping Speed", "\u{2705} Voice", "\u{2003}\u{2002} Gait and Balance"]
        XCTAssertEqual(actualTitles2, expectedTitles2)
        
        // Step 5 - Walking Subtask
        guard let memoryStep = task.steps[6] as? SBASubtaskStep,
            let mTask = memoryStep.subtask as? ORKOrderedTask,
            let lastMemoryStep = mTask.steps.last else {
            XCTAssert(false, "\(task.steps[6]) not of expect class")
            return
        }
        XCTAssertEqual(memoryStep.identifier, "Walking Activity")
        XCTAssertEqual(lastMemoryStep.identifier, "conclusion")
        
    }
    
    func testSurveyTask() {
        
        let inputTask: NSDictionary = [
            "taskIdentifier"    : "1-StudyTracker-1234",
            "schemaIdentifier"  : "Study Drug Tracker",
            "steps"         : [
                [
                    "identifier"   : "studyDrugTiming",
                    "type"         : "singleChoiceText",
                    "title"        : "Study Drug Timing",
                    "text"         : "Indicate when the patient takes the Study Drug",
                    "items"        : [
                        [
                            "prompt" : "The patient has taken the drug now",
                            "value"   : true
                        ],
                        [
                            "prompt" : "Cancel",
                            "value"   : false
                        ]
                    ],
                ]
            ]
        ]
    
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Study Drug Tracker")
        
        guard let task = result as? ORKOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let expectedCount = 1
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }
        
        // Step 1 - Overview
        guard let formStep = task.steps.first as? ORKFormStep,
            let formItem = formStep.formItems?.first,
            let answerFormat = formItem.answerFormat as? ORKTextChoiceAnswerFormat
        else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(formStep.identifier, "studyDrugTiming")
        XCTAssertEqual(answerFormat.textChoices.count, 2)
    }
    
    func testTaskWithInsertSteps_Single() {
        
        let inputTask: NSDictionary = [
            "taskIdentifier"            : "1-Tapping-ABCD-1234",
            "schemaIdentifier"          : "Tapping Activity",
            "surveyItemType"            : "activeTask",
            "taskType"                  : "tapping",
            "insertSteps"               :[
                [
                    "resourceName"      : "MedicationTracking",
                    "resourceBundle"    : Bundle(for: self.classForCoder).bundleIdentifier ?? "",
                    "classType"         : "TrackedDataObjectCollection"
                ]
            ]
        ]
        
        let result = inputTask.createORKTask()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.identifier, "Tapping Activity")
        
        guard let task = result as? SBANavigableOrderedTask else {
            XCTAssert(false, "\(String(describing: result)) not of expect class")
            return
        }
        
        let expectedCount = 3
        XCTAssertEqual(task.steps.count, expectedCount, "\(task.steps)")
        guard task.steps.count == expectedCount else { return }

        // Step 1 - Overview
        guard let instructionStep = task.steps.first as? ORKInstructionStep else {
            XCTAssert(false, "\(String(describing: task.steps.first)) not of expect class")
            return
        }
        XCTAssertEqual(instructionStep.identifier, "instruction")

        // Step 2 - Medication tracking
        let medStep = task.steps[1]
        XCTAssertEqual(medStep.identifier, "Medication Tracker")

        // Step 3 - Tapping Subtask
        guard let tappingStep = task.steps[2] as? SBASubtaskStep,
            let tapTask = tappingStep.subtask as? ORKOrderedTask else {
                XCTAssert(false, "\(task.steps[2]) not of expect class")
                return
        }
        
        XCTAssertEqual(tappingStep.identifier, "Tapping Activity")
        XCTAssertEqual(tapTask.identifier, "Tapping Activity")
        
    }

}
