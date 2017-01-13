//
//  SBAInfoManager.h
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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 This protocol is used as the mapping for information used to customize the study.
 The default implementation maps each key using the property name to a value
 defined in a plist dictionary included in the app resource bundle.
 
 See `BridgeInfo.plist` in the Shared SampleApp Resources included in this project
 for an example.
 */
@protocol SBASharedAppInfo <NSObject>

/**
 Array of objects that can be converted into `SBAPermissionObjectType` objects.
 */
@property (nonatomic, readonly, copy) NSArray * _Nullable permissionTypeItems;

/**
 The Logo image to use for this app.
 */
@property (nonatomic, readonly, copy) NSString * _Nullable logoImageName;

/**
 Keychain service name.
 */
@property (nonatomic, readonly, copy) NSString * _Nullable keychainService;

/**
 Keychain access group name.
 */
@property (nonatomic, readonly, copy) NSString * _Nullable keychainAccessGroup;

/**
 App group identifier used for the suite name of NSUserDefaults (if provided).
 */
@property (nonatomic, readonly, copy) NSString * _Nullable appGroupIdentifier;

@end

@class SBASurveyFactory;

/**
 `SBAInfoManager` serves as a singleton manager for the singletons included in this class.
 It also provides a default implementation for accessing shared information about the 
 application that is used by this framework.
 */
@interface SBAInfoManager : NSObject <SBASharedAppInfo>

/**
 Main entry point for the shared info manager.
 */
+ (instancetype)sharedManager NS_REFINED_FOR_SWIFT;

/**
 Optionally allow setting the info manager to a different instance from the default instance
 created with first access to the shared manager.
 
 @param infoManager Replacement info manager.
 */
+ (void)setInfoManager:(SBAInfoManager *)infoManager;

/**
 A dictionary of key/value pairs used to store information about this application.
 By default, this dictionary is instantiated by merging a plist resource with the 
 filename `BridgeInfo.plist` with a second (optional) plist called "BridgeInfo-private.plist`.
 The merged dictionary is then used to get the properties defined by `SBASharedAppInfo`
 where the property names are the keys into the dictionary.
 */
@property (nonatomic, copy, nullable) NSDictionary <NSString*, id> *plist;

/**
 A reference to the default instance of an `SBASurveyFactory` to be used to build
 surveys.  By default, an instance of the base class `SBASurveyFactory` is instantiated.
 */
@property (nonatomic, strong) SBASurveyFactory *defaultSurveyFactory;

/**
 A list of the resource bundles to search for localized strings and files.
 By default, this array includes `mainBundle`, `ResearchUXFactory`,
 and `ResearchKit` in that order.
 */
@property (nonatomic, copy) NSArray <NSBundle *> *resourceBundles;

/**
 A list of data groups that can be assigned to a user to subcategorize them.
 */
@property (nonatomic, copy, nullable) NSSet <NSString *> *currentDataGroups;

@end

NS_ASSUME_NONNULL_END
