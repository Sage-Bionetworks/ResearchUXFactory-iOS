//
//  SBADataGroupsStep.swift
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

import UIKit

public protocol SBADataGroupsStepProtocol: class {
    
    var identifier: String { get }
    
    /**
     The subset of data groups that are selected/deselected using this step.
     */
    var dataGroups: Set<String> { get }
    
    /**
     Create an `ORKStepResult` from the given set of data groups.
     @return    Step result for this step.
     */
    func stepResult(currentGroups: [String]?) -> ORKStepResult?
    
    /**
     For the given step result, what are the selected data groups?
     @return    The data groups that apply to this step result.
     */
    func selectedDataGroups(with stepResult: ORKStepResult) -> [String]
}

public protocol SBADataGroupsChoiceStepProtocol: SBADataGroupsStepProtocol {
    
    /**
     `ORKTextChoiceAnswerFormat` and `ORKImageChoiceAnswerFormat` do not have a common superclass
     that includes the value stored as the answer to the choice. This protocol allows the classes
     to implement common behavior.
     */
    var choiceAnswerFormat: SBAChoiceAnswerFormatProtocol? { get }
}

open class SBADataGroupsStep: SBANavigationFormStep, SBADataGroupsChoiceStepProtocol {
    
    public override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    public override init(inputItem: SBASurveyItem) {
        super.init(inputItem: inputItem)
        guard let surveyForm = inputItem as? SBAFormStepSurveyItem else {
            return
        }
        
        // map the values
        surveyForm.mapStepValues(with: self)
        let subtype: SBASurveyItemType.FormSubtype = inputItem.surveyItemType.formSubtype() ?? .multipleChoice
        self.formItems = [surveyForm.createFormItem(text: nil, subtype: subtype)]
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open var choiceAnswerFormat: SBAChoiceAnswerFormatProtocol? {
        return self.formItems?.first?.answerFormat as? SBAChoiceAnswerFormatProtocol
    }
}

extension SBADataGroupsChoiceStepProtocol {
    
    public var dataGroups: Set<String> {
        guard let answerFormat = self.choiceAnswerFormat else {
            return []
        }
        let dataGroups = answerFormat.choices.reduce(Set<String>()) { $0.union($1.choiceDataGroups) }
        return dataGroups
    }
    
    public func selectedDataGroups(with stepResult: ORKStepResult) -> [String] {
        let questionResult = stepResult.results?.first as? ORKChoiceQuestionResult
        let choiceAnswers = (questionResult?.choiceAnswers ?? []) as NSArray
        let selectedGroups: [String] = self.choiceAnswerFormat?.choices.sba_mapAndFilter({ (choice) -> [String]? in
            let value = choice.choiceValue
            choiceAnswers.contains(value)
            guard choiceAnswers.contains(value) else { return nil }
            return choice.choiceDataGroups
        }).flatMap({ $0 }) ?? []
        return selectedGroups
    }
    
    public func stepResult(currentGroups: [String]?) -> ORKStepResult? {
        
        // The results can only be built from the current data groups if the values
        // and the data groups are the same
        guard choiceValueMatchesDataGroups() else { return nil }
        
        // Look for a current choice from the input groups
        let currentChoices: [Any]? = {
            // Check that the current group is non-nil
            guard currentGroups != nil, let answerFormat = self.choiceAnswerFormat
            else {
                return nil
            }
            // Create the intersection set that is the values from the current group that are in this steps subset of data groups
            let currentSet = Set(currentGroups!).intersection(self.dataGroups)
            // If there is no overlap then return nil
            guard currentSet.count > 0 else { return nil }
            // Otherwise, look for an answer that maps to the current set
            return answerFormat.choices.sba_mapAndFilter({ (choice) -> Any? in
                let value = Set(choice.convertValueToArray())
                guard value.count > 0, currentSet.intersection(value) == value else { return nil }
                return choice.choiceValue
            })
        }()
        
        // If nothing is found then return a nil results set
        guard currentChoices != nil else {
            return ORKStepResult(stepIdentifier: self.identifier, results: nil)
        }
        
        // If found, then create a questionResult for that choice
        let questionResult = ORKChoiceQuestionResult(identifier: self.identifier)
        questionResult.choiceAnswers = currentChoices
        return ORKStepResult(stepIdentifier: self.identifier, results: [questionResult])
    }
    
    func choiceValueMatchesDataGroups() -> Bool {
        return self.choiceAnswerFormat?.choices.reduce(true, { (input, choice) -> Bool in
            return input && choice.choiceValueMatchesDataGroups()
        }) ?? false
    }
}

extension SBADataGroupsStepProtocol {

    /**
     Return the union/minus set that includes the data groups from the current set of data groups
     that are *not* edited in this step unioned with the new data groups that are selected values
     for this step. For example, if this step is used to select either "groupA" OR "groupB" and 
     the current data groups are "test_user" and "groupA", then the returned groups will include
     "test_user" AND whichever group has been selected via the step result.
     
     @param  previousGroups The current data groups set
     @param  stepResult     The step result to use to get the new selection
     @return                The set of data groups based on the current and step result
     */
    public func union(previousGroups: [String]?, stepResult: ORKStepResult) -> Set<String> {
        let previous = Set(previousGroups ?? [])
        return unionSet(previous: previous, with: stepResult)
    }
    
    fileprivate func unionSet(previous previousGroups: Set<String>, with stepResult: ORKStepResult) -> Set<String> {

        let choices = selectedDataGroups(with: stepResult)
        
        // Create a set with only the groups that are *not* selected as a part of this step
        let minusSet = previousGroups.subtracting(self.dataGroups)
        
        // And the union that minus set with the new choices
        return minusSet.union(choices)
    }
}

extension ORKTask {
    
    /**
     Union the current data groups with the task result to get the new data groups and whether or not they have changed.
     @param currentGroups   List of the current data groups
     @param taskResult      The task result for this run of the task
     @return                dataGroups: New unioned data groups, changed: whether or not the data groups have changed.
    */
    public func union(currentGroups: [String]?, with taskResult: ORKTaskResult) -> (dataGroups: [String]?, changed: Bool)  {
        let previousGroups: Set<String> = Set(currentGroups ?? [])
        let groups = recursiveUnionDataGroups(previousGroups: previousGroups, taskResult: taskResult)
        let changed = (groups != previousGroups)
        return (changed ? Array(groups) : currentGroups, changed)
    }
    
    // recursively search for a data group step
    fileprivate func recursiveUnionDataGroups(previousGroups: Set<String>, taskResult: ORKTaskResult) -> Set<String> {
        guard let navTask = self as? ORKOrderedTask else { return previousGroups }
        var dataGroups = previousGroups
        for step in navTask.steps {
            if let dataGroupsStep = step as? SBADataGroupsStepProtocol,
                let result = taskResult.stepResult(forStepIdentifier: dataGroupsStep.identifier) {
                dataGroups = dataGroupsStep.unionSet(previous: dataGroups, with: result)
            }
            else if let subtaskStep = step as? SBASubtaskStep {
                let subtaskResult = ORKTaskResult(identifier: subtaskStep.subtask.identifier)
                let (subResults, _) = subtaskStep.filteredStepResults(taskResult.results as! [ORKStepResult])
                subtaskResult.results = subResults
                dataGroups = subtaskStep.subtask.recursiveUnionDataGroups(previousGroups: dataGroups, taskResult: subtaskResult)
            }
        }
        return dataGroups
    }
    
}
