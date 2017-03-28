//
//  SBANameDataSource.swift
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
 The `SBANameDataSource` is used to normalize the presentation of the participant's name.
 The design of an app could require recording profile infomation with a separate field for given/family name
 or with a single field for the full name. This property can be used with either type of design.
 */
public protocol SBANameDataSource: class {
    
    /**
     This can either be the full name or the given name for the user. (First name in Western cultures)
     */
    var name: String? { get }
    
    /**
     Family name (last name in US locale)
     */
    var familyName: String? { get }
}

extension SBANameDataSource {
    
    /**
     Only return a value for the given name if the family name is non-nil. Otherwise, the name field
     is the full name and the given name cannot be parsed.
     */
    public var givenName: String? {
        return (self.familyName != nil) ? self.name : nil;
    }
    
    /**
     Join the user's given and family name as appropriate to the current locale.
     */
    public var fullName: String? {
        // If the family name is nil then it is assumed not to be used
        guard let familyName = self.familyName, let givenName = self.name else {
            return self.name
        }
        
        var components = PersonNameComponents()
        components.givenName = givenName
        components.familyName = familyName
        
        return PersonNameComponentsFormatter.localizedString(from: components, style: .default, options: [])
    }
}
