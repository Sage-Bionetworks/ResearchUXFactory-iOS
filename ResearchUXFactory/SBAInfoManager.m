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
#import <ResearchKit/ResearchKit.h>
#import <ResearchUXFactory/ResearchUXFactory-Swift.h>

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

- (instancetype)init {
    self = [super init];
    if (self) {
        _plist = [[SBAResourceFinder shared] infoPlistForResource:@"BridgeInfo"] ?: @{};
        _defaultSurveyFactory = [[SBABaseSurveyFactory alloc] init];
        _resourceBundles = @[[NSBundle mainBundle],
                             [NSBundle bundleForClass:[SBAInfoManager class]],
                             [NSBundle bundleForClass:[ORKStep class]]];
    }
    return self;
}

#pragma mark - SBASharedAppInfo

- (NSArray *)permissionTypeItems {
    return self.plist[NSStringFromSelector(@selector(permissionTypeItems))];
}

- (NSString *)logoImageName {
    return [self stringForKey:NSStringFromSelector(@selector(logoImageName))];
}

- (NSString *)keychainService {
    return [self stringForKey:NSStringFromSelector(@selector(keychainService))];
}

- (NSString *)keychainAccessGroup {
    return [self stringForKey:NSStringFromSelector(@selector(keychainAccessGroup))];
}

- (NSString *)appGroupIdentifier {
    return [self stringForKey:NSStringFromSelector(@selector(appGroupIdentifier))];
}

- (NSString *)stringForKey:(NSString *)key {
    NSString *str = self.plist[key];
    if (![str isKindOfClass:[NSString class]] || str.length == 0) {
        return nil;
    }
    return str;
}

@end
