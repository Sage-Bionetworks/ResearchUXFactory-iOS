//
//  SBAHealthKitWrapper.m
//  ResearchUXFactory
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

#import "SBAHealthKitWrapper.h"

ORKBiologicalSexIdentifier const ORKBiologicalSexIdentifierFemale = @"HKBiologicalSexFemale";
ORKBiologicalSexIdentifier const ORKBiologicalSexIdentifierMale = @"HKBiologicalSexMale";
ORKBiologicalSexIdentifier const ORKBiologicalSexIdentifierOther = @"HKBiologicalSexOther";

NSString *ORKHKBiologicalSexString(HKBiologicalSex biologicalSex) {
    NSString *string = nil;
    switch (biologicalSex) {
        case HKBiologicalSexFemale: string = ORKBiologicalSexIdentifierFemale; break;
        case HKBiologicalSexMale:   string = ORKBiologicalSexIdentifierMale;   break;
        case HKBiologicalSexOther:  string = ORKBiologicalSexIdentifierOther;  break;
        case HKBiologicalSexNotSet: break;
    }
    return string;
}

ORKBloodTypeIdentifier const ORKBloodTypeIdentifierAPositive = @"HKBloodTypeAPositive";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierANegative = @"HKBloodTypeANegative";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierBPositive = @"HKBloodTypeBPositive";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierBNegative = @"HKBloodTypeBNegative";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierABPositive = @"HKBloodTypeABPositive";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierABNegative = @"HKBloodTypeABNegative";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierOPositive = @"HKBloodTypeOPositive";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierONegative = @"HKBloodTypeONegative";

NSString *ORKHKBloodTypeString(HKBloodType bloodType) {
    NSString *string = nil;
    switch (bloodType) {
        case HKBloodTypeAPositive:  string = ORKBloodTypeIdentifierAPositive;   break;
        case HKBloodTypeANegative:  string = ORKBloodTypeIdentifierANegative;   break;
        case HKBloodTypeBPositive:  string = ORKBloodTypeIdentifierBPositive;   break;
        case HKBloodTypeBNegative:  string = ORKBloodTypeIdentifierBNegative;   break;
        case HKBloodTypeABPositive: string = ORKBloodTypeIdentifierABPositive;  break;
        case HKBloodTypeABNegative: string = ORKBloodTypeIdentifierABNegative;  break;
        case HKBloodTypeOPositive:  string = ORKBloodTypeIdentifierOPositive;   break;
        case HKBloodTypeONegative:  string = ORKBloodTypeIdentifierONegative;   break;
        case HKBloodTypeNotSet: break;
    }
    return string;
}
