//
//  SBASurveyRule.swift
//  ResearchUXFactory
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

import Foundation

/**
 The `SBASurveyRule` defines an identifier to skip to and a rule predicate for that step.
 The predicate will only be tested against the owning step. The rules are used to build the
 appropriate step class that implements the `SBANavigationRule` protocol.
 */
public protocol SBASurveyRule : NSSecureCoding {
    
    /**
     Identifier for the matching `ORKResult`
    */
    var resultIdentifier: String { get }
    
    /**
     Identifier for the step to skip to.
     */
    var skipIdentifier: String! { get }
    
    /**
     A rule predicate to use to test the `ORKResult`.
     */
    var rulePredicate: NSPredicate! { get }
}

/**
 List of rules creating the survey rule items.
 */
public enum SBASurveyRuleOperator: String {
    case skip               = "de"
    case equal              = "eq"
    case notEqual           = "ne"
    case lessThan           = "lt"
    case greaterThan        = "gt"
    case lessThanEqual      = "le"
    case greaterThanEqual   = "ge"
    case otherThan          = "ot"
}

/**
 A rule item that can be used to create an `SBASurveyRule`
 */
public protocol SBASurveyRuleItem: class {
    
    /**
     Optional value for the form subtype. If available, this will be used to create the `rulePredicate`.
    */
    var formSubtype:SBASurveyItemType.FormSubtype? { get }
    
    /**
     Optional result identifier associated with this rule. If available, this will be used to create the `rulePredicate`.
     */
    var resultIdentifier: String? { get }
    
    /**
     Optional skip identifier for this rule. If available, this will be used as the skip identifier, otherwise
     the skipIdentifier on the `SBASurveyRuleGroup` will be used.
    */
    var skipIdentifier: String? { get }
    
    /**
     Expected answer for the rule. If nil, then the operator must be .skip or this will return a nil value.
    */
    var expectedAnswer: Any? { get }
    
    /**
     The rule operator to apply. If nil, `.equal` will be assumed unless the `expectedAnswer` is also nil,
     in which case skip will be assumed.
    */
    var ruleOperator: SBASurveyRuleOperator? { get }
}

extension SBASurveyRuleItem {
    
    func rulePredicate(with subtype: SBASurveyItemType.FormSubtype) -> NSPredicate? {
        
        // Exit early if operator or value are unsupported
        let (valid, value, op) = convertValueAndOperator(with: subtype)
        guard valid else { return nil }
        
        // For the case where the answer format is a choice, then the answer
        // is returned as an array of choices
        let isArray = (subtype == .singleChoice) || (subtype == .multipleChoice)
        
        switch(op) {
        case .skip:
            return NSPredicate(format: "answer = NULL")
        case .equal:
            return NSPredicate(format: "answer = %@", value!)
        case .notEqual:
            return NSPredicate(format: "answer <> %@", value!)
        case .otherThan:
            if (isArray) {
                return NSCompoundPredicate(notPredicateWithSubpredicate:
                    NSPredicate(format: "%@ IN answer", value!))
            }
            else {
                return NSPredicate(format: "answer <> %@", value!)
            }
        case .greaterThan:
            return NSPredicate(format: "answer > %@", value!)
        case .greaterThanEqual:
            return NSPredicate(format: "answer >= %@", value!)
        case .lessThan:
            return NSPredicate(format: "answer < %@", value!)
        case .lessThanEqual:
            return NSPredicate(format: "answer <= %@", value!)
        }
    }
    
    func convertValueAndOperator(with subtype: SBASurveyItemType.FormSubtype) -> (valid:Bool, value:CVarArg?, op:SBASurveyRuleOperator) {
        
        // Exit early if operator or value are unsupported
        let value = self.expectedAnswer as? NSObject
        let op: SBASurveyRuleOperator = self.ruleOperator ?? ((value == nil) ? .skip : .equal)
        guard (value != nil) || (op == .skip)
            else {
                assertionFailure("Unsupported operator: \(op) OR expectedAnswer: \(value)")
                return (false, nil, .skip)
        }
        
        // Exit early if this is a skip operation
        guard op != .skip else {
            return (true, nil, op)
        }
        
        // For the case where the answer format is a choice, then the answer
        // is returned as an array of choices
        switch(subtype) {
        case .singleChoice, .multipleChoice, .timingRange:
            if op == .otherThan {
                return (true, value, op)
            } else {
                return (true, [value!], op)
            }
            
        case .boolean, .toggle:
            guard let answer = value as? Bool ?? (value as? NSString)?.boolValue else {
                assertionFailure("Unsupported operator: \(op) OR expectedAnswer: \(value) for \(subtype)")
                return (false, nil, .skip)
            }
            return (true, NSNumber(value: answer), op)
            
        case .scale, .integer:
            guard let answer = value as? Int ?? (value as? NSString)?.integerValue else {
                assertionFailure("Unsupported operator: \(op) OR expectedAnswer: \(value) for \(subtype)")
                return (false, nil, .skip)
            }
            return (true, NSNumber(value: answer), op)
            
        case .continuousScale, .decimal, .duration:
            guard let answer = value as? Double ?? (value as? NSString)?.doubleValue else {
                assertionFailure("Unsupported operator: \(op) OR expectedAnswer: \(value) for \(subtype)")
                return (false, nil, .skip)
            }
            return (true, NSNumber(value: answer), op)
        
        case .date, .dateTime:
            guard let answer = (value as? Date) ?? (value as? NSString)?.dateValue else {
                assertionFailure("Unsupported operator: \(op) OR expectedAnswer: \(value) for \(subtype)")
                return (false, nil, .skip)
            }
            return (true, answer as NSDate, op)
            
        case .time:
            guard let answer = (value as? DateComponents) ?? (value as? NSString)?.timeValue else {
                assertionFailure("Unsupported operator: \(op) OR expectedAnswer: \(value) for \(subtype)")
                return (false, nil, .skip)
            }
            return (true, answer as NSDateComponents, op)
        
        default:
            return (true, value, op)
        }
    }
}

/**
 Optional protocol extension for `SBAFormStepSurveyItem`. If implemented, this can be used
 to assign rules to an `ORKStep` subclass that implements navigation rules.
 */
public protocol SBASurveyRuleGroup: SBAFormStepSurveyItem {
    
    /**
     An identifier to skip to. This identifier will be used if the `SBASurveyRuleItem`
     does not define a `skipIdentifier` specific to a single rule.
    */
    var skipIdentifier: String? { get }
    
    /**
     Should the rule set skip if passed? If `NO` then 
     `SBAPredicateNavigationStep.failedSkipIdentifier = skipIdentifier ?? ORKNullStepIdentifier`
    */
    var skipIfPassed: Bool { get }
    
    /**
     A list of rules.
    */
    var rules: [SBASurveyRuleItem]? { get }
    
    /**
     Are there any active navigation rules?
    */
    func hasNavigationRules() -> Bool
}

extension SBASurveyRuleGroup {
    
    /**
     Factory method for creating a set of survey rule objects.
    */
    public func createSurveyRuleObjects() -> [SBASurveyRuleObject]? {
        
        guard let surveyRules = self.rules else { return nil }
        
        // Get the subtype of the group
        let groupSubtype = self.surveyItemType.formSubtype()
        
        // build a mapping of rules objects, combining for the case where the 
        // skip identifier and the result identifier are the same because in that case
        // only one of the rules needs to match
        var rulesMap: [String:[SBASurveyRuleObject]] = [:]
        for rule in surveyRules {
            
            let ruleObject: SBASurveyRuleObject? = {
            
                // Need a valid Form subtype and identifier and rule predicate
                guard let subtype = rule.formSubtype ?? groupSubtype,
                    let identifier = rule.resultIdentifier ?? self.identifier,
                    let rulePredicate = rule.rulePredicate(with: subtype)
                else {
                    return nil
                }
                
                let skipIdentifier = rule.skipIdentifier ?? self.skipIdentifier ?? ORKNullStepIdentifier
                let ruleObject = SBASurveyRuleObject(identifier: identifier)
                ruleObject.skipIdentifier = skipIdentifier
                ruleObject.rulePredicate = rulePredicate
                
                return ruleObject
            }()
            if let ruleObject = ruleObject {
                let key = "\(ruleObject.resultIdentifier).\(ruleObject.skipIdentifier!)"
                let subgroup: [SBASurveyRuleObject] = rulesMap[key] ?? []
                rulesMap[key] = subgroup.appending(ruleObject)
            }
        }

        // reduce the rules for each result identifier with the same skip identifier to a single OR predicate
        let rules = rulesMap.map { (kv: (_: String, value: [SBASurveyRuleObject])) -> SBASurveyRuleObject in
            let rule = kv.value.first!
            if (kv.value.count > 1) {
                let predicates: [NSPredicate] = kv.value.map({ $0.rulePredicate })
                rule.rulePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
            }
            return rule
        }
        return rules
    }
}

/**
 The `SBASurveyRuleObject` provides a concrete implementation of the `SBASurveyRule`
 */
public class SBASurveyRuleObject: SBADataObject, SBASurveyRule {
    
    public var resultIdentifier: String {
        return self.identifier
    }
    
    public dynamic var skipIdentifier: String!
    public dynamic var rulePredicate: NSPredicate!
    
    override open func dictionaryRepresentationKeys() -> [String] {
        return super.dictionaryRepresentationKeys().appending(contentsOf: [#keyPath(skipIdentifier), #keyPath(rulePredicate)])
    }
}


