//
//  PermissionsTests.swift
//  ResearchUXFactory
//
//  Created by Shannon Young on 1/13/17.
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
//

import XCTest

class PermissionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPermssionsType_Some() {
        let permissionsStep = SBAPermissionsStep(identifier: "permissions",
                                                 permissions: [.coremotion, .notifications, .microphone])
        
        let expectedItems = [SBAPermissionObjectType(permissionType: .coremotion),
                             SBANotificationPermissionObjectType(permissionType: .notifications),
                             SBAPermissionObjectType(permissionType: .microphone)]
        
        let actualItems = permissionsStep.items as? [SBAPermissionObjectType]
        
        XCTAssertNotNil(actualItems)
        guard actualItems != nil else { return }
        XCTAssertEqual(actualItems!, expectedItems)
    }
    
    func testPermssionsType_PhotoLibrary() {
        
        let inputItem: NSDictionary =      [
            "identifier"   : "permissions",
            "type"         : "permissions",
            "title"        : "Permissions",
            "text"         : "The following permissions are required for this activity. Please change these permissions via the iPhone Settings app before continuing.",
            "items"        : [[ "identifier"    : "photoLibrary",
                                "detail"        : "Allow the app to use the Photo Library"]],
            "optional"     : false,
            ]
        
        let permissionsStep = SBAPermissionsStep(inputItem: inputItem)
        XCTAssertNotNil(permissionsStep)
        
        let actualItems = permissionsStep?.items as? [SBAPermissionObjectType]
        
        XCTAssertNotNil(actualItems)
        XCTAssertEqual(actualItems?.count ?? 0, 1)
        
        guard let item = actualItems?.first else { return }
        XCTAssertEqual(item.permissionType, SBAPermissionTypeIdentifier.photoLibrary)
        XCTAssertEqual(item.detail, "Allow the app to use the Photo Library")
        
    }
    
    func testPermissionsType_InputItem() {
        
        let inputItem: NSDictionary =      [
            "identifier"   : "permissions",
            "type"         : "permissions",
            "title"        : "Permissions",
            "text"         : "The following permissions are required for this activity. Please change these permissions via the iPhone Settings app before continuing.",
            "items"        : ["coremotion", "microphone"],
            "optional"     : false,
            ]
        let step = SBAPermissionsStep(inputItem: inputItem)
        
        XCTAssertNotNil(step)
        guard let permissionsStep = step else { return }
        
        XCTAssertEqual(permissionsStep.identifier, "permissions")
        XCTAssertFalse(permissionsStep.isOptional)
        XCTAssertEqual(permissionsStep.title, "Permissions")
        XCTAssertEqual(permissionsStep.text, "The following permissions are required for this activity. Please change these permissions via the iPhone Settings app before continuing.")
        
        let expectedItems = [SBAPermissionObjectType(permissionType: .coremotion), SBAPermissionObjectType(permissionType: .microphone)]
        let actualItems = permissionsStep.items as? [SBAPermissionObjectType]
        
        XCTAssertNotNil(actualItems)
        guard actualItems != nil else { return }
        XCTAssertEqual(actualItems!, expectedItems)
    }
    
}
