//
//  SBAURLLearnMoreAction.swift
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

/**
 The `SBAURLLearnMoreAction` class is used to define a URL that can be displayed when the user taps the
 `learnMore` button.
 */
@objc
public final class SBAURLLearnMoreAction: SBALearnMoreAction {
    
    public var learnMoreURL: URL? {
        get {
            if (_learnMoreURL == nil) {
                if self.identifier.hasPrefix("http") || self.identifier.hasPrefix("file") {
                    _learnMoreURL = URL(string: identifier)
                }
            }
            return _learnMoreURL
        }
        set(newValue) {
            _learnMoreURL = newValue
        }
    }
    fileprivate var _learnMoreURL: URL?
    
    public var learnMoreHTML: String? {
        get {
            if (_learnMoreHTML == nil) && (self.learnMoreURL == nil) {
                _learnMoreHTML = SBAResourceFinder.shared.html(forResource: identifier)
            }
            return _learnMoreHTML
        }
        set(newValue) {
            _learnMoreHTML = newValue
        }
    }
    fileprivate var _learnMoreHTML: String?
    
    override public func learnMoreAction(for step: SBALearnMoreActionStep, with taskViewController: ORKTaskViewController) {
        let vc = SBAWebViewController()
        vc.url = learnMoreURL
        vc.html = learnMoreHTML
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: vc, action: #selector(vc.dismissSelf))
        let navVC = UINavigationController(rootViewController: vc)
        taskViewController.present(navVC, animated: true, completion: nil)
    }
}

extension UIViewController {
    @objc func dismissSelf() {
        self.dismiss(animated: true) {}
    }
}
