//
//  NumericUtilitiesTests.swift
//  macCANableTests
//
//  Created by Robert Huston on 3/7/21.
//  Copyright © 2021 Pinpoint Dynamics, LLC. All rights reserved.
//

import XCTest

@testable import macCANable

class NumericUtilitiesTests: XCTestCase {

    // MARK: - ClampValue<T: Numeric & Comparable>(_ value: T, minimum: T, maximum: T) -> T

    func testClampLimitsLowInteger() throws {
        let min: Int = -2
        let max: Int = 2
        let val: Int = -3
        
        let actual = ClampValue(val, minimum: min, maximum: max)
        
        XCTAssertEqual(actual, min)
    }
    
    func testClampLimitsHighInteger() throws {
        let min: Int = -2
        let max: Int = 2
        let val: Int = 3
        
        let actual = ClampValue(val, minimum: min, maximum: max)
        
        XCTAssertEqual(actual, max)
    }
    
    func testClampAllowsInRangeInteger() throws {
        let min: Int = -2
        let max: Int = 2
        let val: Int = 1
        
        let actual = ClampValue(val, minimum: min, maximum: max)
        
        XCTAssertEqual(actual, val)
    }
    
    func testClampAllowsInRangeUnsigned() throws {
        let min: UInt = 1024
        let max: UInt = 2048
        let val: UInt = 1536
        
        let actual = ClampValue(val, minimum: min, maximum: max)
        
        XCTAssertEqual(actual, val)
    }

    func testClampLimitsLowFloat() throws {
        let min: Float = -3.14
        let max: Float = 3.14
        let val: Float = -4
        
        let actual = ClampValue(val, minimum: min, maximum: max)
        
        XCTAssertEqual(actual, min)
    }
    
    func testClampLimitsHighDouble() throws {
        let min: Double = 4
        let max: Double = 299792458
        let val: Double = 3E8
        
        let actual = ClampValue(val, minimum: min, maximum: max)
        
        XCTAssertEqual(actual, max)
    }

}
