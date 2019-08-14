//
//  SBAQuizStep.swift
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

public protocol SBAPredicateNavigationStep: class {
    
    /**
     The rules that map to this navigation step.
    */
    var rules: [SBASurveyRule]? { get set }
    
    /**
     An identifier to skip to if any of the rules fail.
     */
    var failedSkipIdentifier: String? { get set }
    
    /**
     Predicate to use for getting the matching step results
    */
    var surveyStepResultFilterPredicate: NSPredicate { get }
}

public protocol SBASurveyNavigationStep: SBAPredicateNavigationStep, SBANavigationRule {
    
    /**
     Form step that matches with the given result
    */
    func matchingSurveyStep(for stepResult: ORKStepResult) -> SBAFormStepProtocol?
}

public extension SBASurveyNavigationStep {
    
    func nextStepIdentifier(with taskResult: ORKTaskResult, and additionalTaskResults:[ORKTaskResult]?) -> String? {
        
        guard rules != nil else { return nil }
        
        // Filter out the rules that match
        let results = taskResult.consolidatedResults()
        guard results.count > 0 else { return nil }
        let predicate = self.surveyStepResultFilterPredicate
        let matchingRules = results.sba_mapAndFilter ({ (stepResult) -> [SBASurveyRule]? in
    
            // Look to see if this step result matches a step for this navigation rule
            guard predicate.evaluate(with: stepResult),
                let step = self.matchingSurveyStep(for: stepResult)
            else {
                return nil
            }
            
            // Look for rules that map to the form items
            return step.formItems?.sba_mapAndFilter({ matchingRule(formItem: $0, stepResult: stepResult) })
            
        }).flatMap({ $0 })
        
        // If this navigation has a failed skip identifier then the rules are simplier, instead of 
        // looking at the skipIdentifiers, just check to see if the counts match. If they do not, 
        // then return the failed skip identifier.
        if self.failedSkipIdentifier != nil {
            return (matchingRules.count != self.rules!.count) ? self.failedSkipIdentifier : nil
        }

        // If the returned rules have multiple skip identifiers then a unique skip rule wasn't found
        guard let skipIdentifier = matchingRules.first?.skipIdentifier else { return nil }
        for rule in matchingRules {
            if rule.skipIdentifier != skipIdentifier {
                return nil
            }
        }
        
        // If the count of the skipIdentifiers doesn't match the count of the returned rules, then 
        // not all answers match.
        guard matchingRules.count == self.rules!.filter({ $0.skipIdentifier == skipIdentifier }).count else {
            return nil
        }
        
        // If we have a match, then return nil if there is a failed skip identifier
        return skipIdentifier;
    }
    
    func matchingRule(formItem: ORKFormItem, stepResult: ORKStepResult) -> SBASurveyRule? {
        guard let rules = self.rules else { return nil }
        let result = stepResult.result(forIdentifier: formItem.identifier)
        for rule in rules {
            if rule.resultIdentifier == formItem.identifier,
                let predicate = rule.rulePredicate, predicate.evaluate(with: result) {
                return rule
            }
        }
        return nil
    }
    
    func sharedCopying(_ copy: Any) -> Any {
        guard let step = copy as? SBASurveyNavigationStep else { return copy }
        step.rules = self.rules
        step.failedSkipIdentifier = self.failedSkipIdentifier
        if let learnItem = self as? SBALearnMoreActionStep,
            let learnStep = step as? SBALearnMoreActionStep {
            learnStep.learnMoreAction = learnItem.learnMoreAction
        }
        return step
    }
    
    func sharedDecoding(coder aDecoder: NSCoder) {
        self.rules = aDecoder.decodeObject(forKey: "rules") as? [SBASurveyRule]
        self.failedSkipIdentifier = aDecoder.decodeObject(forKey: "failedSkipIdentifier") as? String
        if let learnStep = self as? SBALearnMoreActionStep {
            learnStep.learnMoreAction = aDecoder.decodeObject(forKey: "learnMoreAction") as? SBALearnMoreAction
        }
    }
    
    func sharedEncoding(_ aCoder: NSCoder) {
        aCoder.encode(self.rules, forKey: "rules")
        aCoder.encode(self.failedSkipIdentifier, forKey: "failedSkipIdentifier")
        if let learnStep = self as? SBALearnMoreActionStep {
            aCoder.encode(learnStep.learnMoreAction, forKey: "learnMoreAction")
        }
    }
    
    func sharedCopyFromSurveyItem(_ surveyItem: Any) {
        guard let ruleGroup = surveyItem as? SBASurveyRuleGroup else { return }
        self.rules = ruleGroup.createSurveyRuleObjects()
        self.failedSkipIdentifier = ruleGroup.skipIfPassed ? nil : (ruleGroup.skipIdentifier ?? ORKNullStepIdentifier)
        if let learnItem = surveyItem as? SBALearnMoreActionItem,
            let learnStep = self as? SBALearnMoreActionStep {
            learnStep.learnMoreAction = learnItem.learnMoreAction()
        }
    }
    
    func sharedHash() -> Int {
        var hash = SBAObjectHash(self.rules) ^ SBAObjectHash(self.failedSkipIdentifier)
        if let learnStep = self as? SBALearnMoreActionStep {
            hash = hash ^ SBAObjectHash(learnStep.learnMoreAction)
        }
        return hash
    }
    
    func sharedEquality(_ object: Any?) -> Bool {
        guard let object = object as? SBASurveyNavigationStep else { return false }
        var same = SBAObjectEquality(self.rules, object.rules) &&
            SBAObjectEquality(self.failedSkipIdentifier, object.failedSkipIdentifier)
        if let learnStep = self as? SBALearnMoreActionStep, let other = object as? SBALearnMoreActionStep {
            same = same && SBAObjectEquality(learnStep.learnMoreAction, other.learnMoreAction)
        }
        return same
    }
}
