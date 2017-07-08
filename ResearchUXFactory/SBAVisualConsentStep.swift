//
//  SBAVisualConsentStep.swift
//  ResearchUXFactory
//
//  Created by Josh Bruhin on 7/6/17.
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
//

import UIKit

class SBAVisualConsentStep: ORKPageStep {
    
    private var consentDocument: ORKConsentDocument!
    
    public init(identifier: String, consentDocument: ORKConsentDocument) {
        super.init(identifier: identifier, steps: SBAVisualConsentStep.instructionSteps(for: consentDocument))
    }
    
    override init(identifier: String, steps: [ORKStep]?) {
        super.init(identifier: identifier, steps: steps)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func stepViewControllerClass() -> AnyClass {
        return SBAGenericPageStepViewController.classForCoder()
    }
    
    static func instructionSteps(for consentDocument: ORKConsentDocument) -> Array<SBAInstructionStep> {
        
        var steps = Array<SBAInstructionStep>()
        for section in consentDocument.sections! {
            
            // skip the 'onlyInDocument' section
            if section.type == .onlyInDocument { continue }
            
            // we don't have a step identifier as these are consent scenes, so let's use the consent
            // title as our identifier. Would prefer to use .type enum here, but most of the sections
            // are defined with same type - custom
            
            guard let identifier = section.title else { continue }
            
            let instructionStep = SBAInstructionStep(identifier: identifier)
            instructionStep.title = section.title
            instructionStep.text = section.summary
            instructionStep.image = section.image
            
            // if there's learn more content, add an action to the instruction step with the content
            if let htmlContent = section.htmlContent {
                let action = SBAURLLearnMoreAction(identifier: identifier)
                action.learnMoreHTML = htmlContent
                instructionStep.learnMoreAction = action
            }
            
            steps.append(instructionStep)
        }
        
        return steps
    }
}
