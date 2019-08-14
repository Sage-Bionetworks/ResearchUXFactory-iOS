//
//  SBATextChoice+ORKTextChoice.swift
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

import Foundation

extension ORKTextChoice: SBATextChoice {
    
    public var choiceText: String { return self.text }
    public var choiceDetail: String? { return self.detailText }
    public var choiceValue: NSCoding & NSCopying & NSObjectProtocol { return self.value }
    
    @objc open var choiceDataGroups: [String] {
        return convertValueToArray()
    }
}

open class SBADataGroupTextChoice : ORKTextChoice {
    
    public var dataGroups: [String]!
    
    override open var choiceDataGroups: [String] {
        return dataGroups
    }
    
    public override init(text: String, detailText: String?, value: NSCoding & NSCopying & NSObjectProtocol, exclusive: Bool) {
        super.init(text: text, detailText: detailText, value: value, exclusive: exclusive)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataGroups = (aDecoder.decodeObject(forKey: "dataGroups") as? [String]) ?? []
    }
    
    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.dataGroups, forKey: "dataGroups")
    }
    
    override open func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! SBADataGroupTextChoice
        copy.dataGroups = self.dataGroups
        return copy
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? SBADataGroupTextChoice else { return false }
        return super.isEqual(object) && (self.dataGroups == obj.dataGroups)
    }
    
    override open var hash: Int {
        return super.hash ^ SBAObjectHash(self.dataGroups)
    }
    
}
