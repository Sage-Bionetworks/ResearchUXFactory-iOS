//
//  SBAInfoManager.swift
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
 This protocol is used as the mapping for information used to customize the study.
 The default implementation maps each key using the property name to a value 
 defined in a plist dictionary included in the app resource bundle.

 See `BridgeInfo.plist` in the Shared SampleApp Resources included in this project
 for an example.
 */
@objc
public protocol SBASharedAppInfo: class {
    
    /**
     The Logo image to use for this app.
     */
    var logoImageName: String? { get }
    
    /**
     Array of objects that can be converted into `SBAPermissionObjectType` objects.
     */
    var permissionTypeItems: [Any]? { get }
    
    /**
     Keychain service name.
     */
    var keychainService: String? { get }
    
    /**
     Keychain access group name.
     */
    var keychainAccessGroup: String? { get }
    
    /**
     App group identifier used for the suite name of NSUserDefaults (if provided).
     */
    var appGroupIdentifier: String? { get }
}

extension SBAInfoManager {
    
    public static var shared: SBAInfoManager {
        return __shared()
    }
}

extension SBAInfoManager: SBASharedAppInfo {
    
    public var logoImageName: String? {
        return string(for:"logoImageName")
    }
    
    public var permissionTypeItems: [Any]? {
        return self.plist["permissionTypes"] as? [Any]
    }
    
    public var keychainService: String? {
        return string(for:"keychainService")
    }
    
    public var keychainAccessGroup: String? {
        return string(for:"keychainAccessGroup")
    }
    
    public var appGroupIdentifier: String? {
        return string(for:"appGroupIdentifier")
    }
    
    fileprivate func string(for key:String) -> String? {
        guard let str = plist[key] as? String
        else {
            return nil
        }
        return str
    }
}

extension SBASharedAppInfo {
    
    /**
     Logo image for this App. This is potentially different from the AppIcon and it can
     be defined in the asset catalog as a scalable vector image.
    */
    public var logoImage: UIImage? {
        guard let imageName = logoImageName else { return nil }
        return UIImage(named: imageName)
    }
    
    /**
     The shared user defaults for this application. This will check for a shared app group
     identifier and will use the standard user defaults if not found.
    */
    public var userDefaults: UserDefaults {
        return UserDefaults(suiteName: self.appGroupIdentifier) ?? UserDefaults.standard
    }
}
