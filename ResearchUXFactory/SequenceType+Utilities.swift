/*
 Copyright (c) 2017, Sage Bionetworks. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


import Foundation


public extension Sequence {
    
    /**
    Returns an `Array` containing the results of mapping and filtering `transform`
    over `self`.
     
    @param  transform   The method which returns either the transformed element or `nil` if filtered.
     
    @return     An array of the transformed elements.
    */
    public func sba_mapAndFilter<T>(_ transform: (Self.Iterator.Element) throws -> T?) rethrows -> [T] {
        var result = [T]()
        for element in self {
            if let t = try transform(element) {
                result.append(t)
            }
        }
        return result
    }
    
    /**
     Returns a `Dictionary` containing the results of mapping and filtering `transform`
     over `self` where the returned values are a key/value pair.
     
     @param  transform  The function used to transform the input sequence into a key/value pair
     
     @return  A dictionary of key/value pairs.
     */
    public func sba_filteredDictionary<Hashable, T>(_ transform: (Self.Iterator.Element) throws -> (Hashable?, T?)) rethrows -> [Hashable: T] {
        var result = [Hashable:T]()
        for element in self {
            let (key, t) = try transform(element)
            if let key = key, let t = t {
                result[key] = t
            }
        }
        return result
    }
    
    /**
     Find the first element in the `Sequence` that matches the given criterion.
     
     @param  evaluate   The function to use to evaluate the search pattern.
     
     @return  The element that matchs the pattern.
    */
    public func sba_find(_ evaluate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        for element in self {
            if try evaluate(element) {
                return element
            }
        }
        return nil
    }
    
    /**
     Find the next element in the `Sequence` after the element that matches the given criterion.
     
     @param  evaluate   The function to use to evaluate the search pattern.
     
     @return  The next element after the one that matchs the pattern.
     */
    public func sba_next(_ evaluate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        var found = false
        for element in self {
            if found {
                return element
            }
            found = try evaluate(element)
        }
        return nil
    }
    
    /**
     Find the first element with the given `identifier`.
     
     @param identifier  The identifier for which to search.
     
     @return    The element with that identifier (if found).
    */
    public func sba_find(withIdentifier identifier: String) -> Self.Iterator.Element? {
        for element in self {
            if let obj = element as? NSObject,
                let id = obj.value(forKey: "identifier") as? String, (id == identifier) {
                return element
            }
        }
        return nil
    }
    
    /**
     Find the last element  with the given `identifier`.
     
     @param identifier  The identifier for which to search.
     
     @return    The element with that identifier (if found).
    */
    public func sba_findLast(withIdentifier identifier: String) -> Self.Iterator.Element? {
        for element in self.reversed() {
            if let obj = element as? NSObject,
                let id = obj.value(forKey: "identifier") as? String, (id == identifier) {
                return element
            }
        }
        return nil
    }

}
