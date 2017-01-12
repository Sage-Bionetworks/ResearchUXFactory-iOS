//
//  SBAInfoManager.m
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


#import "SBAInfoManager.h"

@implementation SBAInfoManager

// Get singleton
static id __instance;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (__instance == nil) {
            __instance = [[self alloc] init];
        }
    });
    return __instance;
}

// Set singleton
+ (void)setInfoManager:(SBAInfoManager *)infoManager {
    __instance = infoManager;
}

//
///**
// A dictionary of key/value pairs used to store information about this application.
// */
//@property (nonatomic, copy, nullable) NSDictionary <NSString*, id> *sharedAppInfo;
//
///**
// A reference to the default instance of an `SBASurveyFactory` to be used to build
// surveys.  By default, an instance of the base class `SBASurveyFactory` is instantiated.
// */
- (SBASurveyFactory *)defaultSurveyFactory {
    if (_defaultSurveyFactory == nil) {
        _defaultSurveyFactory = [[SBASurveyFactory alloc] init];
    }
    return _defaultSurveyFactory;
}



@end
