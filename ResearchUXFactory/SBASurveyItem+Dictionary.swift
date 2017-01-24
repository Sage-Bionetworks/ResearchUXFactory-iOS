//
//  SBASurveyItem+Dictionary.swift
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

func key(_ dictionaryKey: DictionaryKey) -> String {
    return dictionaryKey.rawValue
}

enum DictionaryKey: String {
    
    // extension NSDictionary: SBASurveyItem
    case identifier                     // var identifier: String!
    case type                           // var surveyItemType: SBASurveyItemType (raw value)
    case title                          // var stepTitle: String?
    case text                           // var stepText: String?
    case prompt                         // var stepText: String? (deprecated)
    case detailText                     // var stepDetail: String?
    case footnote                       // var stepFootnote: String?
    case options                        // var options: [String : AnyObject]?
    
    // extension NSDictionary: SBAActiveStepSurveyItem
    case spokenInstruction              // var stepSpokenInstruction: String?
    case finishedSpokenInstruction      // var stepFinishedSpokenInstruction: String? 
    
    // extension NSDictionary: SBAInstructionStepSurveyItem 
    case image                          // var stepImage: UIImage? (resource name)
    case iconImage                      // var iconImage: UIImage? (resource name)
    case learnMoreAction                // func learnMoreAction() -> SBALearnMoreAction? (SBAClassTypeMap factory object)
    case learnMoreHTMLContentURL        // func learnMoreAction() -> SBALearnMoreAction? (deprecated)
    
    // extension NSDictionary: SBAFormStepSurveyItem
    case optional                       // var optional: Bool
    case items                          // var items: [Any]?
    case questionStyle                  // var shouldUseQuestionStyle: Bool
    
    // extension NSDictionary: SBASurveyRule 
    case skipIdentifier                 // var skipIdentifier: String?
    case skipIfPassed                   // var skipIfPassed: Bool
    case expectedAnswer                 // var expectedAnswer: Any?
    
    // extension NSDictionary: SBANumberRange 
    case min                            // var minNumber: NSNumber?
    case max                            // var maxNumber: NSNumber?
    case unit                           // var unitLabel: String?
    case stepInterval                   // var stepInterval: Double

}

extension NSDictionary: SBAStepTransformer {
    
    // Because an NSDictionary could be used to create both an SBASurveyItem *and* an SBAActiveTask
    // need to look to see which is the more likely form to result in a valid result.
    public func transformToStep(with factory: SBABaseSurveyFactory, isLastStep: Bool) -> ORKStep? {
        if (self.surveyItemType.isNilType()) {
            guard let subtask = self.transformToTask(with: factory, isLastStep: isLastStep) else {
                return nil
            }
            let step = SBASubtaskStep(subtask: subtask)
            step.taskIdentifier = self.taskIdentifier
            step.schemaIdentifier = self.schemaIdentifier
            return step
        }
        else {
            return factory.createSurveyStep(self)
        }
    }
}

extension NSDictionary: SBASurveyItem {
    
    public var identifier: String! {
        return (self[key(.identifier)] as? String) ?? self.schemaIdentifier
    }
    
    public var surveyItemType: SBASurveyItemType {
        if let type = self[key(.type)] as? String {
            return SBASurveyItemType(rawValue: type)
        }
        return .custom(nil)
    }
    
    public var stepTitle: String? {
        return self[key(.title)] as? String
    }
    
    public var stepText: String? {
        return (self[key(.text)] as? String) ?? (self[key(.prompt)] as? String)
    }
    
    public var stepDetail: String? {
        return self[key(.detailText)] as? String
    }
    
    public var stepFootnote: String? {
        return self[key(.footnote)] as? String
    }
    
    public var options: [String : AnyObject]? {
        return self[key(.options)] as? [String : AnyObject]
    }
}

extension NSDictionary: SBAActiveStepSurveyItem {
    
    public var stepSpokenInstruction: String? {
        return self[key(.spokenInstruction)] as? String
    }
    
    public var stepFinishedSpokenInstruction: String? {
        return self[key(.finishedSpokenInstruction)] as? String
    }
}

extension NSDictionary: SBAInstructionStepSurveyItem {
    
    public var stepImage: UIImage? {
        guard let imageNamed = self[key(.image)] as? String else { return nil }
        return SBAResourceFinder.shared.image(forResource: imageNamed)
    }
    
    public var iconImage: UIImage? {
        guard let imageNamed = self[key(.iconImage)] as? String else { return nil }
        return SBAResourceFinder.shared.image(forResource: imageNamed)
    }
    
    public func learnMoreAction() -> SBALearnMoreAction? {
        // Keep reverse-compatibility to previous dictionary key
        if let html = self[key(.learnMoreHTMLContentURL)] as? String {
            return SBAURLLearnMoreAction(identifier: html)
        }
        // Look for a dictionary that matches the learnMoreActionKey
        if let learnMoreAction = self[key(.learnMoreAction)] as? [AnyHashable: Any] {
            return SBAClassTypeMap.shared.object(with: learnMoreAction) as? SBALearnMoreAction
        }
        return nil
    }
}

extension NSDictionary: SBAFormStepSurveyItem {
    
    public var optional: Bool {
        let optional = self[key(.optional)] as? Bool
        return optional ?? false
    }
    
    public var items: [Any]? {
        return self[key(.items)] as? [Any]
    }
    
    public var range: AnyObject? {
        return self
    }
    
    public var rules: [SBASurveyRule]? {
        guard self.rulePredicate != nil || self.skipIdentifier != nil else { return nil }
        return [self]
    }
    
    public var shouldUseQuestionStyle: Bool {
        return self[key(.questionStyle)] as? Bool ?? false
    }
}

extension NSDictionary: SBASurveyRule {
    
    public var skipIdentifier: String? {
        return self[key(.skipIdentifier)] as? String
    }
    
    public var skipIfPassed: Bool {
        let skipIfPassed = self[key(.skipIfPassed)] as? Bool
        return skipIfPassed ?? false
    }
    
    public var rulePredicate: NSPredicate? {
        if let subtype = self.surveyItemType.formSubtype() {
            if case .boolean = subtype,
                let expectedAnswer = self.expectedAnswer as? Bool
            {
                return NSPredicate(format: "answer = %@", expectedAnswer as CVarArg)
            }
            else if case .singleChoice = subtype,
                let expectedAnswer = self.expectedAnswer
            {
                let answerArray = [expectedAnswer]
                return NSPredicate(format: "answer = %@", answerArray)
            }
            else if case .multipleChoice = subtype,
                let expectedAnswer = self.expectedAnswer as? [AnyObject]
            {
                return NSPredicate(format: "answer = %@", expectedAnswer)
            }
        }
        return nil;
    }
    
    public var expectedAnswer: Any? {
        return self[key(.expectedAnswer)]
    }
}

extension NSDictionary: SBANumberRange {
    
    public var minNumber: NSNumber? {
        return self[key(.min)] as? NSNumber
    }
    
    public var maxNumber: NSNumber? {
        return self[key(.max)] as? NSNumber
    }

    public var unitLabel: String? {
        return self[key(.unit)] as? String
    }

    public var stepInterval: Double {
        return self[key(.stepInterval)] as? Double ?? 1
    }
}
