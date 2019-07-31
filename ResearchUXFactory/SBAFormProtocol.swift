//
//  SBAFormStepProtocol.swift
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
 A class that conforms to the properties of the `ORKFormStep` but does not require
 inheritance from `ORKFormStep`
 */
@objc
public protocol SBAFormStepProtocol : class {
    var identifier: String { get }
    var title: String? { get set }
    var text: String? { get set }
    var formItems: [ORKFormItem]? { get set }
    init(identifier: String)
}

extension SBAFormStepProtocol {
    
    /**
     Convenience method for finding a form item with the given identifier.
     
     @param     identifier  The identifier string for the `ORKFormItem`
     @return                The form item (if found)
    */
    public func formItem(for identifier: String) -> ORKFormItem? {
        return self.formItems?.sba_find({ $0.identifier == identifier })
    }
}

extension ORKFormStep: SBAFormStepProtocol {
}

extension ORKQuestionStep: SBAFormStepProtocol {
    
    public var formItems: [ORKFormItem]? {
        get {
            return [ORKFormItem(identifier: self.identifier, text: nil, answerFormat: self.answerFormat, optional: self.isOptional)]
        }
        set {
            self.answerFormat = newValue?.sba_find(withIdentifier: self.identifier)?.answerFormat
        }
    }
}

