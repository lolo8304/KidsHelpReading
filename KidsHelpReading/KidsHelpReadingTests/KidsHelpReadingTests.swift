//
//  KidsHelpReadingTests.swift
//  KidsHelpReadingTests
//
//  Created by Lorenz Hänggi on 29.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import XCTest

class KidsHelpReadingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func wordSplit() {
        let words: [String] = "Das ist ein Text".allWords;
        XCTAssert(words.count == 4, "these are 4 words")
        XCTAssert(words[0] == "Das", "first word is 'Das'")
        
    }
    func wordSplitEmpty() {
        let words: [String] = "".allWords;
        XCTAssert(words.count == 0, "there is no word")
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
