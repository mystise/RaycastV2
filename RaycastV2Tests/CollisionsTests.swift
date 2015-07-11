//
//  CollisionsTests.swift
//  RaycastV2
//
//  Created by Adalynn Dudney on 7/11/15.
//  Copyright © 2015 Adalynn Dudney. All rights reserved.
//

import XCTest
@testable import RaycastV2

class CollisionsTests: XCTestCase {
    func testLineLine() {
        var line = LineSeg(point1: Vector(x: 0.0, y: 0.0), point2: Vector(x: 2.0, y: 0.0))
        var line2 = LineSeg(point1: Vector(x: 1.0, y: -1.0), point2: Vector(x: 1.0, y: 1.0))
        
        XCTAssertEqual(test(line, line1: line2)!, Vector(x: 1.0, y: 0.0), "Failed to detect correct collision point")
        
        line.point1 = Vector(x: 0.0, y: 0.0)
        line.point2 = Vector(x: 2.0, y: 2.0)
        line2.point1 = Vector(x: 2.0, y: 0.0)
        line2.point2 = Vector(x: 0.0, y: 2.0)
        
        XCTAssertEqual(test(line, line1: line2)!, Vector(x: 1.0, y: 1.0), "Failed to detect correct collision point")
    }
}
