//
//  Date+CurrentAgeExtension.swift
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

extension Date {
    
    /**
     Convenience method for getting the participant's age from their birthdate. This is used
     to de-identify the participant when uploading demographic information. It can also be used
     for consent and eligibility where there are age requirements.
     @return    The current age of the given birthdate
     */
    public func currentAge() -> Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.dateComponents([.year], from: self, to: Date()).year ?? 0
    }
    
    /**
     Convenience method for initializing a birthdate from the participant's age. This method assumes
     that today is the participant's birthday which should be "close enough" for any study that uses
     this method to establish demographics and eligibility based on current age.
     
     @param     currentAge  The participant's current age
     */
    public init(currentAge: Int) {
        let calendar = Calendar(identifier: .gregorian)
        let birthdate = calendar.date(byAdding: .year, value: -1 * currentAge, to: Date())
        self.init(timeIntervalSinceNow: birthdate?.timeIntervalSinceNow ?? 0)
    }
}
