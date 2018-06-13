//
//  SBAInstructionStep.swift
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

@objc
open class SBAInstructionStep: ORKInstructionStep, SBADirectNavigationRule, SBACustomTypeStep, SBALearnMoreActionStep {
    
    /**
    * For cases where this type of step is created as a placeholder for a custom step.
    */
    open var customTypeIdentifier: String?
    
    /**
     * Pointer to the next step to show after this one. If nil, then the next step
     * is determined by the navigation rules setup by SBANavigableOrderedTask.
     */
    open var nextStepIdentifier: String?
    
    /**
     * HTML Content for the "learn more" for this step
     */
    @available(*, deprecated, message: "use learnMoreAction: instead")
    open var learnMoreHTMLContent: String? {
        guard let learnMore = self.learnMoreAction?.identifier else {
            return nil
        }
        return SBAResourceFinder.shared.html(forResource: learnMore)
    }
    
    /**
    * Indicates whether or not this step should use the completion step animation.
    */
    open var isCompletionStep: Bool = false
    
    /**
     * The learn more action for this step
     */
    open var learnMoreAction: SBALearnMoreAction?
    
    /**
     * Custom text for the continue button.
     */
    open var continueButtonTitle: String?
    
    /**
     * Name of a .mp3 resource file to play when the step is shown.
     */
    open var startStepAudio: String?
    
    public override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    public init(inputItem: SBASurveyItem) {
        super.init(identifier: inputItem.identifier)
        
        self.title = inputItem.stepTitle?.trim()
        self.text = inputItem.stepText?.trim()
        self.footnote = inputItem.stepFootnote?.trim()
        
        if let directStep = inputItem as? SBADirectNavigationRule {
            self.nextStepIdentifier = directStep.nextStepIdentifier
        }
        
        if case SBASurveyItemType.custom(let customType) = inputItem.surveyItemType {
            self.customTypeIdentifier = customType
        }
        
        self.isCompletionStep = (inputItem.surveyItemType == .instruction(.completion))
        
        if let surveyItem = inputItem as? SBAInstructionStepSurveyItem {
            self.learnMoreAction = surveyItem.learnMoreAction()
            self.detailText = surveyItem.stepDetail?.trim()
            self.image = surveyItem.stepImage
            self.iconImage = surveyItem.iconImage
        }
        
        if let dictionary = inputItem as? NSDictionary {
            let continueButtonTitleKey = #keyPath(continueButtonTitle)
            self.continueButtonTitle = dictionary[continueButtonTitleKey] as? String
            
            let startStepAudioKey = #keyPath(startStepAudio)
            self.startStepAudio = dictionary[startStepAudioKey] as? String
        }
    }
    
    open override func stepViewControllerClass() -> AnyClass {
        // If this is a completion step, then use ORKCompletionStepViewController 
        // unless this is class has an image, in which case ORKCompletionStepViewController
        // will not display that image so use the super class implementation.
        if self.isCompletionStep && self.image == nil {
            return ORKCompletionStepViewController.classForCoder()
        }
        else {
            return ORKInstructionStepViewController.classForCoder()
        }
    }
    
    // MARK: NSCopy
    
    override open func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone)
        guard let step = copy as? SBAInstructionStep else { return copy }
        step.nextStepIdentifier = self.nextStepIdentifier
        step.learnMoreAction = self.learnMoreAction
        step.customTypeIdentifier = self.customTypeIdentifier
        step.isCompletionStep = self.isCompletionStep
        step.continueButtonTitle = self.continueButtonTitle
        step.startStepAudio = self.startStepAudio
        return step
    }
    
    // MARK: NSCoding
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.nextStepIdentifier = aDecoder.decodeObject(forKey: #keyPath(nextStepIdentifier)) as? String
        self.learnMoreAction = aDecoder.decodeObject(forKey: #keyPath(learnMoreAction)) as? SBALearnMoreAction
        self.customTypeIdentifier = aDecoder.decodeObject(forKey: #keyPath(customTypeIdentifier)) as? String
        self.isCompletionStep = aDecoder.decodeBool(forKey: #keyPath(isCompletionStep))
        self.continueButtonTitle = aDecoder.decodeObject(forKey: #keyPath(continueButtonTitle)) as? String
        self.startStepAudio = aDecoder.decodeObject(forKey: #keyPath(startStepAudio)) as? String
    }
    
    override open func encode(with aCoder: NSCoder){
        super.encode(with: aCoder)
        aCoder.encode(self.nextStepIdentifier, forKey: #keyPath(nextStepIdentifier))
        aCoder.encode(self.learnMoreAction, forKey: #keyPath(learnMoreAction))
        aCoder.encode(self.customTypeIdentifier, forKey: #keyPath(customTypeIdentifier))
        aCoder.encode(self.isCompletionStep, forKey: #keyPath(isCompletionStep))
        aCoder.encode(self.continueButtonTitle, forKey: #keyPath(continueButtonTitle))
        aCoder.encode(self.startStepAudio, forKey: #keyPath(startStepAudio))
    }
    
    // MARK: Equality
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? SBAInstructionStep else { return false }
        return super.isEqual(object) &&
            SBAObjectEquality(self.nextStepIdentifier, object.nextStepIdentifier) &&
            SBAObjectEquality(self.learnMoreAction, object.learnMoreAction) &&
            SBAObjectEquality(self.customTypeIdentifier, object.customTypeIdentifier) &&
            SBAObjectEquality(self.continueButtonTitle, object.continueButtonTitle) &&
            SBAObjectEquality(self.startStepAudio, object.startStepAudio) &&
            (self.isCompletionStep == object.isCompletionStep)
    }
    
    override open var hash: Int {
        return super.hash ^
            SBAObjectHash(self.nextStepIdentifier) ^
            SBAObjectHash(learnMoreAction) ^
            SBAObjectHash(self.customTypeIdentifier) ^
            SBAObjectHash(self.continueButtonTitle) ^
            SBAObjectHash(self.startStepAudio) ^
            self.isCompletionStep.hashValue
    }
}
