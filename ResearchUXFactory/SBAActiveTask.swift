//
//  SBAActiveTaskFactory.swift
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
import AVFoundation

public enum SBAActiveTaskType {
    
    case custom(String?)
    
    case activeTask(Identifier)
    public enum Identifier : String {
        case cardio
        case goNoGo
        case tapping
        case trailmaking
        case tremor
        case voice
        case walking
    
        // Deprecated
        case memory
    }
    
    init(name: String?) {
        guard (name != nil), let identifier = Identifier(rawValue: name!)
        else {
            self = .custom(name)
            return
        }
        self = .activeTask(identifier)
    }
    
    func isNilType() -> Bool {
        if case .custom(let customType) = self {
            return (customType == nil)
        }
        return false
    }
    
    func activeTaskIdentifier() -> Identifier? {
        if case .activeTask(let identifier) = self {
            return identifier
        }
        return nil
    }
    

}

extension SBAActiveTaskType: Equatable {
}

public func ==(lhs: SBAActiveTaskType, rhs: SBAActiveTaskType) -> Bool {
    switch (lhs, rhs) {
    case (.activeTask(let lhsValue), .activeTask(let rhsValue)):
        return lhsValue == rhsValue;
    case (.custom(let lhsValue), .custom(let rhsValue)):
        return lhsValue == rhsValue;
    default:
        return false
    }
}

extension ORKPredefinedTaskHandOption {
    init(name: String?) {
        let name = name ?? "both"
        switch name {
        case "right"    : self = .right
        case "left"     : self = .left
        default         : self = .both
        }
    }
}

extension ORKTremorActiveTaskOption {
    init(excludes: [String]?) {
        guard let excludes = excludes else {
            self.init(rawValue: 0)
            return
        }
        let rawValue: UInt = excludes.map({ (exclude) -> ORKTremorActiveTaskOption in
            switch exclude {
            case "inLap"            : return .excludeHandInLap
            case "shoulderHeight"   : return .excludeHandAtShoulderHeight
            case "elbowBent"        : return .excludeHandAtShoulderHeightElbowBent
            case "touchNose"        : return .excludeHandToNose
            case "queenWave"        : return .excludeQueenWave
            default                 : return []
            }
        }).reduce(0) { (raw, option) -> UInt in
            return option.rawValue | raw
        }
        self.init(rawValue: rawValue)
    }
}

public protocol SBAActiveTask: SBABridgeTask, SBAStepTransformer {
    var taskType: SBAActiveTaskType { get }
    var intendedUseDescription: String? { get }
    var taskOptions: [String : Any]? { get }
    var predefinedExclusions: ORKPredefinedTaskOption? { get }
    var localizedSteps: [SBASurveyItem]? { get }
    var optional: Bool { get }
    var ignorePermissions: Bool { get }
}

extension SBAActiveTask {
    
    public func createDefaultORKActiveTask(_ options: ORKPredefinedTaskOption) -> ORKOrderedTask? {
        
        guard let activeTaskIdentifier = self.taskType.activeTaskIdentifier() else { return nil }
        
        let predefinedExclusions = self.predefinedExclusions ?? options
        var task:ORKOrderedTask = {
            switch activeTaskIdentifier {
                
            case .cardio:
                return cardioTask(predefinedExclusions)
                
            case .goNoGo:
                return goNoGoTask(predefinedExclusions)

            case .memory:
                return memoryTask(predefinedExclusions)
                
            case .tapping:
                return tappingTask(predefinedExclusions)
                
            case .trailmaking:
                return trailmakingTask(predefinedExclusions)
                
            case .tremor:
                return tremorTask(predefinedExclusions)
                
            case .voice:
                return voiceTask(predefinedExclusions)
                
            case .walking:
                return walkingTask(predefinedExclusions)
            }
        }()
        
        // Modify the instruction step if this is an optional task
        if self.optional {
            task = taskWithSkipAction(task)
        }
        
        // Add the permissions step
        if !self.ignorePermissions,
            let permissionTypes = SBAPermissionsManager.shared.permissionsTypeFactory.permissionTypes(for: task) {
            task = taskWithPermissions(task, permissionTypes)
        }
        
        // map the localized steps
        mapLocalizedSteps(task)
        
        return task
    }
    
    
    // MARK: modification functions
    
    public func taskWithPermissions(_ task: ORKOrderedTask, _ permissions: [SBAPermissionObjectType]) -> ORKOrderedTask {
        
        // Add the permission step
        let permissionsStep = SBAPermissionsStep(identifier: "SBAPermissionsStep")
        permissionsStep.text = Localization.localizedString("PERMISSIONS_TASK_TEXT")
        permissionsStep.permissionTypes = permissions
        permissionsStep.isOptional = false
        var steps = task.steps
        let idx = steps.first is ORKInstructionStep ? 1 : 0
        steps.insert(permissionsStep, at: idx)
        
        if let navTask = task as? ORKNavigableOrderedTask {
            // If this is a navigation task then create a navgiation rule
            // and use that to setup the skip rules
            let copy = navTask.copy(with: steps)
            let skipRule = SBAPermissionsSkipRule(permissionTypes: permissions)
            copy.setSkip(skipRule, forStepIdentifier: permissionsStep.identifier)
            return copy
        }
        else if type(of: task) === ORKOrderedTask.self {
            // If this is an ORKOrderedTask then turn it into an SBANavigableOrderedTask
            return SBANavigableOrderedTask(identifier: task.identifier, steps: steps)
        }
        else if let navTask = task as? SBANavigableOrderedTask {
            // If this is a subclass of an SBANavigableOrderedTask then copy it
            return navTask.copy(with: steps)
        }
        else {
            // Otherwise, adding the permissions isn't supported.
            assertionFailure("Handling of permissions task is not implemented for this task: \(task)")
            return task
        }
    }
    
    public func taskWithSkipAction(_ task: ORKOrderedTask) -> ORKOrderedTask {
        
        guard type(of: task) === ORKOrderedTask.self else {
            assertionFailure("Handling of an optional task is not implemented for any class other than ORKOrderedTask")
            return task
        }
        guard let introStep = task.steps.first as? ORKInstructionStep else {
            assertionFailure("Handling of an optional task is not implemented for tasks that do not start with ORKIntructionStep")
            return task
        }
        guard let conclusionStep = task.steps.last as? ORKInstructionStep else {
            assertionFailure("Handling of an optional task is not implemented for tasks that do not end with ORKIntructionStep")
            return task
        }
        
        // Replace the intro step with a direct navigation step that has a skip button 
        // to skip to the conclusion
        let replaceStep = SBAInstructionStep(identifier: introStep.identifier)
        replaceStep.title = introStep.title
        replaceStep.text = introStep.text
        let skipExplanation = Localization.localizedString("SBA_SKIP_ACTIVITY_INSTRUCTION")
        let detail = introStep.detailText ?? ""
        replaceStep.detailText = "\(detail)\n\(skipExplanation)\n"
        replaceStep.learnMoreAction = SBASkipAction(identifier: conclusionStep.identifier)
        replaceStep.learnMoreAction!.learnMoreButtonText = Localization.localizedString("SBA_SKIP_ACTIVITY")
        var steps: [ORKStep] = task.steps
        steps.removeFirst()
        steps.insert(replaceStep, at: 0)
        
        // Return a navigable ordered task
        return SBANavigableOrderedTask(identifier: task.identifier, steps: steps)
    }
    
    public func mapLocalizedSteps(_ task: ORKOrderedTask) {
        // Map the title, text and detail from the localizedSteps to their matching step from the
        // base factory method defined
        if let items = self.localizedSteps {
            for item in items {
                if let step = task.steps.sba_find({ return $0.identifier == item.identifier }) {
                    step.title = item.stepTitle ?? step.title
                    step.text = item.stepText ?? step.text
                    if let instructionItem = item as? SBAInstructionStepSurveyItem,
                        let detail = instructionItem.stepDetail,
                        let instructionStep = step as? ORKInstructionStep {
                        instructionStep.detailText = detail
                    }
                    if let instructionItem = item as? SBAInstructionStepSurveyItem,
                        let image = instructionItem.stepImage,
                        let instructionStep = step as? ORKInstructionStep {
                        instructionStep.image = image
                    }
                    if let activeStep = step as? ORKActiveStep,
                        let activeItem = item as? SBAActiveStepSurveyItem {
                        if let spokenInstruction = activeItem.stepSpokenInstruction {
                            activeStep.spokenInstruction = spokenInstruction
                        }
                        if let finishedSpokenInstruction = activeItem.stepFinishedSpokenInstruction {
                            activeStep.finishedSpokenInstruction = finishedSpokenInstruction
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: active task factory
    
    public func cardioTask(_ options: ORKPredefinedTaskOption) -> ORKOrderedTask {
        
        let opt = CardioChallengeTaskOptions(taskOptions: taskOptions)
        return ORKOrderedTask.fitnessCheck(withIdentifier: self.schemaIdentifier,
                                               intendedUseDescription: self.intendedUseDescription,
                                               walkDuration: opt.walkDuration,
                                               restDuration: opt.restDuration,
                                               options: options)
    }
    
    public func goNoGoTask(_ options: ORKPredefinedTaskOption) -> ORKOrderedTask {
        
        let opt = GoNoGoTaskOptions(taskOptions: taskOptions)
        
        return ORKOrderedTask.gonogoTask(withIdentifier: self.schemaIdentifier,
                                             intendedUseDescription: self.intendedUseDescription,
                                             maximumStimulusInterval: opt.maximumStimulusInterval,
                                             minimumStimulusInterval: opt.minimumStimulusInterval,
                                             thresholdAcceleration: opt.thresholdAcceleration,
                                             numberOfAttempts: opt.numberOfAttempts,
                                             timeout: opt.timeout,
                                             successSound: opt.successSound,
                                             timeoutSound: opt.timeoutSound,
                                             failureSound: opt.failureSound,
                                             options: options)
    }
    
    public func tappingTask(_ options: ORKPredefinedTaskOption) -> ORKOrderedTask {
        
        let opt = TappingTaskOptions(taskOptions: taskOptions)
        
        return ORKOrderedTask.twoFingerTappingIntervalTask(withIdentifier: self.schemaIdentifier,
                                                               intendedUseDescription: self.intendedUseDescription,
                                                               duration: opt.duration,
                                                               handOptions: opt.handOptions,
                                                               options: options)
    }
    
    public func trailmakingTask(_ options: ORKPredefinedTaskOption) -> ORKOrderedTask {
        
        let opt = TrailmakingTaskOptions(taskOptions: taskOptions)
        
        return ORKOrderedTask.trailmakingTask(withIdentifier: self.schemaIdentifier,
                                                  intendedUseDescription: self.intendedUseDescription,
                                                  trailmakingInstruction: opt.trailmakingInstruction,
                                                  trailType: opt.trailType,
                                                  options: options)
    }
    
    public func tremorTask(_ options: ORKPredefinedTaskOption) -> ORKOrderedTask {
        
        let opt = TremorTaskOptions(taskOptions: taskOptions)
        
        return ORKOrderedTask.tremorTest(withIdentifier: self.schemaIdentifier,
                                             intendedUseDescription: self.intendedUseDescription,
                                             activeStepDuration: opt.duration,
                                             activeTaskOptions: opt.excludeOptions,
                                             handOptions: opt.handOptions,
                                             options: options)
    }
    
    public func voiceTask(_ options: ORKPredefinedTaskOption) -> ORKOrderedTask {
        
        let opt = AudioTaskOptions(taskOptions: taskOptions)
        
        return ORKOrderedTask.audioTask(withIdentifier: self.schemaIdentifier,
                                            intendedUseDescription: self.intendedUseDescription,
                                            speechInstruction: opt.speechInstruction,
                                            shortSpeechInstruction: opt.shortSpeechInstruction,
                                            duration: opt.duration,
                                            recordingSettings: opt.recordingSettings,
                                            checkAudioLevel: true,
                                            options: options)
    }
    
    public func walkingTask(_ options: ORKPredefinedTaskOption) -> ORKOrderedTask {
        
        // The walking activity is assumed to be walking back and forth rather than trying to walk down a long hallway.
        let opt = WalkAndBalanceTaskOptions(taskOptions: taskOptions)
        
        return ORKOrderedTask.walkBackAndForthTask(withIdentifier: self.schemaIdentifier,
                                                       intendedUseDescription: self.intendedUseDescription,
                                                       walkDuration: opt.walkDuration,
                                                       restDuration: opt.restDuration,
                                                       options: options)
    }
    

    // MARK: Deprecated
    
    func memoryTask(_ options: ORKPredefinedTaskOption) -> ORKOrderedTask {
        // Use a fatal error rather than marking unavailable b/c these tasks are build from dictionaries.  syoung 06/01/2017
        fatalError("Not Available: Research has shown that this test isn't valid. Sage no longer supports this task.")
    }
    
}

public struct AudioTaskOptions {
    
    let speechInstruction: String?
    let shortSpeechInstruction: String?
    let duration: TimeInterval
    let recordingSettings: [String: AnyObject]?
    
    public init(taskOptions: [String : Any]?) {
        speechInstruction = taskOptions?["speechInstruction"] as? String
        shortSpeechInstruction = taskOptions?["shortSpeechInstruction"] as? String
        duration = taskOptions?["duration"] as? TimeInterval ?? 10.0
        recordingSettings = taskOptions?["recordingSettings"] as? [String: AnyObject]
    }
}

public struct GoNoGoTaskOptions {
    
    let maximumStimulusInterval: TimeInterval
    let minimumStimulusInterval: TimeInterval
    let thresholdAcceleration: Double
    let numberOfAttempts: Int32
    let timeout: TimeInterval
    let successSound: SystemSoundID
    let timeoutSound: SystemSoundID
    let failureSound: SystemSoundID
    
    public init(taskOptions: [String : Any]?) {
        
        maximumStimulusInterval = taskOptions?["maximumStimulusInterval"] as? TimeInterval ?? 10.0
        minimumStimulusInterval = taskOptions?["minimumStimulusInterval"] as? TimeInterval ?? 4.0
        thresholdAcceleration = taskOptions?["thresholdAcceleration"] as? Double ?? 0.5
        numberOfAttempts = taskOptions?["numberOfAttempts"] as? Int32 ?? 9
        timeout = taskOptions?["timeout"] as? TimeInterval ?? 3.0
        
        func findSoundID(key: String, defaultSound:SystemSoundID) -> SystemSoundID {
            guard let sound = taskOptions?["key"] else { return defaultSound }
            if let resource = sound as? String {
                let soundID = SBAResourceFinder.shared.systemSoundID(forResource: resource)
                return soundID > 0 ? soundID : defaultSound
            }
            else if let soundID = sound as? SystemSoundID {
                return soundID
            }
            return defaultSound
        }
        
        successSound = findSoundID(key: "successSound", defaultSound: 1013)
        timeoutSound = findSoundID(key: "timeoutSound", defaultSound: 0)
        failureSound = findSoundID(key: "failureSound", defaultSound: SystemSoundID(kSystemSoundID_Vibrate))
    }
}

public struct CardioChallengeTaskOptions {
    
    let walkDuration: TimeInterval
    let restDuration: TimeInterval
    let relativeDistanceOnly: Bool
    
    public init(taskOptions: [String : Any]?) {
        walkDuration = taskOptions?["walkDuration"] as? TimeInterval ?? 6 * 60.0
        restDuration = taskOptions?["restDuration"] as? TimeInterval ?? 0.0
        relativeDistanceOnly = {
            if let ret = taskOptions?["relativeDistanceOnly"] as? Bool {
                return ret
            }
            // The info manager is defined using Obj-c which does not have forced optionals
            // as a casting type. Since the currentParticipant is set during app launch,
            // for testing it might not be there. Therefore, cast it to optional and then 
            // return either it's value or false as the default.
            let participant: SBAParticipantInfo? = SBAInfoManager.shared.currentParticipant
            return participant?.isTestUser ?? false
        }()
    }
}

public struct TappingTaskOptions {
    
    let duration: TimeInterval
    let handOptions: ORKPredefinedTaskHandOption
    
    public init(taskOptions: [String : Any]?) {
        duration = taskOptions?["duration"] as? TimeInterval ?? 10.0
        handOptions = ORKPredefinedTaskHandOption(name: taskOptions?["handOptions"] as? String)
    }
}

public struct TrailmakingTaskOptions {
    
    let trailType: ORKTrailMakingTypeIdentifier
    let trailmakingInstruction: String?
    
    public init(taskOptions: [String : Any]?) {
        trailType = {
            guard let trailType = taskOptions?["trailType"] as? String else {
                return ORKTrailMakingTypeIdentifier.B
            }
            return ORKTrailMakingTypeIdentifier(rawValue: trailType)
        }()
        trailmakingInstruction = taskOptions?["trailmakingInstruction"] as? String
    }
}

public struct TremorTaskOptions {
    
    let duration: TimeInterval
    let handOptions: ORKPredefinedTaskHandOption
    let excludeOptions: ORKTremorActiveTaskOption
    
    public init(taskOptions: [String : Any]?) {
        duration = taskOptions?["duration"] as? TimeInterval ?? 10.0
        handOptions = ORKPredefinedTaskHandOption(name: taskOptions?["handOptions"] as? String)
        excludeOptions = ORKTremorActiveTaskOption(excludes: taskOptions?["excludePostions"] as? [String])
    }
}

public struct WalkAndBalanceTaskOptions {
    
    let walkDuration: TimeInterval
    let restDuration: TimeInterval
    
    public init(taskOptions: [String : Any]?) {
        walkDuration = taskOptions?["walkDuration"] as? TimeInterval ?? 30.0
        restDuration = taskOptions?["restDuration"] as? TimeInterval ?? 30.0
    }
}




