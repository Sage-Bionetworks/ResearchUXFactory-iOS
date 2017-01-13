//
//  SBAPasswordOptions.swift
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
 Object with the options for the password form item `ORKAnswerFormat`.
 Default implementation is to create this with a dictionary with the following keys:
 
 "identifier": "password"
 "shouldConfirm": Bool
 "maximumLength": Int
 "validationRegex": String
 "invalidMessage": String
 
 @note If the "validationRegex" is defined, then the "invalidMessage" should also be defined.
 
 */
public struct SBAPasswordOptions {
    
    /**
     By default, the minimum password length is 2
     */
    public static let defaultMinLength: Int = 2
    
    /**
     By default, the maximum password length is 24
     */
    public static let defaultMaxLength: Int = 24
    
    /**
     The maximum password length. Default = `2`. Dictionary key = "maximumLength"
     */
    public let minimumLength: Int
    
    /**
     The maximum password length. Default = `24`. Dictionary key = "maximumLength"
     */
    public let maximumLength: Int
    
    /**
     The validation RegEx for the password (optional). Dictionary key = "validationRegex"
     Default = "[[:ascii:]]{`self.minimumLength`,`self.maximumLength`}"
     
     @note If the "validationRegex" is defined using a dictionary key/value pair, then the `invalidMessage` should also be defined
     */
    public let validationRegex: String
    
    /**
     The message to display if the password is invalid (optional). Dictionary key = "invalidMessage"
     */
    public let invalidMessage: String
    
    /**
     Should the password be confirmed. Default = `YES`. Dictionary key = "shouldConfirm"
    */
    public let shouldConfirm: Bool

    public init(options: [String : AnyObject]? = nil) {
        self.init(validationRegex: options?["validationRegex"] as? String,
                  invalidMessage: options?["invalidMessage"] as? String,
                  maximumLength: options?["maximumLength"] as? Int,
                  minimumLength: options?["minimumLength"] as? Int,
                  shouldConfirm: options?["shouldConfirm"] as? Bool)
    }
    
    public init(validationRegex: String?, invalidMessage: String?, maximumLength: Int?, minimumLength: Int?, shouldConfirm: Bool?) {

        self.maximumLength = maximumLength ?? SBAPasswordOptions.defaultMaxLength
        self.minimumLength = minimumLength ?? SBAPasswordOptions.defaultMinLength
        self.shouldConfirm = shouldConfirm ?? true
        
        // Validation must be defined for both the RegEx and the message
        // or else use the default
        if (validationRegex != nil) && (invalidMessage != nil) {
            self.validationRegex = validationRegex!
            self.invalidMessage = invalidMessage!
        }
        else {
            // If this is a registration, go ahead and set the default password verification
            self.validationRegex = "[[:ascii:]]{\(self.minimumLength),\(self.maximumLength)}"
            self.invalidMessage = Localization.localizedStringWithFormatKey("SBA_REGISTRATION_INVALID_PASSWORD_LENGTH_%@_TO_%@", NSNumber(value: self.minimumLength), NSNumber(value: self.maximumLength))
        }
    }
    
}
