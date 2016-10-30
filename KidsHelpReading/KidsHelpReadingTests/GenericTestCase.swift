//
//  GenericTestCase.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 30.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import XCTest

class GenericTestCase: XCTestCase {

    public var container:DataContainer {
        return DataContainer.testInstance
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
}
