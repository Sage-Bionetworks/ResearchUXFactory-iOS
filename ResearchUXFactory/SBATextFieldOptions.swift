//
//  SBATextFieldOptions.swift
//  ResearchUXFactory
//
//  Created by Shannon Young on 5/19/17.
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
 Object with the options for the text field form item `ORKAnswerFormat`.
 Default implementation is to create this with a dictionary with the following keys:å
 
 @note If the "validationRegex" is defined, then the "invalidMessage" should also be defined.
 
 */
open class SBATextFieldOptions: SBADataObject, SBATextFieldRange {
    
    @objc public dynamic var validationRegex: String?
    
    @objc public dynamic var invalidMessage: String?
    
    @objc public dynamic var maximumLength: Int = 0
    
    @objc public dynamic var minimumLength: Int = 0
    
    @objc public dynamic var autocapitalizationType: UITextAutocapitalizationType = .none
    
    @objc public dynamic var keyboardType: UIKeyboardType = .default
    
    @objc public dynamic var shouldConfirm: Bool = false
    
    override open func dictionaryRepresentationKeys() -> [String] {
        return super.dictionaryRepresentationKeys().appending(contentsOf:[#keyPath(maximumLength),
                                                                          #keyPath(minimumLength),
                                                                          #keyPath(validationRegex),
                                                                          #keyPath(invalidMessage),
                                                                          #keyPath(autocapitalizationType),
                                                                          #keyPath(keyboardType),
                                                                          #keyPath(shouldConfirm)])
    }
    
    override open func mapValue(_ value: Any?, forKey key: String, withClassType classType: String?) -> Any? {
        if key == #keyPath(autocapitalizationType), let name = value as? String {
            return UITextAutocapitalizationType(key: name).rawValue
        }
        else if key == #keyPath(keyboardType), let name = value as? String {
            return UIKeyboardType(key: name).rawValue
        }
        return super.mapValue(value, forKey: key, withClassType: classType)
    }
    
    override open func defaultValue(forKey key: String) -> Any? {
        if key == #keyPath(validationRegex), self.minimumLength > 0, self.maximumLength > 0 {
            return "[[:ascii:]]{\(self.minimumLength),\(self.maximumLength)}"
        }
        else if key == #keyPath(invalidMessage), self.minimumLength > 0, self.maximumLength > 0 {
            return Localization.localizedStringWithFormatKey("SBA_REGISTRATION_INVALID_PASSWORD_LENGTH_%@_TO_%@",
                                                             NSNumber(value: self.minimumLength),
                                                             NSNumber(value: self.maximumLength))
        }
        else if key == #keyPath(shouldConfirm) {
            return true
        }
        return super.defaultValue(forKey: key)
    }
    
}

public class SBAPasswordOptions: SBATextFieldOptions {
    
    /**
     By default, the minimum password length is 8
     */
    public static let defaultMinLength: Int = 8
    
    /**
     By default, the maximum password length is 24
     */
    public static let defaultMaxLength: Int = 24
    
    public override var autocapitalizationType: UITextAutocapitalizationType {
        get { return .none }
        set {}
    }
    
    override public func defaultValue(forKey key: String) -> Any? {
        if key == #keyPath(minimumLength) {
            return SBAPasswordOptions.defaultMinLength
        }
        else if key == #keyPath(maximumLength) {
            return SBAPasswordOptions.defaultMaxLength
        }
        else if key == #keyPath(shouldConfirm) {
            return true
        }
        return super.defaultValue(forKey: key)
    }
}

public class SBAExternalIDOptions: SBATextFieldOptions {
    
    /**
     By default, the autocapitalization type is all characters
     */
    public static let defaultAutocapitalizationType: UITextAutocapitalizationType = .allCharacters
    
    /**
     By default, the keyboard type is ASCII
     */
    public static let defaultKeyboardType: UIKeyboardType = .asciiCapable
    
    override public func defaultValue(forKey key: String) -> Any? {
        if key == #keyPath(autocapitalizationType) {
            return SBAExternalIDOptions.defaultAutocapitalizationType.rawValue
        }
        else if key == #keyPath(keyboardType) {
            return SBAExternalIDOptions.defaultKeyboardType.rawValue
        }
        return super.defaultValue(forKey: key)
    }
}
