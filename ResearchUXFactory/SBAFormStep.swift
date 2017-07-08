//
//  SBAFormStep.swift
//  ResearchUXFactory
//
//  Created by Josh Bruhin on 7/7/17.
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
//

import UIKit

class SBAFormStep: ORKFormStep {
    
    override func stepViewControllerClass() -> AnyClass {
        return SBAGenericStepViewController.classForCoder()
    }
}
