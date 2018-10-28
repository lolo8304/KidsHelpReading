//
//  StoryModelTests.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 29.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import XCTest

class StoryModelTests: GenericTestCase {
    
    var story = {
        return self.container.getStories().first! as StoryModel
    }

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStoryGameStart() {
        self.story.start()
        sleep(1)
        self.story.lastGame().next()
        sleep(1)
        self.story.lastGame().next()
        sleep(1)
        self.story.stop()
        
        XCTAssert(self.story.games?.count == 1, "sollte 1 sein")
        XCTAssert(self.story.lastGame().times?.count == 3, "sollte 3 sein")
        XCTAssert(self.story.points == 3, "sollte 3 sein")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
