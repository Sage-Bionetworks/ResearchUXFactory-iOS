//
//  SBANavigationFormStep.swift
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
 `SBANavigationFormStep` is an implementation of the `SBASurveyNavigationStep`
 that implements the rules for an `ORKFormStep`
 */
public class SBANavigationFormStep: ORKFormStep, SBASurveyNavigationStep {
    
    public var surveyStepResultFilterPredicate: NSPredicate {
        return NSPredicate(format: "%K = %@", #keyPath(identifier), self.identifier)
    }
    
    public func matchingSurveyStep(for stepResult: ORKStepResult) -> SBAFormStepProtocol? {
        guard (stepResult.identifier == self.identifier) else { return nil }
        return self
    }
    
    // MARK: Stuff you can't extend on a protocol
    
    public var rules: [SBASurveyRule]?
    public var failedSkipIdentifier: String?
    
    override public init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    init(inputItem: SBASurveyItem) {
        super.init(identifier: inputItem.identifier)
        self.sharedCopyFromSurveyItem(inputItem)
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone)
        return self.sharedCopying(copy)
    }
    
    // MARK: NSSecureCoding
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.sharedDecoding(coder: aDecoder)
    }
    
    override public func encode(with aCoder: NSCoder){
        super.encode(with: aCoder)
        self.sharedEncoding(aCoder)
    }
    
    // MARK: Equality
    
    override public func isEqual(_ object: Any?) -> Bool {
        return super.isEqual(object) && sharedEquality(object)
    }
    
    override public var hash: Int {
        return super.hash ^ sharedHash()
    }
}
