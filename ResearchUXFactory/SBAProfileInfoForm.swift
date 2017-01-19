//
//  SBARegistrationForm.swift
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

/**
 Protocol for extending all the profile info steps (used by the factory to create the
 appropriate default form items).
 */
public protocol SBAProfileInfoForm: SBAFormProtocol {
    
    /**
     Used in common initialization to get the default options if the included options are nil.
     */
    func defaultOptions(_ inputItem: SBASurveyItem?) -> [SBAProfileInfoOption]
}

/**
 Shared factory methods for creating profile form steps.
 */
extension SBAProfileInfoForm {
    
    public var options: [SBAProfileInfoOption]? {
        return self.formItems?.mapAndFilter({ SBAProfileInfoOption(rawValue: $0.identifier) })
    }
    
    public func formItemForProfileInfoOption(_ profileInfoOption: SBAProfileInfoOption) -> ORKFormItem? {
        return self.formItems?.find({ $0.identifier == profileInfoOption.rawValue })
    }
    
    public func commonInit(inputItem: SBASurveyItem?, factory: SBABaseSurveyFactory?) {
        self.title = inputItem?.stepTitle
        self.text = inputItem?.stepText
        if let formStep = self as? ORKFormStep {
            formStep.footnote = inputItem?.stepFootnote
        }
        let options = SBAProfileInfoOptions(inputItem: inputItem, defaultIncludes: defaultOptions(inputItem))
        self.formItems = options.makeFormItems(factory: factory)
    }
}


